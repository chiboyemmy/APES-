import 'package:cwt_ecommerce_app/features/shop/controllers/product/checkout_controller.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/coupon/coupons_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/coupon_model.dart';

class CouponController extends GetxController {
  static CouponController get instance => Get.find();
  final Rx<CouponModel> coupon = CouponModel.empty().obs;
  RxBool isCouponToggled = false.obs;

  // Inject the repository
  final CouponRepository couponRepository = Get.put(CouponRepository());

  Future<List<CouponModel>> fetchAllItems() {
    return couponRepository.fetchAllItems();
  }

  Future<void> applyCoupon(CouponModel selectedCoupon) async {
    if (selectedCoupon.usageCount == selectedCoupon.usageLimit) {
      TLoaders.warningSnackBar(title: "Oh Snap", message: 'There is no more coupon left');
    } else {
      coupon.value = selectedCoupon;
      CheckoutController.instance.isCouponToggled.value= true;
      Get.back();
      TLoaders.successSnackBar(title: "Great", message: 'Coupon applied successfully!');
    }
  }

  Future<void> updateUsageCount(CouponModel coupon) async {
    int count = coupon.usageCount;
    count++;
    await couponRepository.updateSingleField(coupon.id, {
      'usageCount': count,
    });
  }
}
