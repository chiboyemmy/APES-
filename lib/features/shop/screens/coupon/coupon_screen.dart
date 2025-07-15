import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_utils/common/widgets/appbar/appbar.dart';

import '../../../../common/widgets/loaders/animation_loader.dart';
import '../../../../common/widgets/shimmers/vertical_product_shimmer.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../controllers/coupon_controller.dart';
import 'coupon_card.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  final String currency = '\$';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponController());
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Coupon'),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: FutureBuilder(
          future: controller.fetchAllItems(),
          builder: (context, snapshot) {
            const emptyWidget = TAnimationLoaderWidget(
              text: 'Whoops! There is no Coupon...',
              animation: TImages.acerlogo,
              showAction: false,
            );
            const loader = TVerticalProductShimmer(itemCount: 6);
            final widget = TCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot, loader: loader, nothingFound: emptyWidget);
            if (widget != null) return widget;
            final coupons = snapshot.data;
            return ListView.separated(
              itemCount: coupons!.length,
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                // const circle = true;
                return Column(
                  children: [
                    CouponCard(coupon: coupon),
                  ],
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: TSizes.spaceBtwItems),
            );
          },
        ),
      ),
    );
  }
}

class HalfCircle extends StatelessWidget {
  const HalfCircle({
    super.key,
    required this.isTop,
  });

  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: 18,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isTop
              ? const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
        ),
      ),
    );
  }
}

class Coupon {
  final String code;
  final double discount;
  final bool isPercentage;
  final double saved;
  final String description;
  final double? minimumOrderAmount;
  final double? uptoDiscount;

  Coupon({
    required this.code,
    required this.discount,
    required this.isPercentage,
    required this.saved,
    required this.description,
    this.minimumOrderAmount,
    this.uptoDiscount,
  });
}
