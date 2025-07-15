import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';

import '../../../../common/widgets/products/cart/bottom_add_to_cart_widget.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/sizes.dart';
import '../../models/product_model.dart';
import 'widgets/product_attributes.dart';
import 'widgets/product_detail_image_slider.dart';
import 'widgets/product_meta_data.dart';
import 'widgets/product_review_screen.dart';
import 'widgets/rating_share_widget.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1 - Product Image Slider
            TProductImageSlider(product: product),

            /// 2 - Product Details
            Container(
              padding: const EdgeInsets.only(right: TSizes.defaultSpace, left: TSizes.defaultSpace, bottom: TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// - Rating & Share
                  TRatingAndShare(
                    rating: product.rating!.toString(),
                    reviewCount: product.reviewsCount.toString(),
                  ),

                  /// - Price, Title, Stock, & Brand
                  TProductMetaData(product: product),
                  const SizedBox(height: TSizes.spaceBtwSections / 2),

                  /// -- Attributes
                  // If Product has no variations do not show attributes as well.
                  if (product.variations != null && product.variations!.isNotEmpty) TProductAttributes(product: product),
                  if (product.variations != null && product.variations!.isNotEmpty) const SizedBox(height: TSizes.spaceBtwSections),

                  /// -- Checkout Button
                  // SizedBox(
                  //   width: TDeviceUtils.getScreenWidth(context),
                  //   child: ElevatedButton(child: const Text('Checkout'), onPressed: () => Get.to(() => const CheckoutScreen())),
                  // ),
                  // const SizedBox(height: TSizes.spaceBtwSections),

                  /// - Description
                  const TSectionHeading(title: 'Description', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  // Read more package
                  ReadMoreText(
                    parseDescription(product.description),
                    trimLines: 2,
                    colorClickableText: Colors.pink,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' Less',
                    moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// - Reviews
                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  GestureDetector(
                    onTap: () => Get.to(() => SingleProductReviewsScreen(product: product), fullscreenDialog: true),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [TSectionHeading(title: 'Reviews (${product.reviewsCount.toString()})', showActionButton: false), const Icon(Iconsax.arrow_right_3, size: 18)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TBottomAddToCart(product: product),
    );
  }
}

String parseDescription(String? jsonDescription) {
  if (jsonDescription == null) return '';

  try {
    final List<dynamic> delta = jsonDecode(jsonDescription);
    String description = '';
    for (var block in delta) {
      if (block is Map && block.containsKey('insert')) {
        description += block['insert'].toString().replaceAll('\\n', '\n');
      }
    }
    return description.trim();
  } catch (e) {
    return jsonDescription; // Fallback if parsing fails
  }
}
