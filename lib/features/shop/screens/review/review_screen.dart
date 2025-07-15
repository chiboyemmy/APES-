import 'package:cwt_ecommerce_app/common/widgets/images/t_rounded_image.dart' show TRoundedImage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/star rating/star_rating.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/review_controller.dart';
import '../../models/cart_item_model.dart';

class ProductReviewsScreen extends StatelessWidget {
  ProductReviewsScreen({super.key, required this.product});

  final ReviewController _reviewController = Get.put(ReviewController());
  final CartItemModel product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),

              // Product Image
              Center(
                child: TRoundedImage(
                  imageUrl: product.image!,
                  isNetworkImage: true,
                  height: 150,
                  width: 150,
                  backgroundColor: TColors.primary.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 24),
              // Title and Subtitle
              const Text('How was the quality of your purchase?', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Loved your outfit? Rate the outfit and share your feedback.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              // Rating Bar
              Center(
                child: Obx(
                  () => StarRating(
                    currentRating: _reviewController.rating.value,
                    onRatingChanged: (value) => _reviewController.rating.value = value,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Review Text Field
              TextField(
                onChanged: (text) => _reviewController.updateReviewText(text),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts on the fit, material, and quality...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _reviewController.submitReview(product),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
