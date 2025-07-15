import 'package:cwt_ecommerce_app/features/shop/controllers/product/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../common/widgets/products/cart/billing_amount_section.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/controllers/address_controller.dart';
import '../../controllers/product/cart_controller.dart';
import '../../controllers/product/order_controller.dart';
import '../cart/widgets/cart_items.dart';
import 'widgets/billing_address_section.dart';
import 'widgets/billing_payment_section.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutController = Get.put(CheckoutController());
    final cartController = CartController.instance;
    final addressController = AddressController.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) => addressController.allUserAddresses());
    final subTotal = cartController.totalCartPrice.value;
    final orderController = Get.put(OrderController());
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(
        showActions: true,
        showBackArrow: true,
        showSkipButton: false,
        title: const Text("CheckOut"),
        actionIcon: Iconsax.notification,
        actionOnPressed: () => Get.toNamed(TRoutes.notification),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// -- Items in Cart
              const TCartItems(showAddRemoveButtons: false),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// -- Billing Section
              TRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.black : TColors.white,
                child: Column(
                  children: [
                    /// Pricing
                    TBillingAmountSection(subTotal: subTotal),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Divider
                    const Divider(),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Payment Methods
                    const TBillingPaymentSection(),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Address
                    const TAddressSection(isBillingAddress: false),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Divider
                    const Divider(),

                    /// Address Checkbox
                    Obx(
                      () => CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text('Billing Address is Same as Shipping Address',
                            style: Theme.of(context).textTheme.labelLarge),
                        value: addressController.billingSameAsShipping.value,
                        onChanged: (value) => addressController.billingSameAsShipping.value = value ?? true,
                      ),
                    ),

                    /// Divider
                    Obx(() => !addressController.billingSameAsShipping.value ? const Divider() : const SizedBox.shrink()),

                    /// Shipping Address
                    Obx(() => !addressController.billingSameAsShipping.value
                        ? const TAddressSection(isBillingAddress: true)
                        : const SizedBox.shrink()),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),

      /// -- Checkout Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: subTotal > 0
                ? () => orderController.processOrder(subTotal)
                : () => TLoaders.warningSnackBar(title: 'Empty Cart', message: 'Add items in the cart in order to proceed.'),
            child: Obx(() => Text('Checkout \$${checkoutController.calculateGrandTotal(subTotal).toStringAsFixed(2)}')),
          ),
        ),
      ),
    );
  }
}
