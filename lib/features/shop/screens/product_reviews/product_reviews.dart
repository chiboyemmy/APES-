// import 'package:flutter/material.dart';
//
// import '../../../../common/widgets/appbar/appbar.dart';
// import '../../../../utils/constants/sizes.dart';
// import 'widgets/progress_indicator_and_rating.dart';
// import 'widgets/rating_star.dart';
//
// class ProductReviewsScreen extends StatelessWidget {
//   const ProductReviewsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       /// -- Appbar
//       appBar: TAppBar(title: Text('Reviews & Ratings'), showBackArrow: true),
//
//       /// -- Body
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(TSizes.defaultSpace),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// -- Reviews List
//               Text("Ratings and reviews are verified and are from people who use the same type of device that you use."),
//               SizedBox(height: TSizes.spaceBtwItems),
//
//               /// Overall Product Ratings
//               TOverallProductRating(),
//               TRatingBarIndicator(rating: 3.5),
//               Text("12,611"),
//               SizedBox(height: TSizes.spaceBtwSections),
//
//               /// User Reviews List
//               // ListView.separated(
//               //   shrinkWrap: true,
//               //   itemCount: TDummyData.productReviews.length,
//               //   physics: const NeverScrollableScrollPhysics(),
//               //   separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwSections),
//               //   itemBuilder: (_, index) => UserReviewCard(productReview: TDummyData.productReviews[index]),
//               // )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
