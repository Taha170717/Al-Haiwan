import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../../doctor/controller/doctor_chat_controller.dart';
import '../../../../../doctor/views/bottom_nav_pages/chat/doctor_chat_screen.dart';
import 'package:al_haiwan/utils/custom_snackbar.dart';


class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorProfileImage;
  final String petName;
  final String date;
  final String time;
  final String reason;
  final String status;
  final String rejectedReason;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorProfileImage,
    required this.petName,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
    required this.rejectedReason,
    required this.createdAt,
  });

  factory Appointment.fromFirestore(Map<String, dynamic> data, String id) {
    // Handle selectedDate - could be Timestamp or String
    String formattedDate = '';
    var rawDate = data['selectedDate'];
    if (rawDate is Timestamp) {
      formattedDate = DateFormat('MMM dd, yyyy').format(rawDate.toDate());
    } else if (rawDate is String && rawDate.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(rawDate);
        formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);
      } catch (e) {
        formattedDate = rawDate; // fallback to original string
      }
    }

    // Handle selectedTime - should be a simple string
    String formattedTime = data['selectedTime']?.toString() ?? '';

    return Appointment(
      id: id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? 'Unknown Doctor',
      doctorSpecialty: data['doctorSpecialty'] ?? 'Veterinarian',
      doctorProfileImage: data['doctorprofilepic'] ?? '',
      petName: data['petName'] ?? '',
      date: formattedDate,
      time: formattedTime,
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      // read rejected reason from doctorNotes or rejectedReason field
      rejectedReason: (data['doctorNotes'] ?? data['rejectedReason'] ?? '') as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// Small reusable chat button that keeps its own loading state.
class _ChatButton extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorImage;
  final DoctorChatController chatController;

  const _ChatButton({required this.doctorId, required this.doctorName, required this.doctorImage, required this.chatController});

  @override
  State<_ChatButton> createState() => _ChatButtonState();
}

class _ChatButtonState extends State<_ChatButton> {
  bool _isLoading = false;

  Future<void> _startChat(BuildContext context) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      if (widget.doctorId.isEmpty) {
        CustomSnackbar.showError('Error', 'Doctor ID is empty', context: context);
        setState(() => _isLoading = false);
        return;
      }

      final chatId = await widget.chatController.startChatWithDoctor(doctorId: widget.doctorId, doctorName: widget.doctorName, doctorImage: widget.doctorImage);
      if (chatId.isEmpty) {
        CustomSnackbar.showError('Error', 'Unable to start chat', context: context);
        setState(() => _isLoading = false);
        return;
      }

      // stop spinner before navigating so it won't remain visible on previous screen
      setState(() => _isLoading = false);
      // allow a short delay so the spinner state can repaint before navigation starts
      await Future.delayed(Duration(milliseconds: 300));
      // push the chat screen so user can go back to appointments via back button
      Get.to(() => DoctorChatScreen(
            chatId: chatId,
            doctorName: widget.doctorName,
            doctorImage: widget.doctorImage,
            participantName: widget.doctorName,
            participantImage: widget.doctorImage,
          ));
    } catch (e) {
      setState(() => _isLoading = false);
      CustomSnackbar.showError('Error', 'Failed to start chat', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 140),
      child: ElevatedButton.icon(
        onPressed: () => _startChat(context),
        icon: _isLoading ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(Icons.chat, size: 14, color: Colors.white),
        label: _isLoading ? Text('Starting...', style: TextStyle(fontSize: 12, color: Colors.white)) : Text('Chat', style: TextStyle(fontSize: 12, color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF199A8E)),
      ),
    );
  }
}

// Helper to map appointment status to a color. Kept at top-level so it's available from the widget tree.
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return Colors.green;
    case 'completed':
      return Colors.blue;
    case 'pending':
      return Colors.orange;
    case 'cancelled':
      return Colors.red;
    case 'rejected':
      return Colors.red.shade700;
    default:
      return Colors.grey;
  }
}

class MyAppointmentScreen extends StatelessWidget {
  final DoctorChatController chatController = Get.put(DoctorChatController());

  MyAppointmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isTablet = screen.width > 600;

