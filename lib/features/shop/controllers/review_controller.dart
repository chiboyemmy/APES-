import 'package:get/get.dart';

import '../../../common/widgets/success_screen/success_screen.dart';
import '../../../data/repositories/product/product_repository.dart';
import '../../../data/repositories/reviews/reviews_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/cart_item_model.dart';
import '../models/product_review_model.dart';

class ReviewController extends GetxController {
  static ReviewController get instance => Get.find();

  // Inject the repository
  final ReviewRepository reviewRepository = Get.put(ReviewRepository());
  final ProductRepository productRepository = Get.put(ProductRepository());

  Future<List<ReviewModel>> fetchReview(String productId) {
    return reviewRepository.fetchAllItemByProductId(productId);
  }

  RxInt rating = 0.obs;
  var reviewText = ''.obs;
  final userController = Get.put(UserController());

  void updateReviewText(String text) {
    reviewText.value = text;
  }

  Future<void> submitReview(CartItemModel item) async {
    // Check rating and review
    if (rating.value == 0 && reviewText.value.isEmpty) {
      TLoaders.warningSnackBar(title: "Oh Snap", message: 'Please write a review or give rating');
      return;
    }

    final review = ReviewModel(
        id: '',
        productId: item.productId,
        userId: userController.user.value.id,
        userName: userController.user.value.fullName,
        rating: rating.value.toDouble(),
        productImage: item.image!,
        productName: item.title,
        userProfileImage: userController.user.value.profilePicture,
        reviewText: reviewText.value,
        mediaUrls: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());

    // Save the review to Firestore
    await reviewRepository.addItem(review);

    // Re‑fetch the product so you have the latest values
    final product = await productRepository.getSingleProduct(item.productId);

    // Compute the new aggregates
    final oldCount   = product.ratingCount ?? 0;
    final oldAvg     = product.rating   ?? 0.0;
    final newCount   = oldCount + 1;
    final newRating  = rating.value.toDouble();

    // ⏺ New average = (oldAvg * oldCount + newRating) / newCount
    final updatedAvg = (oldAvg * oldCount + newRating) / newCount;

    // Update your product model
    product
      ..ratingCount   = newCount
      ..reviewsCount  = newCount
      ..rating        = updatedAvg
      ..lastReviews   = [review, ...?product.lastReviews]; // prepend to keep most recent first

    // Persist it back to Firestore
    await productRepository.updateProduct(product);

    // ProductController.instance.featuredProducts.value = product;;

    // Update point based on rating
    if (rating.value != 0) {
      await userController.updateUserPointsPerRating();
    }

    // Update point based on review
    if (reviewText.value.isEmpty) {
      await userController.updateUserPointsPerReview();
    }

    TLoaders.successSnackBar(title: 'Success', message: 'Review submitted successfully');

    // Show Success screen
    Get.off(() => SuccessScreen(
          image: TImages.orderCompletedAnimation,
          title: 'Review Submitted!',
          subTitle: 'Your review submitted successfully!',
          onPressed: () => Get.back(),
        ));
  }
}
