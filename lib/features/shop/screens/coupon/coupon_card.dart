import 'package:flutter/material.dart';
import 'package:t_utils/common/widgets/containers/t_container.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/coupon_controller.dart';
import '../../models/coupon_model.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({super.key, required this.coupon});

  final CouponModel coupon;

  @override
  Widget build(BuildContext context) {
    final controller = CouponController.instance;
    final dark = THelperFunctions.isDarkMode(context);
    final bool hasUsageLeft = (coupon.usageLimit - coupon.usageCount) > 0;
    return TContainer(
      showBorder: true,
      borderColor: TColors.grey,
      backgroundColor: TColors.lightContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Coupon Code and Redeem Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Discount
                  Text(
                    coupon.discountType == DiscountType.percentage
                        ? "Save ${coupon.discountValue.toStringAsFixed(2)}%"
                        : "Save \$${coupon.discountValue.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: TColors.primary),
                  ),

                  /// Code
                  Text(
                    coupon.code.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: hasUsageLeft ? coupon.isActive ? () => controller.applyCoupon(coupon) : null : null,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    backgroundColor: hasUsageLeft ? TColors.primary : TColors.grey),
                child: const Text("Redeem"),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),

          /// Description
          Text(coupon.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: dark ? TColors.grey : TColors.black)),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Usage Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(coupon.usageLimit - coupon.usageCount).floor()} Left",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: TColors.error),
              ),

              /// Validity Period
              if (coupon.startDate != null && coupon.endDate != null)
                Text(
                  "Valid until ${THelperFunctions.getFormattedDate(coupon.endDate!)}",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: dark ? TColors.grey : TColors.black),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
