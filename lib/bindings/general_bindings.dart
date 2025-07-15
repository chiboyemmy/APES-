import 'package:cwt_ecommerce_app/features/personalization/controllers/settings_controller.dart';
import 'package:cwt_ecommerce_app/features/personalization/controllers/user_controller.dart';
import 'package:cwt_ecommerce_app/features/shop/controllers/coupon_controller.dart';
import 'package:get/get.dart';

import '../data/services/notifications/notification_service.dart';
import '../features/authentication/controllers/otp_controller.dart';
import '../features/personalization/controllers/address_controller.dart';
import '../features/personalization/controllers/notifcation_controller.dart';
import '../features/shop/controllers/product/images_controller.dart';
import '../features/shop/controllers/product/variation_controller.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    /// -- Core
    Get.put(NetworkManager());

    /// -- Product
    // Get.put(CheckoutController());
    Get.put(VariationController());
    Get.put(ImagesController());

    /// -- Other
    Get.put(AddressController());
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => VariationController());
    Get.lazyPut(() => CouponController());
    Get.lazyPut(() => UserController());
    Get.lazyPut(() => OTPController());
    Get.put(TNotificationService());
    Get.lazyPut(() => NotificationController(), fenix: true);
  }
}
