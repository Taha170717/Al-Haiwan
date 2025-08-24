import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Appointment.dart';
import 'doctor_detail_viewmodel.dart';
import 'doctor_list_viewmodel.dart';

class DoctorDetailView extends StatelessWidget {
  final Doctor doctor;
  final String doctorId;

  const DoctorDetailView({Key? key, required this.doctor, required this.doctorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isTablet = screen.width > 600;
    final controller = Get.put(DoctorDetailViewModel());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Doctor Detail', style: TextStyle(
          fontFamily: "bolditalic",
          color: Color(0xFF199A8E),
          fontSize: screen.width * (isTablet ? 0.035 : 0.045),
        )),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF199A8E)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screen.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: screen.width * (isTablet ? 0.15 : 0.2),
                  height: screen.width * (isTablet ? 0.15 : 0.2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screen.width * 0.03),
                    border: Border.all(color: Color(0xFF199A8E), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screen.width * 0.03),
                    child: doctor.profileImageUrl.isNotEmpty
                        ? Image.network(
                      doctor.profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.person, size: screen.width * 0.1, color: Colors.grey),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.person, size: screen.width * 0.1, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: screen.width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.fullName, style: TextStyle(
                          fontSize: screen.width * (isTablet ? 0.035 : 0.045),
                          fontWeight: FontWeight.bold
                      )),
                      Text(doctor.specialty, style: TextStyle(
                          fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                          color: Colors.grey
                      )),
                      SizedBox(height: screen.height * 0.005),
                      Row(
                        children: [
                          Icon(Icons.work_outline, size: screen.width * (isTablet ? 0.03 : 0.04), color: Colors.grey),
                          SizedBox(width: screen.width * 0.01),
                          Text("${doctor.experience}", style: TextStyle(
                              fontSize: screen.width * (isTablet ? 0.025 : 0.035)
                          )),
                        ],
                      ),
                      SizedBox(height: screen.height * 0.005),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: screen.width * (isTablet ? 0.03 : 0.04), color: Colors.grey),
                          SizedBox(width: screen.width * 0.01),
                          Flexible(
                            child: Text("${doctor.clinicAddress}", style: TextStyle(
                                fontSize: screen.width * (isTablet ? 0.025 : 0.035)
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: screen.height * 0.03),

            Container(
              padding: EdgeInsets.all(screen.width * 0.04),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(screen.width * 0.03),
                border: Border.all(color: Color(0xFF199A8E).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Clinic Information", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF199A8E),
                    fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                  )),
                  SizedBox(height: screen.height * 0.01),
                  Row(
                    children: [
                      Icon(Icons.local_hospital, size: screen.width * 0.04, color: Colors.grey[600]),
                      SizedBox(width: screen.width * 0.02),
                      Expanded(
                        child: Text(doctor.clinicName, style: TextStyle(
                          fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                          fontWeight: FontWeight.w500,
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: screen.height * 0.01),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: screen.width * 0.04, color: Colors.grey[600]),
                      SizedBox(width: screen.width * 0.02),
                      Expanded(
                        child: Text(doctor.clinicAddress, style: TextStyle(
                          fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                          color: Colors.grey[700],
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: screen.height * 0.01),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: screen.width * 0.04, color: Colors.grey[600]),
                      SizedBox(width: screen.width * 0.02),
                      Text("Consultation Fee: ₨${doctor.consultationFee.toInt()}", style: TextStyle(
                        fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF199A8E),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screen.height * 0.03),

            Text("About", style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF199A8E),
              fontSize: screen.width * (isTablet ? 0.03 : 0.04),
            )),
            SizedBox(height: screen.height * 0.005),
            Text(
              doctor.about,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: screen.width * (isTablet ? 0.025 : 0.035),
              ),
            ),
            SizedBox(height: screen.height * 0.02),

            Text("Bio", style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF199A8E),
              fontSize: screen.width * (isTablet ? 0.03 : 0.04),
            )),
            SizedBox(height: screen.height * 0.005),
            Text(
              doctor.id,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: screen.width * (isTablet ? 0.025 : 0.035),
              ),
            ),
            SizedBox(height: screen.height * 0.03),

            Text("Available Days", style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF199A8E),
              fontSize: screen.width * (isTablet ? 0.03 : 0.04),
            )),
            SizedBox(height: screen.height * 0.01),

            SizedBox(
              height: screen.height * (isTablet ? 0.08 : 0.075),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: doctor.availableDays.length,
                itemBuilder: (context, index) {
                  final dayName = doctor.availableDays[index];
                  final dayDate = 21 + index; // Simple date calculation
                  final day = Day(day: dayName, date: dayDate);

                  return Obx(() => GestureDetector(
                        onTap: () => controller.selectedDay.value = day,
                        child: Container(
                      width: screen.width * (isTablet ? 0.12 : 0.15),
                      margin: EdgeInsets.only(right: screen.width * 0.025),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screen.width * 0.025),
                        color: controller.selectedDay.value.day == day.day
                            ? Color(0xFF199A8E)
                            : Colors.grey[200],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(day.day, style: TextStyle(
                              color: controller.selectedDay.value.day == day.day
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: screen.width * (isTablet ? 0.025 : 0.03),
                            )),
                            Text(day.date.toString(), style: TextStyle(
                              color: controller.selectedDay.value.day == day.day
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: screen.width * (isTablet ? 0.03 : 0.035),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ));
                },
              ),
            ),

            SizedBox(height: screen.height * 0.03),

            Text("Available Time Slots", style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF199A8E),
              fontSize: screen.width * (isTablet ? 0.03 : 0.04),
            )),
            SizedBox(height: screen.height * 0.01),

            Wrap(
              spacing: screen.width * 0.025,
              runSpacing: screen.height * 0.012,
              children: doctor.availableTimeSlots
                  .map((time) => Obx(() => GestureDetector(
                onTap: () => controller.selectedTime.value = time,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screen.width * 0.04,
                    vertical: screen.height * 0.012,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screen.width * 0.025),
                    color: controller.selectedTime.value == time
                        ? Color(0xFF199A8E)
                        : Colors.grey[200],
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: controller.selectedTime.value == time
                          ? Colors.white
                          : Colors.black,
                      fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                    ),
                  ),
                ),
              )))
                  .toList(),
            ),
            SizedBox(height: screen.height * 0.03),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF199A8E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screen.width * 0.075),
                  ),
                  padding: EdgeInsets.symmetric(vertical: screen.height * 0.017),
                ),
                onPressed: () {
                  if (controller.selectedTime.value.isEmpty) {
                    Get.snackbar('Error', 'Please select a time slot');
                    return;
                  }
                  Get.to(() => AppointmentSummaryView(doctor: doctor));
                },
                child: Text("Book Appointment", style: TextStyle(
                  color: Colors.white,
                  fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
