import 'package:al_haiwan/user/repository/bottomNav/bottomNavScreens/profile/profile_viewmodal.dart';
import 'package:get/get.dart';
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileViewModel());
  }
}
