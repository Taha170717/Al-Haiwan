import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../doctor/models/appointment_model.dart';

class AdminAppointmentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var confirmedAppointments = <AppointmentModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var selectedFilter = 'all'.obs; // all, today, thisWeek, thisMonth

  @override
  void onInit() {
    super.onInit();
    fetchConfirmedAppointments();
  }

  Future<void> fetchConfirmedAppointments() async {
    try {
      isLoading.value = true;

      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('status', whereIn: ['confirmed', 'completed', 'paymentVerified'])
          .get();

      List<AppointmentModel> appointments = [];

      for (var doc in snapshot.docs) {
        try {
          AppointmentModel appointment = AppointmentModel.fromFirestore(doc);

          // Fetch doctor details
          DocumentSnapshot doctorDoc = await _firestore
              .collection('doctor_profiles')
              .doc(appointment.doctorId)
              .get();

          if (doctorDoc.exists) {
            appointment.doctorName = (doctorDoc.data() as String??['name'] ?? 'Unknown Doctor') as String?;
            appointment.doctorSpecialty = (doctorDoc.data() as String??['specialty'] ?? '') as String?;
          }

          appointments.add(appointment);
        } catch (e) {
          print('Error processing appointment: $e');
        }
      }

      appointments = _filterAppointmentsByDate(appointments);
      appointments.sort((a, b) => b.selectedDate.compareTo(a.selectedDate));

      confirmedAppointments.value = appointments;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch appointments: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<AppointmentModel> _filterAppointmentsByDate(List<AppointmentModel> appointments) {
    if (selectedFilter.value == 'all') {
      return appointments;
    }

    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (selectedFilter.value) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'thisWeek':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case 'thisMonth':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      default:
        return appointments;
    }

    return appointments.where((appointment) {
      DateTime appointmentDate = appointment.selectedDate.toDate();
      return appointmentDate.isAfter(startDate.subtract(Duration(seconds: 1))) &&
          appointmentDate.isBefore(endDate.add(Duration(seconds: 1)));
    }).toList();
  }

  List<AppointmentModel> get filteredAppointments {
    if (searchQuery.value.isEmpty) {
      return confirmedAppointments;
    }

    return confirmedAppointments.where((appointment) {
      return appointment.ownerName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          appointment.petName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (appointment.doctorName?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
          appointment.problem.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    fetchConfirmedAppointments();
  }

  Future<void> refreshAppointments() async {
    await fetchConfirmedAppointments();
  }

  double getTotalRevenue() {
    return filteredAppointments.fold(0.0, (sum, appointment) =>
    sum + (appointment.consultationFee ?? 0.0));
  }

  int getTotalAppointments() {
    return filteredAppointments.length;
  }

  Map<String, int> getAppointmentsByStatus() {
    Map<String, int> statusCount = {};
    for (var appointment in filteredAppointments) {
      statusCount[appointment.status] = (statusCount[appointment.status] ?? 0) + 1;
    }
    return statusCount;
  }
}
