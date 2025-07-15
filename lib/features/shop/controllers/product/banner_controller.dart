import 'package:cwt_ecommerce_app/home_menu.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/banners/banner_repository.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/banner_model.dart';

class BannerController extends GetxController {
  final bannersLoading = false.obs;
  final carousalCurrentIndex = 0.obs;
  final bannerRepo = Get.put(BannerRepository());
  final RxList<BannerModel> banners = <BannerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  void updatePageIndicator(index) {
    carousalCurrentIndex.value = index;
  }

  /// Fetch banners from Firestore and update the 'banners' list
  Future<void> fetchBanners() async {
    try {
      // Start Loading
      bannersLoading.value = true;

      final banners = await bannerRepo.fetchAllItems();

      // Assign banners
      this.banners.assignAll(banners);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      bannersLoading.value = false;
    }
  }

  // Method to handle navigation when a banner is clicked
  void onBannerClick(BannerModel banner) {
    switch (banner.targetType) {
      case BannerTargetType.productScreen:
        // Navigate to ProductScreen with the target product ID
        if (banner.targetId != null) {
          Get.toNamed(TRoutes.productDetail, parameters: {'id': "${banner.targetId}"});
        }
        break;

      case BannerTargetType.categoryScreen:
        // Navigate to CategoryScreen with the target category ID
        if (banner.targetId != null) {
          Get.toNamed(TRoutes.category, arguments: {'id': banner.targetId});
        }
        break;

      case BannerTargetType.customUrl:
        // Open the custom URL in a web view or browser
        if (banner.customUrl != null) {
          Get.toNamed('/webview', arguments: {'url': banner.customUrl});
        }
        break;
      case BannerTargetType.brandScreen:
        // Navigate to CampaignScreen with the target campaign ID
        if (banner.targetId != null) {
          //   Get.toNamed(TRoutes.editBrand, arguments: {'id': banner.targetId});
        }
        break;

      case BannerTargetType.homeScreen:
        Get.toNamed(TRoutes.homeMenu);
        break;
      case BannerTargetType.shopScreen:
        AppScreenController.instance.selectedMenu.value = 1;
        Get.toNamed(TRoutes.homeMenu);
        break;
      case BannerTargetType.settingScreen:
        AppScreenController.instance.selectedMenu.value = 3;
        Get.toNamed(TRoutes.homeMenu);
        break;
      case BannerTargetType.favouriteScreen:
        AppScreenController.instance.selectedMenu.value = 2;
        Get.toNamed(TRoutes.homeMenu);
        break;
      case BannerTargetType.cart:
        Get.toNamed(TRoutes.cart);
        break;
      case BannerTargetType.orders:
        Get.toNamed(TRoutes.order);
        break;
      case BannerTargetType.profile:
        Get.toNamed(TRoutes.userProfile);
        break;
      case BannerTargetType.none:
        Get.toNamed(TRoutes.homeMenu);
        break;
    }
  }

  void updateClickValue(BannerModel banner) async {
    int clicks = banner.clicks;
    clicks++;
    await bannerRepo.updateSingleField(banner.id, {'clicks': clicks});
  }
}
