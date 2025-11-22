import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/doctor_profile_controller.dart';
import '../../../models/doctor_availability_model.dart';

class DoctorProfileManagementScreen extends StatelessWidget {
  final DoctorProfileController controller = Get.put(DoctorProfileController());

  DoctorProfileManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Manage Profile',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'bolditalic'
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Obx(() => Switch(
            value: controller.isCurrentlyAvailable.value,
            onChanged: (value) => controller.toggleAvailabilityStatus(),
            activeColor: Colors.white,
          )),
          SizedBox(width: screenWidth * 0.04),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(context),
              SizedBox(height: screenHeight * 0.02),
              _buildBasicInfoCard(context),
              SizedBox(height: screenHeight * 0.02),
              _buildProfessionalDetailsCard(context),
              SizedBox(height: screenHeight * 0.02),
              _buildPaymentDetailsCard(context),
              SizedBox(height: screenHeight * 0.02),
              _buildAvailabilityCard(context),
              SizedBox(height: screenHeight * 0.02),
              _buildSaveButton(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: controller.isCurrentlyAvailable.value
                ? [Colors.green[400]!, Colors.green[600]!]
                : [Colors.red[400]!, Colors.red[600]!],
          ),
        ),
        child: Row(
          children: [
            Icon(
              controller.isCurrentlyAvailable.value
                  ? Icons.check_circle
                  : Icons.cancel,
              color: Colors.white,
              size: screenWidth * 0.08,
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.isCurrentlyAvailable.value
                        ? 'Currently Available'
                        : 'Currently Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Toggle availability in the top right',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeColor = const Color(0xFF199A8E);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: themeColor,
                  child: Icon(Icons.info, color: Colors.white),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildProfileTextField(
              context,
              initialValue: controller.registrationNumber.value,
              label: 'Medical Registration Number',
              icon: Icons.badge,
              onChanged: (v) => controller.registrationNumber.value = v,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileTextField(
              context,
              initialValue: controller.specialization.value,
              label: 'Specialization',
              icon: Icons.medical_services,
              onChanged: (v) => controller.specialization.value = v,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileTextField(
              context,
              initialValue: controller.consultationFee.value.toString(),
              label: 'Consultation Fee (RS)',
              icon: Icons.money,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  controller.consultationFee.value = double.tryParse(v) ?? 0.0,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileTextField(
              context,
              initialValue: controller.bio.value,
              label: 'Bio (Short Description)',
              icon: Icons.person,
              maxLines: 2,
              onChanged: (v) => controller.bio.value = v,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileTextField(
              context,
              initialValue: controller.about.value,
              label: 'About (Detailed Description)',
              icon: Icons.info_outline,
              maxLines: 4,
              onChanged: (v) => controller.about.value = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalDetailsCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeColor = const Color(0xFF199A8E);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: themeColor,
                  child: Icon(Icons.local_hospital, color: Colors.white),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Clinic Information',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildProfileTextField(
              context,
              initialValue: controller.clinicName.value,
              label: 'Clinic Name',
              icon: Icons.local_hospital,
              onChanged: (v) => controller.clinicName.value = v,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileTextField(
              context,
              initialValue: controller.clinicAddress.value,
              label: 'Clinic Address',
              icon: Icons.location_on,
              maxLines: 3,
              onChanged: (v) => controller.clinicAddress.value = v,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileTextField(
              context,
              initialValue: controller.clinicContact.value,
              label: 'Clinic Contact Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              onChanged: (v) => controller.clinicContact.value = v,
            ),
            SizedBox(height: screenHeight * 0.02),
            Obx(() => SwitchListTile(
              title: Text('Online Consultation Only',
                  style: TextStyle(color: themeColor)),
              subtitle: Text('Toggle if you only provide online consultations'),
              value: controller.isOnlineOnly.value,
              onChanged: (value) {
                controller.isOnlineOnly.value = value;
              },
                  activeColor: themeColor,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeColor = const Color(0xFF199A8E);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: themeColor,
                  child: Icon(Icons.payment, color: Colors.white),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildProfileTextField(
              context,
              initialValue: controller.easypaisaNumber.value,
              label: 'Easypaisa Number',
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              onChanged: (v) => controller.easypaisaNumber.value = v,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileTextField(
              context,
              initialValue: controller.jazzcashNumber.value,
              label: 'Jazzcash Number',
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              onChanged: (v) => controller.jazzcashNumber.value = v,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileTextField(
              context,
              initialValue: controller.bankName.value,
              label: 'Bank Name',
              icon: Icons.account_balance,
              onChanged: (v) => controller.bankName.value = v,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileTextField(
              context,
              initialValue: controller.bankAccountNumber.value,
              label: 'Account Number',
              icon: Icons.numbers,
              keyboardType: TextInputType.number,
              onChanged: (v) => controller.bankAccountNumber.value = v,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildProfileTextField(
              context,
              initialValue: controller.bankHolderName.value,
              label: 'Account Holder Name',
              icon: Icons.perm_identity,
              onChanged: (v) => controller.bankHolderName.value = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Availability',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),
            SizedBox(height: screenWidth * 0.04),

            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.weeklyAvailability.length,
              itemBuilder: (context, index) {
                return _buildDayAvailabilityCard(context, index);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDayAvailabilityCard(BuildContext context, int dayIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dayAvailability = controller.weeklyAvailability[dayIndex];

    return Card(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                dayAvailability.day,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch(
              value: dayAvailability.isAvailable,
              onChanged: (value) {
                controller.toggleDayAvailability(dayIndex);
              },
              activeColor: Colors.teal,
            ),
          ],
        ),
        children: [
          if (dayAvailability.isAvailable) ...[
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  ...dayAvailability.timeSlots.map((slot) =>
                      _buildTimeSlotCard(context, dayIndex, slot)
                  ).toList(),

                  ElevatedButton.icon(
                    onPressed: () => _showAddTimeSlotDialog(context, dayIndex),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Time Slot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(BuildContext context, int dayIndex, TimeSlot slot) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.teal[50],
      child: ListTile(
        title: Text(
          '${slot.startTime} - ${slot.endTime}',
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text('Max ${slot.maxPatients} patients'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            controller.removeTimeSlot(dayIndex, slot.id);
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: double.infinity,
      height: screenWidth * 0.12,
      child: ElevatedButton(
        onPressed: () {
          controller.updateProfile();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Save Profile',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddTimeSlotDialog(BuildContext context, int dayIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    String startTime = '09:00';
    String endTime = '10:00';
    int maxPatients = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Time Slot',
          style: TextStyle(fontSize: screenWidth * 0.045),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(startTime),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      startTime = time.format(context);
                    });
                  }
                },
              ),

              ListTile(
                title: const Text('End Time'),
                subtitle: Text(endTime),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      endTime = time.format(context);
                    });
                  }
                },
              ),

              TextFormField(
                initialValue: maxPatients.toString(),
                decoration: const InputDecoration(
                  labelText: 'Max Patients',
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  maxPatients = int.tryParse(value) ?? 1;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addTimeSlot(dayIndex, startTime, endTime, maxPatients);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTextField(
    BuildContext context, {
    required String initialValue,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeColor = const Color(0xFF199A8E);
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: themeColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: themeColor, width: 2),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.03, horizontal: screenWidth * 0.04),
      ),
    );
  }
}
