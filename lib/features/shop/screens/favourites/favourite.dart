import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/loaders/animation_loader.dart';
import '../../../../common/widgets/products/product_cards/product_card_vertical.dart';
import '../../../../common/widgets/shimmers/vertical_product_shimmer.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../controllers/product/favourites_controller.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // Intercept the back button press and redirect to Home Screen
      // onPopInvoked: (value) async => Get.offAll(const HomeMenu()),
      onPopInvokedWithResult: (bool didPop, Object? result) async => await Get.offAllNamed(TRoutes.homeMenu),
      child: Scaffold(
        appBar: TAppBar(
          showActions: true,
          showSkipButton: false,
          showActionWithBadge: true,
          title: const Text("Wishlist"),
          leadingIcon: Iconsax.notification,
          actionIcon: Iconsax.add,
          actionOnPressed: () => Get.toNamed(TRoutes.homeMenu),
          leadingOnPressed: () => Get.toNamed(TRoutes.notification),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                /// Products Grid
                Obx(() {
                  return FutureBuilder(
                    future: FavouriteController.instance.favoriteProducts(),
                    builder: (_, snapshot) {
                      /// Nothing Found Widget
                      final emptyWidget = TAnimationLoaderWidget(
                        text: 'Whoops! Wishlist is Empty...',
                        animation: TImages.pencilAnimation,
                        showAction: true,
                        actionText: 'Let\'s add some',
                        onActionPressed: () => Get.offAllNamed(TRoutes.homeMenu),
                      );
                      const loader = TVerticalProductShimmer(itemCount: 6);
                      final widget = TCloudHelperFunctions.checkMultiRecordState(
                          snapshot: snapshot, loader: loader, nothingFound: emptyWidget);
                      if (widget != null) return widget;

                      final products = snapshot.data!;
                      return TGridLayout(
                        itemCount: products.length,
                        itemBuilder: (_, index) => TProductCardVertical(product: products[index]),
                      );
                    },
                  );
                }),
                SizedBox(height: TDeviceUtils.getBottomNavigationBarHeight() + TSizes.defaultSpace),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
