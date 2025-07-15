import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../models/order_model.dart';
import 'heading_with_icon.dart';

class PaymentDetail extends StatelessWidget {
  const PaymentDetail({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      backgroundColor: TColors.borderSecondary.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const THeadingWithIcon(title: 'Payment Details', icon: Iconsax.bank),
          const SizedBox(height: TSizes.spaceBtwItems),

          buildRow("Subtotal (${order.itemCount} items):", "\$${order.totalAmount}", context),
          buildRow("Delivery Fee:", "\$${order.shippingAmount}", context),
          buildRow("Tax Amount:", "\$${order.taxAmount}", context),
          const Divider(thickness: 1.0),
          buildRow("Total :", "\$${order.totalAmount}", context),
          const SizedBox(height: TSizes.xs),
          buildRow("Payment Method:", "Cash on Delivery", context),
        ],
      ),
    );
  }

  Widget buildRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical space between rows
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(value, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.right),
        ],
      ),
    );
  }
}
