const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

// Trigger: when a new order is created, decrement stock and increment soldCount atomically
exports.onOrderCreated = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const orderId = context.params.orderId;

    if (!order || !Array.isArray(order.items)) {
      console.log('Order has no items or invalid format:', orderId);
      return null;
    }

    const productUpdates = [];
    const logWrites = [];

    for (const item of order.items) {
      if (!item.productId) continue;
      const productRef = db.collection('products').doc(item.productId);
      productUpdates.push({ ref: productRef, quantity: item.quantity, name: item.productName });
    }

    try {
      await db.runTransaction(async (tx) => {
        // Validate stock availability and prepare updates
        for (const pu of productUpdates) {
          const prodSnap = await tx.get(pu.ref);
          if (!prodSnap.exists) {
            throw new functions.https.HttpsError('not-found', `Product ${pu.ref.id} not found`);
          }
          const prodData = prodSnap.data();
          const currentStock = (typeof prodData.stockQuantity === 'number') ? prodData.stockQuantity : (typeof prodData.stock === 'number' ? prodData.stock : 0);
          if (currentStock < pu.quantity) {
            throw new functions.https.HttpsError('failed-precondition', `Insufficient stock for product ${pu.ref.id}`);
          }
        }

        // Apply stock updates and prepare logs
        for (const pu of productUpdates) {
          const prodSnap = await tx.get(pu.ref);
          const prodData = prodSnap.data();
          const previousStock = (typeof prodData.stockQuantity === 'number') ? prodData.stockQuantity : (typeof prodData.stock === 'number' ? prodData.stock : 0);
          const newStock = previousStock - pu.quantity;

          tx.update(pu.ref, {
            stockQuantity: newStock,
            soldCount: admin.firestore.FieldValue.increment(pu.quantity),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          const logRef = db.collection('inventory_logs').doc();
          logWrites.push({ ref: logRef, data: {
            id: logRef.id,
            productId: pu.ref.id,
            productName: pu.name || null,
            action: 'order_placed',
            quantityChanged: -pu.quantity,
            previousStock: previousStock,
            newStock: newStock,
            orderId: orderId,
            adminId: null,
            reason: null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          }});
        }
      });

      // Commit logs in a separate batch
      if (logWrites.length > 0) {
        const batch = db.batch();
        for (const lw of logWrites) {
          batch.set(lw.ref, lw.data);
        }
        await batch.commit();
      }

      // Mark order as updated by function
      try {
        await db.collection('orders').doc(orderId).update({
          stockUpdateStatus: 'updated_by_function',
          stockUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (e) {
        console.error('Failed to mark order stockUpdateStatus (success):', e);
      }

      console.log(`Stock updated and logs written for order ${orderId}`);
    } catch (err) {
      console.error('Failed to update stock for order', orderId, err);
      try {
        await db.collection('orders').doc(orderId).update({
          stockUpdateStatus: 'failed',
          stockUpdateError: err.message || String(err),
          stockUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (e) {
        console.error('Failed to mark order stockUpdateStatus', e);
      }
    }

    return null;
  });

// Trigger: when an order is updated; if status changed to 'cancelled', restore stock and decrement soldCount
exports.onOrderUpdated = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const orderId = context.params.orderId;

    if (!before || !after) return null;

    const prevStatus = before.status;
    const newStatus = after.status;

    // Only act when status transitions to 'cancelled' from a different status
    if (prevStatus === newStatus) return null;
    if (newStatus !== 'cancelled') return null;
    if (!Array.isArray(after.items)) return null;

    const items = after.items;
    const logWrites = [];
    const productUpdates = [];

    for (const item of items) {
      if (!item.productId) continue;
      const productRef = db.collection('products').doc(item.productId);
      productUpdates.push({ ref: productRef, quantity: item.quantity, name: item.productName });
    }

    try {
      await db.runTransaction(async (tx) => {
        for (const pu of productUpdates) {
          const prodSnap = await tx.get(pu.ref);
          if (!prodSnap.exists) {
            // If product doesn't exist, skip restore for that product but continue others
            console.warn(`Product ${pu.ref.id} not found during restore for order ${orderId}`);
            continue;
          }
          const prodData = prodSnap.data();
          const previousStock = (typeof prodData.stockQuantity === 'number') ? prodData.stockQuantity : (typeof prodData.stock === 'number' ? prodData.stock : 0);
          const newStock = previousStock + pu.quantity;

          tx.update(pu.ref, {
            stockQuantity: newStock,
            soldCount: admin.firestore.FieldValue.increment(-pu.quantity),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          const logRef = db.collection('inventory_logs').doc();
          logWrites.push({ ref: logRef, data: {
            id: logRef.id,
            productId: pu.ref.id,
            productName: pu.name || null,
            action: 'order_cancelled',
            quantityChanged: pu.quantity,
            previousStock: previousStock,
            newStock: newStock,
            orderId: orderId,
            adminId: after.updatedBy ?? null,
            reason: after.adminNotes ?? 'order_cancelled',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          }});
        }
      });

      if (logWrites.length > 0) {
        const batch = db.batch();
        for (const lw of logWrites) {
          batch.set(lw.ref, lw.data);
        }
        await batch.commit();
      }

      // Mark order as stock restored by function
      try {
        await db.collection('orders').doc(orderId).update({
          stockUpdateStatus: 'restored_by_function',
          stockUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (e) {
        console.error('Failed to mark order stockUpdateStatus (restore):', e);
      }

      console.log(`Stock restored and logs written for cancelled order ${orderId}`);
    } catch (err) {
      console.error('Failed to restore stock for cancelled order', orderId, err);
      try {
        await db.collection('orders').doc(orderId).update({
          stockUpdateStatus: 'restore_failed',
          stockUpdateError: err.message || String(err),
          stockUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (e) {
        console.error('Failed to mark order stockUpdateStatus (restore failure):', e);
      }
    }

    return null;
  });

// Helper: collect tokens for a uid from multiple common locations
async function _collectTokensForUid(uid) {
  const tokensSet = new Set();
  try {
    // 1) users/{uid}/fcmTokens subcollection
    const uTokens = await db.collection('users').doc(uid).collection('fcmTokens').get();
    uTokens.forEach(d => {
      const t = d.data() && d.data().token;
      if (t) tokensSet.add(t);
    });

    // 2) doctors/{uid}/fcmTokens subcollection
    const dTokens = await db.collection('doctors').doc(uid).collection('fcmTokens').get();
    dTokens.forEach(d => {
      const t = d.data() && d.data().token;
      if (t) tokensSet.add(t);
    });

    // 3) legacy single fields
    const uDoc = await db.collection('users').doc(uid).get();
    if (uDoc.exists && uDoc.data() && uDoc.data().fcmToken) tokensSet.add(uDoc.data().fcmToken);

    const docDoc = await db.collection('doctors').doc(uid).get();
    if (docDoc.exists && docDoc.data() && docDoc.data().fcmToken) tokensSet.add(docDoc.data().fcmToken);

    // 4) legacy fcm_tokens collection structure (fcm_tokens/{uid}/tokens/{doc})
    try {
      const legacy = await db.collection('fcm_tokens').doc(uid).collection('tokens').get();
      legacy.forEach(d => {
        const t = d.data() && d.data().token;
        if (t) tokensSet.add(t);
      });
    } catch (e) {
      // ignore if legacy structure doesn't exist
    }
  } catch (e) {
    console.error('Error collecting tokens for', uid, e);
  }
  return Array.from(tokensSet);
}

// Helper: cleanup invalid tokens returned by FCM
async function _cleanupInvalidTokenForUid(uid, badToken) {
  try {
    // remove from users/{uid}/fcmTokens
    const q1 = await db.collection('users').doc(uid).collection('fcmTokens').where('token', '==', badToken).get();
    const batch = db.batch();
    q1.forEach(d => batch.delete(d.ref));

    // remove from doctors/{uid}/fcmTokens
    const q2 = await db.collection('doctors').doc(uid).collection('fcmTokens').where('token', '==', badToken).get();
    q2.forEach(d => batch.delete(d.ref));

    // remove legacy token docs if present
    try {
      const q3 = await db.collection('fcm_tokens').doc(uid).collection('tokens').where('token', '==', badToken).get();
      q3.forEach(d => batch.delete(d.ref));
    } catch (e) {}

    // unset top-level fcmToken fields if equal
    const uRef = db.collection('users').doc(uid);
    const uSnap = await uRef.get();
    if (uSnap.exists && uSnap.data() && uSnap.data().fcmToken === badToken) {
      batch.update(uRef, { fcmToken: admin.firestore.FieldValue.delete() });
    }
    const docRef = db.collection('doctors').doc(uid);
    const docSnap = await docRef.get();
    if (docSnap.exists && docSnap.data() && docSnap.data().fcmToken === badToken) {
      batch.update(docRef, { fcmToken: admin.firestore.FieldValue.delete() });
    }

    await batch.commit();
  } catch (e) {
    console.error('Error cleaning up token', uid, badToken, e);
  }
}

// Trigger: when an appointment is updated (status change), notify the patient
exports.onAppointmentUpdated = functions.firestore
  .document('appointments/{appointmentId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const appointmentId = context.params.appointmentId;

    if (!before || !after) return null;
    const prevStatus = before.status;
    const newStatus = after.status;
    if (prevStatus === newStatus) return null;

    // Compose message
    let title = 'Appointment Update';
    let body = `Your appointment status changed to ${newStatus}`;
    if (newStatus === 'confirmed' || newStatus === 'accepted') {
      title = 'Appointment Confirmed';
      body = `Your appointment on ${after.selectedDate || ''} ${after.selectedTime || ''} has been confirmed by the doctor.`;
    } else if (newStatus === 'rejected' || newStatus === 'declined') {
      title = 'Appointment Rejected';
      body = `Your appointment was rejected by the doctor.`;
    } else if (newStatus === 'completed') {
      title = 'Appointment Completed';
      body = `Your appointment has been marked completed.`;
    }

    const patientId = after.userId || after.patientId || after.userUid;
    if (!patientId) return null;

    // Create user notification record server-side
    try {
      const userNotif = {
        userId: patientId,
        appointmentId: appointmentId,
        title: title,
        message: body,
        status: newStatus,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await db.collection('notifications').add(userNotif);

      // Also write into users/{patientId}/notifications for easy per-user reads
      try {
        await db.collection('users').doc(patientId).collection('notifications').add(userNotif);
      } catch (e) {
        console.warn('Failed to write into users/{uid}/notifications', e);
      }

      // Increment user's unread notifications counter (best-effort)
      try {
        await db.collection('users').doc(patientId).set({
          unreadUserNotificationsCount: admin.firestore.FieldValue.increment(1),
        }, { merge: true });
      } catch (e) {
        console.warn('Failed to increment user unread count', patientId, e);
      }
    } catch (e) {
      console.error('Failed to write user notification', e);
    }

    // Send FCM to patient tokens if any
    try {
      const tokens = await _collectTokensForUid(patientId);
      if (!tokens || tokens.length === 0) {
        console.log('No tokens for patient', patientId);
        return null;
      }

      const payload = {
        notification: { title, body },
        data: { appointmentId: appointmentId, type: 'appointment_status', status: String(newStatus) },
      };

      const resp = await admin.messaging().sendMulticast({ tokens, ...payload });
      // Cleanup invalid tokens
      if (resp.failureCount && resp.responses) {
        resp.responses.forEach((r, idx) => {
          if (!r.success) {
            const badToken = tokens[idx];
            const err = r.error;
            if (err && (err.code === 'messaging/registration-token-not-registered' || err.code === 'messaging/invalid-registration-token')) {
              _cleanupInvalidTokenForUid(patientId, badToken);
            }
          }
        });
      }
    } catch (e) {
      console.error('Error sending appointment-updated FCM', e);
    }

    return null;
  });

// Trigger: when an appointment is created, notify the assigned doctor (server-side write + FCM)
exports.onAppointmentCreated = functions.firestore
  .document('appointments/{appointmentId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return null;

    const appointmentId = context.params.appointmentId;
    const doctorId = data.doctorId || data.doctor || null;
    const ownerName = data.ownerName || data.userName || data.patientName || '';
    const petName = data.petName || '';
    const date = data.selectedDate || '';
    const time = data.selectedTime || '';

    if (!doctorId) {
      console.log('Appointment created but no doctorId for', appointmentId);
      return null;
    }

    // Create an in-app doctor notification (admin privileges)
    try {
      const doctorNotif = {
        doctorId: doctorId,
        appointmentId: appointmentId,
        title: 'New Appointment Request',
        message: `${ownerName} requested an appointment${petName ? ' for ' + petName : ''}`.trim(),
        patientName: ownerName,
        appointmentDate: date,
        appointmentTime: time,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await db.collection('doctor_notifications').add(doctorNotif);

      // Also write to doctors/{doctorId}/notifications for easier per-doctor reads
      try {
        await db.collection('doctors').doc(doctorId).collection('notifications').add(doctorNotif);
      } catch (e) {
        console.warn('Failed to write into doctors/{uid}/notifications', e);
      }

      // Increment unread counter on doctor's doc (best-effort)
      try {
        await db.collection('doctors').doc(doctorId).set({
          unreadDoctorNotificationsCount: admin.firestore.FieldValue.increment(1),
        }, { merge: true });
      } catch (e) {
        console.warn('Failed to increment doctor unread count', doctorId, e);
      }
    } catch (e) {
      console.error('Failed to write doctor_notifications (admin) for appointment', appointmentId, e);
    }

    // Send FCM to doctor tokens if any
    try {
      const tokens = await _collectTokensForUid(doctorId);
      if (!tokens || tokens.length === 0) {
        console.log('No tokens found for doctor', doctorId);
        return null;
      }

      const payload = {
        notification: {
          title: 'New Appointment Request',
          body: `${ownerName} booked an appointment${petName ? ' for ' + petName : ''} on ${date} ${time}`.trim(),
        },
        data: {
          appointmentId: appointmentId,
          type: 'appointment_created',
        },
      };

      const resp = await admin.messaging().sendMulticast({ tokens, ...payload });
      if (resp.failureCount && resp.responses) {
        resp.responses.forEach((r, idx) => {
          if (!r.success) {
            const badToken = tokens[idx];
            const err = r.error;
            console.warn('FCM send failure for token', badToken, err && err.code);
            if (err && (err.code === 'messaging/registration-token-not-registered' || err.code === 'messaging/invalid-registration-token')) {
              _cleanupInvalidTokenForUid(doctorId, badToken);
            }
          }
        });
      }

      console.log(`Sent appointment-created notification for ${appointmentId} to doctor ${doctorId}`);
    } catch (e) {
      console.error('Error sending appointment-created FCM', e);
    }

    return null;
  });
