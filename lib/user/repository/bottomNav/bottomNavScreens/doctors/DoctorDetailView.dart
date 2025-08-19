import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreens/doctors/Appointment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'doctor_list_viewmodel.dart'; // Import your model
import 'doctor_detail_viewmodel.dart'; // ViewModel if needed

class DoctorDetailView extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailView({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final controller = Get.put(DoctorDetailViewModel());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Doctor Detail',style: TextStyle(
          fontFamily: "bolditalic",color: Color(0xFF199A8E)
        ),),
        backgroundColor: Colors.white,
        //foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(screen.width * 0.05),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(screen.width * 0.03),
                  child: Image.asset(
                    doctor.image,
                    width: screen.width * 0.2,
                    height: screen.width * 0.2,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: screen.width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name,
                          style: TextStyle(
                              fontSize: screen.width * 0.045,
                              fontWeight: FontWeight.bold)),
                      Text(doctor.speciality,
                          style: TextStyle(
                              fontSize: screen.width * 0.035,
                              color: Colors.grey)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star,
                              size: 16, color: Color(0xFF199A8E)),
                          SizedBox(width: 4),
                          Text("${doctor.rating}"),
                          SizedBox(width: 10),
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          Text("${doctor.distance}"),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: screen.height * 0.03),
            Text("About", style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF199A8E))),
            SizedBox(height: 4),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...",
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: screen.height * 0.03),

            // Date Selector (Static for simplicity)
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: controller.days
                    .map((day) => Obx(() => GestureDetector(
                  onTap: () => controller.selectedDay.value = day,
                  child: Container(
                    width: 60,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: controller.selectedDay.value == day
                          ? Color(0xFF199A8E)
                          : Colors.grey[200],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(day.day,
                              style: TextStyle(
                                  color: controller.selectedDay.value ==
                                      day
                                      ? Colors.white
                                      : Colors.black)),
                          Text(day.date.toString(),
                              style: TextStyle(
                                  color: controller.selectedDay.value ==
                                      day
                                      ? Colors.white
                                      : Colors.black)),
                        ],
                      ),
                    ),
                  ),
                )))
                    .toList(),
              ),
            ),

            SizedBox(height: screen.height * 0.03),

            // Time Slots
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.timeSlots
                  .map((time) => Obx(() => GestureDetector(
                onTap: () => controller.selectedTime.value = time,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: controller.selectedTime.value == time
                        ? Color(0xFF199A8E)
                        : Colors.grey[200],
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                        color: controller.selectedTime.value == time
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              )))
                  .toList(),
            ),
            Spacer(),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF199A8E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(vertical: 14),

                ),
                onPressed: () {
                  // Booking logic
                  Get.to(() => AppointmentSummaryView(doctor: doctor));

                },
                child: Text("Book Appointment",style: TextStyle(
                  color: Colors.white
                ),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
