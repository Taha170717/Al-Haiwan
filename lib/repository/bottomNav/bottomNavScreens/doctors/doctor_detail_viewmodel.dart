import 'package:get/get.dart';

class DoctorDetailViewModel extends GetxController {
  var selectedDay = Day(day: 'Mon', date: 21).obs;
  var selectedTime = ''.obs;

  final List<Day> days = [
    Day(day: 'Mon', date: 21),
    Day(day: 'Tue', date: 22),
    Day(day: 'Wed', date: 23),
    Day(day: 'Thu', date: 24),
    Day(day: 'Fri', date: 25),
    Day(day: 'Sat', date: 26),
  ];

  final List<String> timeSlots = [
    "08:00 AM",
    "10:00 AM",
    "11:00 AM",
    "01:00 PM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
    "07:00 PM",
    "08:00 PM",
  ];
}

class Day {
  final String day;
  final int date;
  Day({required this.day, required this.date});
}
