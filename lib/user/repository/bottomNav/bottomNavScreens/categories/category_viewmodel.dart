import 'package:get/get.dart';
import 'category_model.dart';

class CategoryViewModel extends GetxController {
  var categories = <Category>[
    Category(name: "Deworming", iconPath: "assets/icons/deworming.png"),
    Category(name: "Vaccines", iconPath: "assets/icons/injection.png"),
    Category(name: "Pain Relief", iconPath: "assets/icons/leech.png"),
    Category(name: "Skin & Coat", iconPath: "assets/icons/spa.png"),
    Category(name: "Eye/Ear Drops", iconPath: "assets/icons/eye_ear.png"),
    Category(name: "Supplements", iconPath: "assets/icons/supplements.png"),
    Category(name: "Pet Food", iconPath: "assets/icons/pet_food.png"),
    Category(name: "Grooming", iconPath: "assets/icons/grooming.png"),
    Category(name: "Toys", iconPath: "assets/icons/toys.png"),
    Category(name: "Cleaning", iconPath: "assets/icons/cleaning.png"),
  ].obs;
}
