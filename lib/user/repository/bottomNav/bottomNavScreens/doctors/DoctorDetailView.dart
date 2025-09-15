import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../doctor/models/doctor_availability_model.dart';
import '../../../../models/doctor_detail_viewmodel.dart';
import 'Appointment.dart';
import '../../../../models/doctor_list_viewmodel.dart';

class DoctorDetailView extends StatelessWidget {
  final Doctor doctor;
  final String doctorId;

  const DoctorDetailView({Key? key, required this.doctor, required this.doctorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isTablet = screen.width > 600;
    final controller = Get.put(DoctorDetailViewModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDoctorAvailability(doctorId);
      controller.fetchDoctorProfile(doctorId);
    });

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
                          child: Icon(Icons.person,
                              size: screen.width * 0.1,
                              color: Colors.grey),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.person,
                          size: screen.width * 0.1, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: screen.width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.fullName,
                          style: TextStyle(
                              fontSize:
                              screen.width * (isTablet ? 0.035 : 0.045),
                              fontWeight: FontWeight.bold)),
                      Text(doctor.specialty,
                          style: TextStyle(
                              fontSize:
                              screen.width * (isTablet ? 0.025 : 0.035),
                              color: Colors.grey)),
                      SizedBox(height: screen.height * 0.005),
                      Row(
                        children: [
                          Icon(Icons.work_outline,
                              size: screen.width * (isTablet ? 0.03 : 0.04),
                              color: Colors.grey),
                          SizedBox(width: screen.width * 0.01),
                          Text("${doctor.experience}",
                              style: TextStyle(
                                  fontSize: screen.width *
                                      (isTablet ? 0.025 : 0.035))),
                        ],
                      ),
                      SizedBox(height: screen.height * 0.005),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: screen.width * (isTablet ? 0.03 : 0.04),
                              color: Colors.grey),
                          SizedBox(width: screen.width * 0.01),
                          Flexible(
                            child: Text("${doctor.clinicAddress}",
                                style: TextStyle(
                                    fontSize: screen.width *
                                        (isTablet ? 0.025 : 0.035))),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: screen.height * 0.03),
            Obx(() => Container(
              padding: EdgeInsets.all(screen.width * 0.04),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(screen.width * 0.03),
                border:
                Border.all(color: Color(0xFF199A8E).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Clinic Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF199A8E),
                        fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                      )),
                  SizedBox(height: screen.height * 0.01),
                  Row(
                    children: [
                      Icon(Icons.local_hospital,
                          size: screen.width * 0.04,
                          color: Colors.grey[600]),
                      SizedBox(width: screen.width * 0.02),
                      Expanded(
                        child: Text(
                            controller.doctorProfile.value?.clinicName ??
                                doctor.clinicName,
                            style: TextStyle(
                              fontSize:
                              screen.width * (isTablet ? 0.025 : 0.035),
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: screen.height * 0.01),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: screen.width * 0.04,
                          color: Colors.grey[600]),
                      SizedBox(width: screen.width * 0.02),
                      Expanded(
                        child: Text(
                            controller.doctorProfile.value?.clinicAddress ??
                                doctor.clinicAddress,
                            style: TextStyle(
                              fontSize:
                              screen.width * (isTablet ? 0.025 : 0.035),
                              color: Colors.grey[700],
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: screen.height * 0.01),
                  Row(
                    children: [
                      Icon(Icons.money,
                          size: screen.width * 0.04,
                          color: Colors.grey[600]),
                      SizedBox(width: screen.width * 0.02),
                      Text(
                          "Consultation Fee: ₨ ${(controller.doctorProfile.value?.consultationFee ?? doctor.consultationFee).toInt()}",
                          style: TextStyle(
                            fontSize:
                            screen.width * (isTablet ? 0.025 : 0.035),
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF199A8E),
                          )),
                    ],
                  ),
                ],
              ),
            )),
            SizedBox(height: screen.height * 0.03),
            Text("About",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF199A8E),
                  fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                )),
            Obx(() => Text(
              controller.doctorProfile.value?.about ?? doctor.about,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: screen.width * (isTablet ? 0.025 : 0.035),
              ),
            )),
            SizedBox(height: screen.height * 0.03),
            Text("Bio",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF199A8E),
                  fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                )),
            SizedBox(height: screen.height * 0.005),
            Obx(() => Text(
              controller.doctorProfile.value?.bio ?? doctor.bio,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: screen.width * (isTablet ? 0.025 : 0.035),
              ),
            )),

            SizedBox(height: screen.height * 0.02),
            Text("Select Appointment Date",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF199A8E),
                  fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                )),
            SizedBox(height: screen.height * 0.01),
            Obx(() => controller.isLoading.value
                ? Center(child: CircularProgressIndicator(color: Color(0xFF199A8E)))
                : controller.availableDays.isEmpty
                ? Container(
              padding: EdgeInsets.all(screen.width * 0.04),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(screen.width * 0.03),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: screen.width * 0.02),
                  Expanded(
                    child: Text(
                      "No availability data found in Firebase. Please contact the doctor to set up their schedule.",
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                      ),
                    ),
                  ),
                ],
              ),
            )
                : Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(screen.width * 0.03),
                border: Border.all(color: Color(0xFF199A8E).withOpacity(0.2)),
              ),
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(Duration(days: 90)),
                          focusedDay:
                              controller.selectedDate.value ?? DateTime.now(),
                          calendarFormat: CalendarFormat.month,
                          selectedDayPredicate: (day) {
                            return controller.selectedDate.value != null &&
                                isSameDay(controller.selectedDate.value!, day);
                          },
                          enabledDayPredicate: (day) {
                            String dayName = getDayName(day.weekday);
                            return controller.availableDays.any(
                                (availableDay) =>
                                    availableDay.day.toLowerCase() ==
                                    dayName.toLowerCase());
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            String dayName = getDayName(selectedDay.weekday);
                            var availableDay = controller.availableDays
                                .firstWhereOrNull((day) =>
                                    day.day.toLowerCase() ==
                                    dayName.toLowerCase());

                            if (availableDay != null) {
                              controller.selectedDate.value = selectedDay;
                              controller.selectedDay.value = availableDay;
                              controller.updateTimeSlotsForDay(availableDay);
                  }
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF199A8E),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF199A8E).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  disabledDecoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.red),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Color(0xFF199A8E),
                    fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF199A8E)),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF199A8E)),
                ),
              ),
            )),
            SizedBox(height: screen.height * 0.03),
            Obx(() => controller.selectedDate.value != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Available Time Slots",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF199A8E),
                      fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                    )),
                SizedBox(height: screen.height * 0.01),
                controller.availableTimeSlots.isEmpty
                    ? Container(
                  padding: EdgeInsets.all(screen.width * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(screen.width * 0.03),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Text(
                    "No time slots available for selected date",
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                    ),
                  ),
                )
                    : Wrap(
                  spacing: screen.width * 0.025,
                  runSpacing: screen.height * 0.012,
                  children: controller.availableTimeSlots
                      .map((time) => GestureDetector(
                    onTap: () => controller.selectedTime.value = time,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screen.width * 0.04,
                        vertical: screen.height * 0.012,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(screen.width * 0.025),
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
                          fontSize:
                          screen.width * (isTablet ? 0.025 : 0.035),
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
                SizedBox(height: screen.height * 0.03),
              ],
            )
                : SizedBox()),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF199A8E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screen.width * 0.075),
                  ),
                  padding:
                  EdgeInsets.symmetric(vertical: screen.height * 0.017),
                ),
                onPressed: () {
                  if (controller.selectedTime.value.isEmpty) {
                    Get.snackbar('Error', 'Please select a time slot');
                    return;
                  }
                  if (controller.selectedDate.value == null) {
                    Get.snackbar('Error', 'Please select a date');
                    return;
                  }
                  Get.to(() => AppointmentSummaryView(
                    doctor: doctor,
                        doctorProfile: controller.doctorProfile.value,
                      ));
                },
                child: Text("Book Appointment",
                    style: TextStyle(
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

// Helper function to get weekday name
String getDayName(int weekday) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  return days[weekday - 1];
}

class Day {
  final String day;
  final int date;
  Day({required this.day, required this.date});
}