    // Defensive: require an authenticated user before building Firestore queries
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Appointments', style: TextStyle(color: Color(0xFF199A8E), fontFamily: 'bolditalic', fontSize: screen.width * (isTablet ? 0.035 : 0.045))),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF199A8E)),
        ),
        body: Center(child: Text('Please sign in to view your appointments', style: TextStyle(color: Colors.grey))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontFamily: 'bolditalic',
            fontSize: screen.width * (isTablet ? 0.035 : 0.045),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF199A8E)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: uid)
            .where('status', whereIn: ['pending', 'confirmed', 'completed', 'rejected'])
            .snapshots(),
        builder: (context, snapshot) {
          try {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF199A8E))));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading appointments', style: TextStyle(color: Colors.grey)));
            }

            // Parse appointments defensively: skip malformed docs
            final appointments = <Appointment>[];
            final docList = snapshot.data?.docs ?? [];
            for (final d in docList) {
              try {
                final raw = d.data();
                if (raw == null) continue;
                Map<String, dynamic> map;
                if (raw is Map<String, dynamic>) map = raw;
                else if (raw is Map) map = Map<String, dynamic>.from(raw);
                else continue;

                appointments.add(Appointment.fromFirestore(map, d.id));
              } catch (e) {
                // skip malformed doc
                print('Skipped malformed appointment ${d.id}: $e');
                continue;
              }
            }

            if (appointments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: screen.width * 0.2, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text('No appointments yet', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return SafeArea(
              child: ListView.separated(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemCount: appointments.length,
                separatorBuilder: (_, __) => SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  return _buildAppointmentCard(context, appt, screen, isTablet);
                },
              ),
            );
          } catch (e, st) {
            print('Error building appointments UI: $e\n$st');
            return Center(child: Text('Error loading appointments', style: TextStyle(color: Colors.red)));
          }
        },
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment, Size screen, bool isTablet) {
    // compact, robust layout that avoids overflow
    final statusColor = _getStatusColor(appointment.status);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // avatar
            Container(
              width: isTablet ? 72 : 56,
              height: isTablet ? 72 : 56,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[100]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: appointment.doctorProfileImage.isNotEmpty
                    ? Image.network(appointment.doctorProfileImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person))
                    : Icon(Icons.person, size: isTablet ? 40 : 28),
              ),
            ),

            SizedBox(width: 12),

            // main info
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Doctor name full width on its own line so it doesn't get truncated by the status badge
                Text(appointment.doctorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 16 : 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 6),
                // Specialty on its own line
                Text(appointment.doctorSpecialty, style: TextStyle(color: Colors.grey[600], fontSize: isTablet ? 13 : 12)),
                SizedBox(height: 8),
                // Right-aligned column with status and (optionally) Chat button so name can use full width
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                        child: Text(appointment.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(height: 6),
                      // Chat button moved here (only for confirmed status)
                      if (appointment.status.toLowerCase() == 'confirmed')
                        _ChatButton(doctorId: appointment.doctorId, doctorName: appointment.doctorName, doctorImage: appointment.doctorProfileImage, chatController: chatController),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey), SizedBox(width: 6), Flexible(child: Text('${appointment.date} ${appointment.time}', style: TextStyle(fontSize: 12, color: Colors.grey[700])))]),
                SizedBox(height: 6),
                Row(children: [Icon(Icons.pets, size: 14, color: Colors.grey), SizedBox(width: 6), Flexible(child: Text(appointment.petName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))]),
                if (appointment.reason.isNotEmpty) SizedBox(height: 6),
                if (appointment.reason.isNotEmpty) Text(appointment.reason, style: TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                // Prescription button placed under reason field
                if (appointment.reason.isNotEmpty) SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('prescriptions')
                      .where('appointmentId', isEqualTo: appointment.id)
                      .snapshots(),
                  builder: (context, presSnap) {
                    if (presSnap.connectionState == ConnectionState.waiting) {
                      return SizedBox();
                    }

                    // We removed server-side ordering to avoid requiring a composite index.
                    // Sort the documents client-side by createdAt (newest first).
                    final rawDocs = presSnap.data?.docs ?? [];
                    final docs = List<QueryDocumentSnapshot>.from(rawDocs);
                    docs.sort((a, b) {
                      DateTime da = DateTime.fromMillisecondsSinceEpoch(0);
                      DateTime db = DateTime.fromMillisecondsSinceEpoch(0);
                      try {
                        final aData = a.data() as Map<String, dynamic>;
                        final at = aData['createdAt'];
                        if (at is Timestamp) da = at.toDate();
                        else if (at is int) da = DateTime.fromMillisecondsSinceEpoch(at);
                        else if (at is String) da = DateTime.tryParse(at) ?? da;
                      } catch (_) {}
                      try {
                        final bData = b.data() as Map<String, dynamic>;
                        final bt = bData['createdAt'];
                        if (bt is Timestamp) db = bt.toDate();
                        else if (bt is int) db = DateTime.fromMillisecondsSinceEpoch(bt);
                        else if (bt is String) db = DateTime.tryParse(bt) ?? db;
                      } catch (_) {}
                      return db.compareTo(da); // newest first
                    });

                    final count = docs.length;
                    if (count > 0) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => _showPrescriptionsDialog(context, appointment.id, docs),
                          icon: Icon(Icons.receipt_long, size: 16, color: Color(0xFF199A8E)),
                          label: Text('View Prescription${count > 1 ? ' (${count})' : ''}', style: TextStyle(color: Color(0xFF199A8E))),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      );
                    }

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: Icon(Icons.receipt_long, size: 16, color: Colors.grey[400]),
                        label: Text('No Prescription', style: TextStyle(color: Colors.grey[400])),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    );
                  },
                ),
                if (appointment.status.toLowerCase() == 'rejected' && appointment.rejectedReason.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Row(children: [Icon(Icons.info_outline, size: 14, color: Colors.red[400]), SizedBox(width: 6), Expanded(child: Text('Rejected: ${appointment.rejectedReason}', style: TextStyle(color: Colors.red[700], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis))]),
                ],
              ]),
            ),

            // actions column - center vertically so chat button sits a bit lower and doesn't overlap the name
          ]),

          // For completed appointments, show review button below the card.
          if (appointment.status.trim().toLowerCase() == 'completed') ...[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('appointmentId', isEqualTo: appointment.id)
                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .limit(1)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return SizedBox();
                }
                final hasReview = snap.hasData && (snap.data?.docs.isNotEmpty ?? false);
                if (hasReview) {
                  // user already reviewed this appointment - hide the button
                  return SizedBox();
                }

                return Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 0, maxWidth: 140),
                    child: TextButton(
                      onPressed: () => _showReviewDialog(context, appointment),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Leave a Review', style: TextStyle(color: Color(0xFF199A8E), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, Appointment appointment) {
    final ratingCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Add Review', style: TextStyle(fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ratingCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(hintText: 'Rating (1-5)'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(hintText: 'Write your review...'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              ElevatedButton(
                onPressed: submitting
                    ? null
                    : () async {
                        final ratingText = ratingCtrl.text.trim();
                        final comment = commentCtrl.text.trim();
                        final rating = int.tryParse(ratingText) ?? 0;
                        if (rating < 1 || rating > 5) {
                          CustomSnackbar.showError('Invalid', 'Please enter a rating between 1 and 5', context: context);
                          return;
                        }
                        if (comment.isEmpty) {
                          CustomSnackbar.showError('Required', 'Please write a short review', context: context);
                          return;
                        }

                        try {
                          setState(() => submitting = true);
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          final displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
                          if (uid == null) throw Exception('Not signed in');

                          // Prefer the name stored in the users collection (username/name)
                          String resolvedName = displayName;
                          try {
                            final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                            if (userDoc.exists) {
                              final udata = userDoc.data();
                              if (udata != null) {
                                resolvedName = (udata['username'] as String?) ?? (udata['name'] as String?) ?? resolvedName;
                              }
                            }
                          } catch (_) {
                            // ignore and keep displayName
                          }

                          await FirebaseFirestore.instance.collection('reviews').add({
                            'userId': uid,
                            'userName': resolvedName,
                            'ownerName': resolvedName, // store the user's display name from users collection when possible
                            'doctorId': appointment.doctorId,
                            'rating': rating,
                            'comment': comment,
                            'appointmentId': appointment.id,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          Navigator.pop(context);
                          CustomSnackbar.showSuccess('Thank you', 'Your review has been submitted', context: context);
                        } catch (e) {
                          CustomSnackbar.showError('Error', 'Failed to submit review: ${e.toString()}', context: context);
                        } finally {
                          setState(() => submitting = false);
                        }
                      },
                child: submitting ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPrescriptionsDialog(BuildContext context, String appointmentId, List<QueryDocumentSnapshot> docs) {
    showDialog(
      context: context,
      builder: (context) {
        final screen = MediaQuery.of(context).size;
        final dialogWidth = screen.width > 600 ? screen.width * 0.6 : screen.width * 0.9;

        return AlertDialog(
          title: Text('Prescription', style: TextStyle(fontWeight: FontWeight.w600)),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: docs.map((d) {
                  // Defensive parsing: treat data as Map<String, dynamic> if possible
                  Map<String, dynamic> data = {};
                  try {
                    final raw = d.data();
                    if (raw is Map<String, dynamic>) data = raw;
                    else if (raw is Map) data = Map<String, dynamic>.from(raw);
                  } catch (_) {
                    data = {};
                  }

                  final text = (data['prescription'] ?? '').toString();
                  final ts = data['createdAt'];
                  String when = '';
                  try {
                    if (ts is Timestamp) when = DateFormat('MMM dd, yyyy • hh:mm a').format(ts.toDate());
                    else if (ts is int) when = DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(ts));
                    else if (ts is String && ts.isNotEmpty) when = ts;
                  } catch (e) {
                    when = '';
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (when.isNotEmpty) Text(when, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      if (when.isNotEmpty) SizedBox(height: 6),
                      Text(text.isNotEmpty ? text : 'No prescription text available', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                    ]),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
          ],
        );
      },
    );
  }
}
