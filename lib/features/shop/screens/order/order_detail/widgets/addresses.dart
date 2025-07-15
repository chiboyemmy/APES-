
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../models/order_model.dart';
import 'heading_with_icon.dart';

class OrderAddresses extends StatelessWidget {
  const OrderAddresses({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      backgroundColor: TColors.borderSecondary.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const THeadingWithIcon(title: 'Shipping Address', icon: Iconsax.location_tick),
          const SizedBox(height: TSizes.spaceBtwItems),
          buildRow("Name:", order.userName, context),
          buildRow("Email:", order.userEmail, context),
          buildRow("Address:", order.shippingAddress.toString(), context),

          const SizedBox(height: TSizes.spaceBtwItems),
          const Divider(),
          const SizedBox(height: TSizes.spaceBtwItems),

          const THeadingWithIcon(title: 'Billing Address', icon: Iconsax.location),
          const SizedBox(height: TSizes.spaceBtwItems),

          if(order.billingAddressSameAsShipping)
            const Text('Billing Address is Same as Shipping Address'),
          if(!order.billingAddressSameAsShipping) buildRow("Name:", order.userName, context),
          if(!order.billingAddressSameAsShipping) buildRow("Email:", order.userEmail, context),
          if(!order.billingAddressSameAsShipping) buildRow("Address:", order.shippingAddress.toString(), context),
        ],
      ),
    );
  }

  Widget buildRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical space between rows
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Expanded(
            flex: 3,
            child: Text(value, textAlign: TextAlign.right, style: Theme.of(context).textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}
