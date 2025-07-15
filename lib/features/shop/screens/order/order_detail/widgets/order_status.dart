import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../../common/widgets/images/t_circular_image.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../models/order_model.dart';
import '../../../review/review_screen.dart';
import 'heading_with_icon.dart';

class OrderStatusWidget extends StatelessWidget {
  const OrderStatusWidget({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    // final dark = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const THeadingWithIcon(title: 'Order Summary', icon: Iconsax.shopping_bag),
        const SizedBox(height: TSizes.spaceBtwItems),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Order ID:", style: Theme.of(context).textTheme.bodyLarge),
            Text(order.id, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: TSizes.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Placed on:", style: Theme.of(context).textTheme.bodyLarge),
            Text(order.formattedOrderDate, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: TSizes.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Grand Total:", style: Theme.of(context).textTheme.bodyLarge),
            Text('\$${order.totalAmount}', style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: TSizes.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Order Status:", style: Theme.of(context).textTheme.bodyLarge),
            TRoundedContainer(
              padding: const EdgeInsets.symmetric(vertical: TSizes.sm / 2, horizontal: TSizes.sm),
              backgroundColor: (THelperFunctions.getColor(order.orderStatus.name) ?? TColors.primary).withValues(alpha: 0.1),
              child: Text(
                order.orderStatus.name[0].toUpperCase() + order.orderStatus.name.substring(1),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: THelperFunctions.getColor(order.orderStatus.name)),
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// Cart Items
        const THeadingWithIcon(title: 'Items', icon: Iconsax.shopping_cart),
        const SizedBox(height: TSizes.spaceBtwItems),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
          itemBuilder: (_, index) {
            final item = order.products[index];

            return TRoundedContainer(
              showBorder: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image or Icon
                  item.image != null && item.image!.isNotEmpty
                      ? TCircularImage(
                          backgroundColor: TColors.primary.withValues(alpha: 0.3),
                          isNetworkImage: true,
                          image: item.image!,
                        )
                      : const Icon(Iconsax.receipt_item, size: 40),

                  const SizedBox(width: 12),

                  // Product Details (Title, Price, Quantity)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: THelperFunctions.screenWidth() / 2.2,
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '\$${item.totalAmount}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Unit Price and Quantity
                        Row(
                          children: [
                            Text(
                              'Unit Price: \$${item.price.toStringAsFixed(1)}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems / 2),
                            Text(
                              'Quantity: ${item.quantity}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),

                        // Add Review Product Button
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => Get.to(ProductReviewsScreen(product: item)),
                          icon: const Icon(Iconsax.star, size: 14),
                          label: const Text("Review Product"),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: TSizes.spaceBtwSections),
      ],
    );
  }
}
