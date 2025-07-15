import 'package:get/get.dart';

import '../features/authentication/controllers/sign_in_controller.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    /// -- Core
    Get.lazyPut(() => SignInController());
  }
}
