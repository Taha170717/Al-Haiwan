import 'package:get/get.dart';

class Doctor {
  final String name;
  final String speciality;
  final String image;
  final double rating;
  final String distance;

  Doctor({
    required this.name,
    required this.speciality,
    required this.image,
    required this.rating,
    required this.distance,
  });
}

class DoctorListViewModel extends GetxController {
  var doctors = <Doctor>[
    Doctor(
      name: "Dr. Marcus Horizon",
      speciality: "Veterinarian",
      image: "assets/images/doc1.png",
      rating: 4.7,
      distance: "1200m",
    ),
    Doctor(
      name: "Dr. Maria Elena",
      speciality: "Veterinarian",
      image: "assets/images/doc2.png",
      rating: 4.7,
      distance: "600m",
    ),
    Doctor(
      name: "Dr. Stefi Jessi",
      speciality: "Veterinarian",
      image: "assets/images/doc3.png",
      rating: 4.7,
      distance: "1400m",
    ),
    Doctor(
      name: "Dr. Gerty Cori",
      speciality: "Veterinarian",
      image: "assets/images/doc4.png",
      rating: 4.7,
      distance: "1300m",
    ),
  ].obs;
}
