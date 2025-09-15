import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../models/user_appointment_model.dart';
import '../../../../models/order_model.dart';

class MyAppointmentsOrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var appointments = <Appointment>[].obs;
  var orders = <OrderModel>[].obs;
  var isLoadingAppointments = false.obs;
  var isLoadingOrders = false.obs;
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserAppointments();
    loadUserOrders();
  }

  Future<void> loadUserAppointments() async {
    try {
      isLoadingAppointments.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .get();

      final appointmentsList = querySnapshot.docs
          .map((doc) => Appointment.fromFirestore(doc.data(), doc.id))
          .toList();

      appointmentsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      appointments.value = appointmentsList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: $e',
          backgroundColor: Colors.red[100], colorText: Colors.red[800]);
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  Future<void> loadUserOrders() async {
    try {
      isLoadingOrders.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      final ordersList = querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();

      ordersList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      orders.value = ordersList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load orders: $e',
          backgroundColor: Colors.red[100], colorText: Colors.red[800]);
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      loadUserAppointments(),
      loadUserOrders(),
    ]);
  }

  Color getAppointmentStatusColor(String status) {
    // Remove enum prefix if present and convert to lowercase
    final cleanStatus = status.contains('.') ? status.split('.').last : status;
    switch (cleanStatus.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paymentverified':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getAppointmentStatusDisplayText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'PENDING';
      case AppointmentStatus.paymentVerified:
        return 'PAYMENT VERIFIED';
      case AppointmentStatus.confirmed:
        return 'CONFIRMED';
      case AppointmentStatus.completed:
        return 'COMPLETED';
      case AppointmentStatus.cancelled:
        return 'CANCELLED';
      default:
        return status.toString().split('.').last.toUpperCase();
    }
  }

  Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'in_transit':
        return Colors.cyan;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class MyAppointmentsOrdersPage extends StatelessWidget {
  final MyAppointmentsOrdersController controller = Get.put(MyAppointmentsOrdersController());

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isTablet = screen.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Appointments & Orders",
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontFamily: "bolditalic",
            fontSize: screen.width * (isTablet ? 0.035 : 0.045),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF199A8E)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF199A8E)),
            onPressed: () => controller.refreshData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: EdgeInsets.all(screen.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(screen.width * 0.03),
            ),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectedTab.value = 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: screen.height * 0.015),
                      decoration: BoxDecoration(
                        color: controller.selectedTab.value == 0
                            ? Color(0xFF199A8E)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(screen.width * 0.03),
                      ),
                      child: Text(
                        "Appointments",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: controller.selectedTab.value == 0
                              ? Colors.white
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectedTab.value = 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: screen.height * 0.015),
                      decoration: BoxDecoration(
                        color: controller.selectedTab.value == 1
                            ? Color(0xFF199A8E)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(screen.width * 0.03),
                      ),
                      child: Text(
                        "Orders",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: controller.selectedTab.value == 1
                              ? Colors.white
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),

          // Content
          Expanded(
            child: Obx(() => controller.selectedTab.value == 0
                ? _buildAppointmentsTab(screen, isTablet)
                : _buildOrdersTab(screen, isTablet)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab(Size screen, bool isTablet) {
    return Obx(() {
      if (controller.isLoadingAppointments.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
          ),
        );
      }

      if (controller.appointments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: screen.width * 0.2,
                color: Colors.grey[400],
              ),
              SizedBox(height: screen.height * 0.02),
              Text(
                "No appointments found",
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: Color(0xFF199A8E),
        child: ListView.builder(
          padding: EdgeInsets.all(screen.width * 0.04),
          itemCount: controller.appointments.length,
          itemBuilder: (context, index) {
            final appointment = controller.appointments[index];
            return _buildAppointmentCard(appointment, screen, isTablet);
          },
        ),
      );
    });
  }

  Widget _buildOrdersTab(Size screen, bool isTablet) {
    return Obx(() {
      if (controller.isLoadingOrders.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
          ),
        );
      }

      if (controller.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: screen.width * 0.2,
                color: Colors.grey[400],
              ),
              SizedBox(height: screen.height * 0.02),
              Text(
                "No orders found",
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: Color(0xFF199A8E),
        child: ListView.builder(
          padding: EdgeInsets.all(screen.width * 0.04),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _buildOrderCard(order, screen, isTablet);
          },
        ),
      );
    });
  }

  Widget _buildAppointmentCard(Appointment appointment, Size screen, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.height * 0.017),
      padding: EdgeInsets.all(screen.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(screen.width * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Doctor Appointment",
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF199A8E),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screen.width * 0.03,
                  vertical: screen.height * 0.005,
                ),
                decoration: BoxDecoration(
                  color: controller
                      .getAppointmentStatusColor(appointment.status.toString())
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screen.width * 0.02),
                ),
                child: Text(
                  controller
                      .getAppointmentStatusDisplayText(appointment.status),
                  style: TextStyle(
                    color: controller.getAppointmentStatusColor(
                        appointment.status.toString()),
                    fontSize: screen.width * (isTablet ? 0.02 : 0.025),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screen.height * 0.015),

          // Appointment details
          Row(
            children: [
              Icon(Icons.person, size: screen.width * 0.04, color: Color(0xFF199A8E)),
              SizedBox(width: screen.width * 0.02),
              Text(
                "Owner: ${appointment.ownerName}",
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: screen.height * 0.008),
          Row(
            children: [
              Icon(Icons.local_hospital,
                  size: screen.width * 0.04, color: Color(0xFF199A8E)),
              SizedBox(width: screen.width * 0.02),
              Text(
                "Doctor: ${appointment.doctorName}",
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: screen.height * 0.008),

          Row(
            children: [
              Icon(Icons.medical_services,
                  size: screen.width * 0.04, color: Color(0xFF199A8E)),
              SizedBox(width: screen.width * 0.02),
              Text(
                "Consultation Type: ${appointment.consultationType.toString().split('.').last.toUpperCase()}",
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: screen.height * 0.008),

          SizedBox(height: screen.height * 0.008),

          // Conditional display based on consultation type
          if (appointment.consultationType == ConsultationType.pet) ...[
            if (appointment.petName != null) ...[
              Row(
                children: [
                  Icon(Icons.pets,
                      size: screen.width * 0.04, color: Color(0xFF199A8E)),
                  SizedBox(width: screen.width * 0.02),
                  Text(
                    "Pet: ${appointment.petName}",
                    style: TextStyle(
                      fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screen.height * 0.008),
            ],
            if (appointment.petType != null) ...[
              Row(
                children: [
                  Icon(Icons.category,
                      size: screen.width * 0.04, color: Color(0xFF199A8E)),
                  SizedBox(width: screen.width * 0.02),
                  Text(
                    "Pet Type: ${appointment.petType}",
                    style: TextStyle(
                      fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screen.height * 0.008),
            ],
          ] else ...[
            if (appointment.numberOfPatients != null) ...[
              Row(
                children: [
                  Icon(
                      appointment.consultationType == ConsultationType.livestock
                          ? Icons.agriculture
                          : Icons.egg,
                      size: screen.width * 0.04,
                      color: Color(0xFF199A8E)),
                  SizedBox(width: screen.width * 0.02),
                  Text(
                    appointment.consultationType == ConsultationType.livestock
                        ? "Livestock Count: ${appointment.numberOfPatients}"
                        : "Poultry Count: ${appointment.numberOfPatients}",
                    style: TextStyle(
                      fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screen.height * 0.008),
            ],
          ],

          Row(
            children: [
              Icon(Icons.calendar_today, size: screen.width * 0.04, color: Color(0xFF199A8E)),
              SizedBox(width: screen.width * 0.02),
              Text(
                "${appointment.selectedDay} | ${appointment.selectedTime}",
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: screen.height * 0.012),

          Divider(color: Colors.grey[300]),

          SizedBox(height: screen.height * 0.008),

          // Footer with fee and payment method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fee: Rs ${appointment.consultationFee.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF199A8E),
                ),
              ),
              Text(
                appointment.paymentMethod,
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.025 : 0.03),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, Size screen, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.height * 0.017),
      padding: EdgeInsets.all(screen.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screen.width * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screen.width * 0.02),
                    decoration: BoxDecoration(
                      color: Color(0xFF199A8E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(screen.width * 0.02),
                    ),
                    child: Icon(
                      Icons.local_pharmacy,
                      size: screen.width * 0.04,
                      color: Color(0xFF199A8E),
                    ),
                  ),
                  SizedBox(width: screen.width * 0.03),
                  Text(
                    "Medicine Order",
                    style: TextStyle(
                      fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screen.width * 0.03,
                  vertical: screen.height * 0.005,
                ),
                decoration: BoxDecoration(
                  color: controller.getOrderStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screen.width * 0.02),
                ),
                child: Text(
                  order.status.toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(
                    color: controller.getOrderStatusColor(order.status),
                    fontSize: screen.width * (isTablet ? 0.02 : 0.025),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screen.height * 0.015),

          // Order ID with improved styling
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screen.width * 0.03,
              vertical: screen.height * 0.008,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(screen.width * 0.02),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, size: screen.width * 0.035, color: Colors.grey[600]),
                SizedBox(width: screen.width * 0.02),
                Text(
                  "Order ID: ${order.id.substring(0, 8).toUpperCase()}",
                  style: TextStyle(
                    fontSize: screen.width * (isTablet ? 0.025 : 0.03),
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screen.height * 0.012),

          // Items
          Text(
            "Items (${order.items.length}):",
            style: TextStyle(
              fontSize: screen.width * (isTablet ? 0.025 : 0.035),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: screen.height * 0.008),

          ...order.items.take(3).map((item) => Padding(
            padding: EdgeInsets.only(bottom: screen.height * 0.005),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(screen.width * 0.02),
                  child: Image.network(
                    item.productImage,
                    width: screen.width * 0.08,
                    height: screen.width * 0.08,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          width: screen.width * 0.08,
                          height: screen.width * 0.08,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius:
                            BorderRadius.circular(screen.width * 0.02),
                          ),
                          child: Icon(
                            Icons.medication,
                            size: screen.width * 0.04,
                            color: Color(0xFF199A8E),
                          ),
                        ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: screen.width * 0.08,
                        height: screen.width * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(
                              screen.width * 0.02),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF199A8E)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: screen.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: screen.width * (isTablet ? 0.025 : 0.032),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Qty: ${item.quantity} × Rs ${item.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: screen.width * (isTablet ? 0.02 : 0.028),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Rs ${item.total.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: screen.width * (isTablet ? 0.025 : 0.032),
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF199A8E),
                  ),
                ),
              ],
            ),
          )).toList(),

          if (order.items.length > 3)
            Padding(
              padding: EdgeInsets.only(top: screen.height * 0.005),
              child: Text(
                "... and ${order.items.length - 3} more items",
                style: TextStyle(
                  fontSize: screen.width * (isTablet ? 0.02 : 0.028),
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          SizedBox(height: screen.height * 0.012),

          Divider(color: Colors.grey[300]),

          SizedBox(height: screen.height * 0.008),

          // Delivery info with enhanced visual design
          Container(
            padding: EdgeInsets.all(screen.width * 0.03),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(screen.width * 0.02),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: screen.width * 0.04, color: Colors.blue[600]),
                SizedBox(width: screen.width * 0.02),
                Expanded(
                  child: Text(
                    "${order.deliveryAddress}, ${order.city}, ${order.state}",
                    style: TextStyle(
                      fontSize: screen.width * (isTablet ? 0.025 : 0.03),
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screen.height * 0.012),

          // Total and payment method with enhanced contrast
          Container(
            padding: EdgeInsets.all(screen.width * 0.03),
            decoration: BoxDecoration(
              color: Color(0xFF199A8E).withOpacity(0.05),
              borderRadius: BorderRadius.circular(screen.width * 0.02),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet, size: screen.width * 0.04, color: Color(0xFF199A8E)),
                    SizedBox(width: screen.width * 0.02),
                    Text(
                      "Total: Rs ${order.total.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: screen.width * (isTablet ? 0.03 : 0.038),
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF199A8E),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screen.width * 0.025,
                    vertical: screen.height * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(screen.width * 0.015),
                  ),
                  child: Text(
                    order.paymentMethod,
                    style: TextStyle(
                      fontSize: screen.width * (isTablet ? 0.025 : 0.03),
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
