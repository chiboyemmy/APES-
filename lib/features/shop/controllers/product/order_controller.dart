import 'package:cwt_ecommerce_app/features/shop/controllers/product/product_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:t_utils/utils/constants/enums.dart';

import '../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../data/repositories/order/order_repository.dart';
import '../../../../data/services/notifications/notification_service.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/controllers/address_controller.dart';
import '../../../personalization/controllers/settings_controller.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../models/coupon_model.dart';
import '../../models/order_activity.dart';
import '../../models/order_model.dart';
import '../../models/shipping_model.dart';
import '../coupon_controller.dart';
import 'cart_controller.dart';
import 'checkout_controller.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  // Order Details Values

  final isLoading = false.obs;
  final loadingOrders = false.obs;
  Rx<OrderModel> selectedOrder = OrderModel.empty().obs;
  final selectedOrderId = ''.obs;

  /// Variables
  var selectedMethod = 0.obs;
  final orders = <OrderModel>[].obs;

  final cartController = CartController.instance;
  final addressController = AddressController.instance;
  final checkoutController = Get.put(CheckoutController());
  final couponController = Get.put(CouponController());
  final orderRepository = Get.put(OrderRepository());
  final userController = Get.put(UserController());
  final settingController = Get.put(SettingsController());

  @override
  void onInit() {
    super.onInit();
    fetchUserOrders();
  }

  /// Init Data
  Future<void> init() async {
    try {
      isLoading.value = true;
      // Fetch record if argument was null
      if (selectedOrder.value.id.isEmpty) {
        if (selectedOrderId.value.isEmpty) {
          Get.back();
        } else {
          selectedOrder.value = await orderRepository.fetchSingleOrder(selectedOrderId.value);

          if (selectedOrder.value.id.isEmpty) Get.back();
        }
      }
    } catch (e) {
      if (selectedOrder.value.id.isEmpty) {
        Get.back();
      } else {
        TLoaders.errorSnackBar(title: 'Oh Snap', message: 'Unable to fetch Order details. $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectMethod(int index) {
    selectedMethod.value = index;
  }

  /// Fetch user's order history
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      loadingOrders.value = true;
      final userOrders = await orderRepository.fetchUserOrders();
      orders.addAll(userOrders);
      return userOrders;
    } catch (e) {
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    } finally {
      loadingOrders.value = false;
    }
  }

  Future<OrderModel> fetchSingleOrder(String id) async {
    return await orderRepository.fetchSingleOrder(id);
  }

  /// Method for order processing
  void processOrder(double subTotal) async {
    try {
      if (addressController.selectedAddress.value.id.isEmpty) {
        TLoaders.warningSnackBar(title: 'Address Required', message: 'Please Add Address in order to proceed.');
        return;
      }
      // Start Loader
      TFullScreenLoader.openLoadingDialog('Processing your order', TImages.pencilAnimation);

      if (userController.user.value.id.isEmpty) return;

      if (addressController.billingSameAsShipping.isFalse) {
        if (addressController.selectedBillingAddress.value.id.isEmpty) {
          TLoaders.warningSnackBar(title: 'Billing Address Required', message: 'Please add Billing Address in order to proceed.');
          return;
        }
      }
      // Get User Token
      final token = await TNotificationService.getToken();

      final shipping = ShippingInfo(
        carrier: '',
        trackingNumber: UniqueKey().toString(),
        shippingStatus: ShippingStatus.pending,
        shippingMethod: ShippingMethod.express,
      );

      final activity = OrderActivity(
        activityType: ActivityType.orderCreated,
        activityDate: DateTime.now(),
        performedBy: Role.user.name,
        description: "Order created Successfully",
      );

      final totalAmount = double.parse(checkoutController.calculateGrandTotal(subTotal).toStringAsFixed(2));
      final shippingAmount = SettingsController.instance.settings.value.isTaxShippingEnabled ? checkoutController.getShippingCost((subTotal - checkoutController.calculateTotalDiscount(subTotal)).clamp(0.0, double.infinity)): 0.0;
      final taxAmount = SettingsController.instance.settings.value.isTaxShippingEnabled ? checkoutController.getTaxAmount(subTotal): 0.0;
      final pointsUsed = checkoutController.isUsingPoints.value ? checkoutController.pointsDiscountAmount.value.toInt() : 0;
      // Add Details
      final order = OrderModel(
        docId: '',
        id: UniqueKey().toString(),
        userId: userController.user.value.id,
        userName: userController.user.value.fullName,
        userEmail: userController.user.value.email,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        shippingAddress: addressController.selectedAddress.value,
        products: cartController.cartItems,
        paymentStatus: PaymentStatus.unpaid,
        orderStatus: OrderStatus.pending,
        shippingInfo: shipping,
        activities: [activity],
        itemCount: cartController.cartItems.length,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        shippingAmount: shippingAmount,
        taxAmount: taxAmount,
        billingAddress: null,
        billingAddressSameAsShipping: true,
        userDeviceToken: token,
        subTotal: subTotal,
        coupon: couponController.coupon.value,
        taxRate: settingController.settings.value.taxRate,
        couponDiscountAmount: couponController.coupon.value.discountValue,
        pointsUsed: pointsUsed,
        pointsDiscountAmount: checkoutController.pointsDiscountAmount.value,
        totalDiscountAmount: checkoutController.calculateTotalDiscount(subTotal),
      );

      // Save the order to Firestore
      await orderRepository.saveOrder(order, userController.user.value.id);

      // Update coupon count if applied
      if (couponController.coupon.value.id.isNotEmpty) {
        couponController.updateUsageCount(couponController.coupon.value);
      }

      if (checkoutController.isUsingPoints.value) {
        // Update user point as used by user for purchase
        await userController.updateUserPointsUsedForPurchase(checkoutController.pointsDiscountAmount.value);
      }
      // Update user point
      await userController.updateUserPointsPerPurchase(totalAmount);

      // Update user order count
      await userController.updateUserOrderCount();

      /// Update retailer order count?

      // Once the order placed, update Stock of each item
      final productController = Get.put(ProductController());

      for (var product in cartController.cartItems) {
        await productController.updateProductStock(product.productId, product.quantity, product.variationId);
      }

      // Update the cart status
      cartController.clearCart();

      // Update Coupon
      couponController.coupon.value = CouponModel.empty();

      // Update orders list
      orders.add(order);

      // Create and add the notification using the existing `addNotification` method
      TNotificationService.instance.addNotification(
        RemoteMessage(
          messageId: UniqueKey().toString(),
          notification: RemoteNotification(
            title: 'Order Placed Successfully',
            body: 'Your order #${order.id} has been successfully placed. We\'ll notify you once it\'s shipped.',
          ),
          data: {
            'route': TRoutes.orderDetail,
            'id': order.id,
          },
        ),
        route: "${TRoutes.orderDetail}/${order.id}",
        routeId: order.id,
      );

      // Show Success screen
      Get.off(() => SuccessScreen(
            image: TImages.orderCompletedAnimation,
            title: 'Order Success!',
            subTitle: 'Your item will be shipped soon!',
            onPressed: () => Get.offAllNamed(TRoutes.homeMenu),
          ));
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Method for cancelling order
  Future<void> cancelOrder(OrderModel order) async {
    await orderRepository.cancelOrder(order);
    TLoaders.successSnackBar(title: "Oh Snap", message: 'order cancelled ');
    selectedOrder.refresh();
  }
}
