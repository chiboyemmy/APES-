import 'package:cwt_ecommerce_app/features/shop/controllers/product/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/shop/models/coupon_model.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';

class TBillingAmountSection extends StatelessWidget {
  const TBillingAmountSection({super.key, required this.subTotal});

  final double subTotal;

  @override
  Widget build(BuildContext context) {
    // final dark = THelperFunctions.isDarkMode(context);
    final controller = CheckoutController.instance;

    return Obx(
      () => Column(
        children: [
          /// Coupon Code
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TTexts.couponCodeOrVouchers, style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                onPressed: () => Get.toNamed(TRoutes.coupon),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
              )
            ],
          ),

          /// -- Points
          if (controller.settingsController.settings.value.isPointBaseEnabled) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Available Points: ${controller.userController.user.value.points}", style: Theme.of(context).textTheme.bodyMedium),
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: controller.isUsingPoints.value,
                    activeTrackColor: TColors.darkerGrey,
                    onChanged: (value) {
                      controller.isUsingPoints.value = value;
                      if (value) controller.pointsDiscountAmount.value = 0.0;
                    },
                  ),
                ),
              ],
            ),
          ],

          const Divider(),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// -- Sub Total
          Row(
            children: [
              Expanded(child: Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium)),
              Text('\$${subTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),

          /// -- Shipping Fee
          if (controller.settingsController.settings.value.isTaxShippingEnabled) ...[
            Row(
              children: [
                Expanded(child: Text('Shipping Fee', style: Theme.of(context).textTheme.bodyMedium)),
                Obx(
                  () => Text('\$${controller.isShippingFree(subTotal) ? 'Free' : (controller.getShippingCost(subTotal)).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.labelLarge),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),

            /// -- Tax Fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax Fee', style: Theme.of(context).textTheme.bodyMedium),
                Text('\$${controller.getTaxAmount(subTotal).toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),

            /// Point Discount
            if (controller.isUsingPoints.value) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Points Discount', style: Theme.of(context).textTheme.bodyMedium),
                  Obx(() => Text('-\$${controller.pointsDiscountAmount.value}', style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ],

            // Coupon Discount
            if (controller.couponController.coupon.value.id.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('Coupon Discount', style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsetsDirectional.zero),
                        onPressed: () => controller.couponController.coupon.value = CouponModel.empty(),
                        child: Text('Clear', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: TColors.error)),
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        controller.couponController.coupon.value.discountType == DiscountType.percentage
                            ? "${controller.couponController.coupon.value.discountValue.toStringAsFixed(2)}%"
                            : "-\$${controller.couponController.coupon.value.discountValue.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
            const SizedBox(height: TSizes.spaceBtwItems),
          ],

          /// -- Order Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order Total', style: Theme.of(context).textTheme.titleMedium),
              Obx(() => Text('\$${controller.calculateGrandTotal(subTotal)}', style: Theme.of(context).textTheme.titleMedium)),
            ],
          ),
        ],
      ),
    );
  }
}
