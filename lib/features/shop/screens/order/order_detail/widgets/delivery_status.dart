import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_utils/utils/constants/enums.dart';

import '../../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../models/order_model.dart';
import 'heading_with_icon.dart';

class DeliveryStatus extends StatelessWidget {
  const DeliveryStatus({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    // final dark = THelperFunctions.isDarkMode(context);
    return TRoundedContainer(
      backgroundColor: TColors.borderSecondary.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Delivery status and tracking ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const THeadingWithIcon(title: 'Delivery Status', icon: Iconsax.truck),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: order.shippingInfo.carrier,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      TextSpan(
                        text: order.shippingInfo.trackingNumber,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: TSizes.md),
      order.orderStatus.name == OrderStatus.canceled.name ? const OrderStatusTile(
        icon: Icons.cancel,
        title: "Order Canceled",
        status:  "Completed",
        isActive: true,
        isCompleted: true,
      ):

      Column(
        children: OrderStatus.values.map((status) {
          return buildStatusTile(status,order.orderStatus);
        }).toList(),),

        ],
      ),
    );
  }



  Widget buildStatusTile(OrderStatus status,OrderStatus currentStatus) {
    // Determine if this status is completed or active
    bool isCompleted = currentStatus.index > status.index;
    bool isActive = currentStatus == status;

    switch (status) {
      case OrderStatus.pending:
        return OrderStatusTile(
          icon: Icons.hourglass_empty,
          title: "Order Placed",
          status: isCompleted ? "Completed" : "Pending",
          isActive: isActive,
          isCompleted: isCompleted,
        );
      case OrderStatus.processing:
        return OrderStatusTile(
          icon: Icons.sync,
          title: "Processing",
          status: isCompleted ? "Completed" : "In Progress",
          isActive: isActive,
          isCompleted: isCompleted,
        );
      case OrderStatus.shipped:
        return OrderStatusTile(
          icon: Icons.local_shipping,
          title: "Shipped",
          status: isCompleted ? "Completed" : "On the Way",
          isActive: isActive,
          isCompleted: isCompleted,
        );
      case OrderStatus.delivered:
        return OrderStatusTile(
          icon: Icons.home,
          title: "Delivered",
          status: isCompleted ? "Completed" : "Arrived",
          isActive: isActive,
          isCompleted: isCompleted,
        );
      case OrderStatus.canceled:
        return OrderStatusTile(
          icon: Icons.cancel,
          title: "Order Canceled",
          status: isCompleted ? "Completed" : "Canceled",
          isActive: isActive,
          isCompleted: isCompleted,
        );
      case OrderStatus.returned:
        return OrderStatusTile(
          icon: Icons.undo,
          title: "Returned",
          status: isCompleted ? "Completed" : "Returned",
          isActive: isActive,
          isCompleted: isCompleted,
        );
      case OrderStatus.refunded:
        return OrderStatusTile(
          icon: Icons.money_off,
          title: "Refunded",
          status: isCompleted ? "Completed" : "Refunded",
          isActive: isActive,
          isCompleted: isCompleted,
        );
    }
  }

}

class OrderStatusTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final bool isActive;
  final bool isCompleted;

  const OrderStatusTile({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isCompleted ? TColors.primary  : (isActive ? TColors.primary : Colors.grey),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isCompleted ? Colors.black : (isActive ? Colors.black : Colors.grey),
        ),
      ),
      subtitle: Text(
        status,
        style: TextStyle(
          color: isCompleted ? Colors.black : (isActive ? Colors.black : Colors.grey),
        ),
      ),
      trailing: isCompleted
          ? const Icon(Icons.check_circle, color: TColors.primary)
          : (isActive ? const Icon(Icons.radio_button_checked, color: TColors.primary) : null),
    );
  }
}

