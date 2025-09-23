import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../doctor/models/doctor_availability_model.dart';

class DoctorDetailViewModel extends GetxController {
  var selectedDay = Rx<Day?>(null);
  var selectedTime = ''.obs;
  var availableDays = <Day>[].obs;
  var availableTimeSlots = <String>[].obs;
  var isLoading = false.obs;
  var doctorProfile = Rx<DoctorProfile?>(null);
  var selectedDate = Rx<DateTime?>(null);
  var currentMonth = DateTime.now().obs;

  bool _isProfileLoading = false;
  bool _isAvailabilityLoading = false;

  Future<void> fetchDoctorProfile(String doctorId) async {
    if (_isProfileLoading) return;

    try {
      _isProfileLoading = true;

      final profileDoc = await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .doc(doctorId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (profileDoc.exists) {
        final data = profileDoc.data() as Map<String, dynamic>;
        doctorProfile.value = DoctorProfile.fromMap(data);
      }
    } catch (e) {
      print('Error fetching doctor profile: $e');
      doctorProfile.value = null;
    } finally {
      _isProfileLoading = false;
    }
  }

  Future<void> fetchDoctorAvailability(String doctorId) async {
    if (_isAvailabilityLoading) return;

    try {
      _isAvailabilityLoading = true;
      isLoading.value = true;
      print("[v0] Starting to fetch availability for doctor: $doctorId");

      final availabilityDoc = await FirebaseFirestore.instance
          .collection('doctor_availability')
          .doc(doctorId)
          .get(const GetOptions(source: Source.serverAndCache));

      print("[v0] Document exists: ${availabilityDoc.exists}");

      if (availabilityDoc.exists) {
        final data = availabilityDoc.data() as Map<String, dynamic>;
        print("[v0] Raw Firestore data: $data");

        List<Day> days = [];
        List<String> timeSlots = [];

        if (data.isNotEmpty) {
          if (data.containsKey('weeklyAvailability')) {
            print("[v0] Found 'weeklyAvailability' field");
            final weeklyAvailability = data['weeklyAvailability'] as List<dynamic>?;
            if (weeklyAvailability != null) {
              _parseWeeklyAvailabilityData(weeklyAvailability, days, timeSlots);
            }
          } else if (data.containsKey('schedule')) {
            print("[v0] Found 'schedule' field");
            final schedule = data['schedule'] as Map<String, dynamic>?;
            if (schedule != null) {
              _parseScheduleData(schedule, days, timeSlots);
            }
          } else if (data.containsKey('availableDays')) {
            print("[v0] Found 'availableDays' field");
            final availableDaysList = data['availableDays'] as List<dynamic>?;
            if (availableDaysList != null) {
              _parseDirectDaysData(availableDaysList, days, timeSlots, data);
            }
          } else if (data.containsKey('days')) {
            print("[v0] Found 'days' field");
            final daysList = data['days'] as List<dynamic>?;
            if (daysList != null) {
              _parseDirectDaysData(daysList, days, timeSlots, data);
            }
          } else {
            print("[v0] No standard fields found, trying flat structure");
            _parseFlatStructure(data, days, timeSlots);
          }
        }

        print("[v0] Parsed ${days.length} days: ${days.map((d) => d.day).toList()}");
        print("[v0] Parsed ${timeSlots.length} time slots: $timeSlots");

        availableDays.value = days;
        availableTimeSlots.value = timeSlots;
        selectedDay.value = days.isNotEmpty ? days.first : null;

        if (days.isNotEmpty && timeSlots.isNotEmpty) {
          print("[v0] Successfully loaded availability data");
        } else {
          print("[v0] No valid availability data found in Firebase");
        }
      } else {
        print("[v0] No availability document found for doctor $doctorId");
        availableDays.value = [];
        availableTimeSlots.value = [];
        selectedDay.value = null;
      }
    } catch (e) {
      print("[v0] Error fetching doctor availability: $e");
      print("[v0] Error type: ${e.runtimeType}");
      availableDays.value = [];
      availableTimeSlots.value = [];
      selectedDay.value = null;
    } finally {
      _isAvailabilityLoading = false;
      isLoading.value = false;
    }
  }

  void _parseScheduleData(Map<String, dynamic> schedule, List<Day> days, List<String> timeSlots) {
    schedule.forEach((dayName, dayData) {
      if (dayData is Map<String, dynamic> && dayData['isAvailable'] == true) {
        int dayIndex = _getDayIndex(dayName);
        int date = 21 + dayIndex;
        days.add(Day(day: dayName, date: date));

        if (dayData['timeSlots'] != null) {
          List<dynamic> slots = dayData['timeSlots'];
          for (var slot in slots) {
            if (slot is Map<String, dynamic> && slot['isAvailable'] == true) {
              String timeSlot = "${slot['startTime']} - ${slot['endTime']}";
              if (!timeSlots.contains(timeSlot)) {
                timeSlots.add(timeSlot);
              }
            }
          }
        }
      }
    });
  }

  void _parseDirectDaysData(List<dynamic> availableDays, List<Day> days, List<String> timeSlots, Map<String, dynamic> data) {
    for (int i = 0; i < availableDays.length; i++) {
      String dayName = availableDays[i].toString();
      int date = 21 + i;
      days.add(Day(day: dayName, date: date));
    }

    if (data['timeSlots'] != null) {
      List<dynamic> slots = data['timeSlots'];
      for (var slot in slots) {
        timeSlots.add(slot.toString());
      }
    } else if (data['availableTimeSlots'] != null) {
      List<dynamic> slots = data['availableTimeSlots'];
      for (var slot in slots) {
        timeSlots.add(slot.toString());
      }
    }
  }

  void _parseFlatStructure(Map<String, dynamic> data, List<Day> days, List<String> timeSlots) {
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (String dayName in dayNames) {
      if (data[dayName] != null) {
        var dayData = data[dayName];
        if (dayData is bool && dayData == true) {
          int dayIndex = _getDayIndex(dayName);
          int date = 21 + dayIndex;
          days.add(Day(day: dayName, date: date));
        } else if (dayData is Map<String, dynamic> && dayData['available'] == true) {
          int dayIndex = _getDayIndex(dayName);
          int date = 21 + dayIndex;
          days.add(Day(day: dayName, date: date));
        }
      }
    }

    List<String> possibleTimeFields = ['timeSlots', 'availableTimeSlots', 'slots', 'times'];
    for (String field in possibleTimeFields) {
      if (data[field] != null && data[field] is List) {
        List<dynamic> slots = data[field];
        for (var slot in slots) {
          timeSlots.add(slot.toString());
        }
        break;
      }
    }
  }

  void _parseWeeklyAvailabilityData(List<dynamic> weeklyAvailability, List<Day> days, List<String> timeSlots) {
    print("[v0] Parsing weeklyAvailability with ${weeklyAvailability.length} entries");

    for (var dayData in weeklyAvailability) {
      if (dayData is Map<String, dynamic>) {
        String dayName = dayData['day']?.toString() ?? '';
        bool isAvailable = dayData['isAvailable'] == true;

        print("[v0] Processing day: $dayName, available: $isAvailable");

        if (isAvailable && dayName.isNotEmpty) {
          int dayIndex = _getDayIndex(dayName);
          int date = 21 + dayIndex;
          days.add(Day(day: dayName, date: date));

          // Parse time slots for this day
          if (dayData['timeSlots'] != null) {
            List<dynamic> slots = dayData['timeSlots'] as List<dynamic>;
            print("[v0] Found ${slots.length} time slots for $dayName");

            for (var slot in slots) {
              if (slot is Map<String, dynamic> && slot['isAvailable'] == true) {
                String startTime = slot['startTime']?.toString() ?? '';
                String endTime = slot['endTime']?.toString() ?? '';
                if (startTime.isNotEmpty && endTime.isNotEmpty) {
                  String timeSlot = "$startTime - $endTime";
                  if (!timeSlots.contains(timeSlot)) {
                    timeSlots.add(timeSlot);
                    print("[v0] Added time slot: $timeSlot");
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  int _getDayIndex(String dayName) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days.indexOf(dayName);
  }

  void updateTimeSlotsForDay(Day day) async {
    try {
      selectedDay.value = day;
    } catch (e) {
      print('Error updating time slots: $e');
    }
  }

  void previousMonth() {
    currentMonth.value = DateTime(currentMonth.value.year, currentMonth.value.month - 1);
  }

  void nextMonth() {
    currentMonth.value = DateTime(currentMonth.value.year, currentMonth.value.month + 1);
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    String dayName = _getDayName(date.weekday);
    Day? matchingDay = availableDays.firstWhereOrNull((day) => day.day == dayName);
    if (matchingDay != null) {
      selectedDay.value = matchingDay;
      updateTimeSlotsForDay(matchingDay);
    }
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  bool isDateAvailable(DateTime date) {
    String dayName = _getDayName(date.weekday);
    return availableDays.any((day) => day.day == dayName);
  }

  @override
  void onClose() {
    selectedDay.close();
    selectedTime.close();
    availableDays.close();
    availableTimeSlots.close();
    isLoading.close();
    doctorProfile.close();
    selectedDate.close();
    currentMonth.close();
    super.onClose();
  }
}

class Day {
  final String day;
  final int date;
  Day({required this.day, required this.date});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Day && other.day == day && other.date == date;
  }

  @override
  int get hashCode => day.hashCode ^ date.hashCode;
}
