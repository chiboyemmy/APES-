import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_utils/common/widgets/appbar/appbar.dart';
import 'package:t_utils/utils/constants/enums.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/product/order_controller.dart';
import '../../../models/order_model.dart';
import 'widgets/addresses.dart';
import 'widgets/delivery_status.dart';
import 'widgets/order_status.dart';
import 'widgets/payment_details.dart';

class OrderDetail extends StatelessWidget {
  const OrderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());
    controller.selectedOrder.value = Get.arguments ?? OrderModel.empty();
    controller.selectedOrderId.value = Get.parameters['id'] ?? '';

    // Initialize the controller data outside the build method
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.init());

    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text("Order Details")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.md),
        child: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildOrderDetails(controller.selectedOrder.value, controller)), // If order is passed, directly display order details
      ),
    );
  }

  // A reusable method to build the order details UI
  Widget _buildOrderDetails(OrderModel order, OrderController controller) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            OrderStatusWidget(order: order),
            const SizedBox(height: TSizes.spaceBtwItems),
            OrderAddresses(order: order),
            const SizedBox(height: TSizes.spaceBtwItems),
            PaymentDetail(order: order),
            const SizedBox(height: TSizes.spaceBtwItems),
            DeliveryStatus(order: order),
            const SizedBox(height: TSizes.spaceBtwItems),
            if (order.orderStatus.name == OrderStatus.pending.name)
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => controller.cancelOrder(order), child: const Text("Cancel Order")))
          ],
        ),
      ),
    );
  }
}
