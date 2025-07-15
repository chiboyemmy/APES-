import 'package:get/get.dart';

import '../../../data/repositories/brands/brand_repository.dart';
import '../../../data/repositories/product/product_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/brand_model.dart';
import '../models/product_model.dart';

class BrandController extends GetxController {
  static BrandController get instance => Get.find();

  RxBool isLoading = true.obs;
  RxList<BrandModel> allBrands = <BrandModel>[].obs;
  RxList<BrandModel> featuredBrands = <BrandModel>[].obs;
  final brandRepository = Get.put(BrandRepository());

  @override
  void onInit() {
    getFeaturedBrands();
    super.onInit();
  }

  /// -- Load Brands
  Future<void> getFeaturedBrands() async {
    try {
      // Show loader while loading Brands
      isLoading.value = true;

      // Fetch Brands from your data source (Firestore, API, etc.)
      final fetchedCategories = await brandRepository.fetchAllItems();

      // Update the brands list
      allBrands.assignAll(fetchedCategories);

      // Update the featured brands list
      featuredBrands.assignAll(allBrands.where((brand) => brand.isFeatured).take(4).toList());
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // -- Get Brands For Category
  // Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
  //   final brands = await brandRepository.fetchSingleItem(categoryId);
  //   return brands;
  // }
  // Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
  //   try {
  //     final snapshot = await brandRepository.db
  //         .collection("Brands")
  //         .where("categories", arrayContains: categoryId) // Fetch brands that have this category
  //         .get();
  //
  //     return snapshot.docs.map((doc) => BrandModel.fromDocSnapshot(doc)).toList();
  //   } catch (e) {
  //     TLoaders.errorSnackBar(title: "Error", message: e.toString());
  //     return [];
  //   }
  // }
  Future<List<BrandModel>> getBrandsForCategory(String categoryId, int limit) async {
    final brands = await brandRepository.getBrandsForCategory(categoryId, limit);
    return brands;
  }

  /// Get Brand Specific Products from your data source
  Future<List<ProductModel>> getBrandProducts(String brandId, int limit) async {
    final products = await ProductRepository.instance.getProductsForBrand(brandId, limit);
    return products;
  }

  Future<void> updateBrandView(String brandId, BrandModel brand) async {
    int view = brand.viewCount!;
    view++;
    brandRepository.updateSingleField(brandId, {"viewCount": view});
  }
}
