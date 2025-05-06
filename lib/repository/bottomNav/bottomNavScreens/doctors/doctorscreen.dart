import 'package:al_haiwan/repository/bottomNav/bottomNavScreens/doctors/DoctorDetailView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'doctor_list_viewmodel.dart';

class Doctorscreen extends StatelessWidget {
  final DoctorListViewModel controller = Get.put(DoctorListViewModel());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.18;
    final padding = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() => ListView.builder(
        padding: EdgeInsets.all(padding),
        itemCount: controller.doctors.length,
        itemBuilder: (context, index) {
          final doctor = controller.doctors[index];
          return  InkWell(
            onTap: () {
              Get.to(() => DoctorDetailView(doctor: doctor));
            },
            child: Container(
              margin: EdgeInsets.only(bottom: padding),
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(imageSize * 0.2),
                    child: Image.asset(
                      doctor.image,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.042,
                          ),
                        ),
                        Text(
                          doctor.speciality,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: screenWidth * 0.04, color: Color(0xFF199A8E)),
                            SizedBox(width: 4),
                            Text(
                              "${doctor.rating}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.location_on,
                                size: screenWidth * 0.04, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              "${doctor.distance} away",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

        },
      )),
    );
  }
}
