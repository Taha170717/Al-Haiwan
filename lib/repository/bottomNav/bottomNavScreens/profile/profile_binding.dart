import 'package:get/get.dart';
import 'profile_viewmodal.dart';
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileViewModel());
  }
}
