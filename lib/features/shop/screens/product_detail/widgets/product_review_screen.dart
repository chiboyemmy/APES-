import 'package:cwt_ecommerce_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cwt_ecommerce_app/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_utils/common/widgets/appbar/appbar.dart';

import '../../../../../common/widgets/shimmers/review_shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/review_controller.dart';
import '../../../models/product_review_model.dart';
import 't_review_card.dart';

class SingleProductReviewsScreen extends StatelessWidget {
  const SingleProductReviewsScreen({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewController());
    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text("All Reviews"),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: FutureBuilder<List<ReviewModel>>(
            future: controller.fetchReview(product.id),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SingleChildScrollView(
                  child: Column(
                    children: List.generate(3, (index) => const TReviewCardShimmer()), // Show shimmer cards while loading
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No reviews available'));
              }
              final data = snapshot.data;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // StarRating(currentRating: product.rating!.round()),
                    // const SizedBox(height: TSizes.spaceBtwItems),
                    //
                    // Text('${product.rating!.round()}/5', style: Theme.of(context).textTheme.headlineLarge),
                    // Text(
                    //   'Based on ${product.rating!.round()} Reviews',
                    //   style: const TextStyle(color: Color(0xFF979797), fontSize: 14, fontFamily: 'Montserrat', fontWeight: FontWeight.w400),
                    // ),
                    // const SizedBox(height: TSizes.sm),

                    // Text('Most Helpful Reviews', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 16)),
                    // const SizedBox(height: TSizes.sm),

                    ListView.separated(
                      itemCount: data!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final review = data[index];
                        return TRoundedContainer(
                          backgroundColor: TColors.lightContainer,
                          child: ReviewCard(
                            reviewModel: review,
                          ),
                        );
                      }, separatorBuilder: (BuildContext context, int index) => const SizedBox(height: TSizes.spaceBtwItems),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
