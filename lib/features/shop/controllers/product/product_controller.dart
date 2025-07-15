import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/product/product_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/product_model.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  var selectedSize = 'M'.obs;
  var selectedColor = Colors.black.obs;

  // Function to update size
  void updateSize(String size) {
    selectedSize.value = size;
  }

  // Function to update color
  void updateColor(Color color) {
    selectedColor.value = color;
  }

  final isLoading = false.obs;
  var selectedChip = 'Trending'.obs;
  final productRepository = Get.put(ProductRepository());
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  RxList<ProductModel> mostViewedProducts = <ProductModel>[].obs;
  RxList<ProductModel> bestSellerProducts = <ProductModel>[].obs;

  /// -- Initialize Products from your backend
  @override
  void onInit() {
    fetchFeaturedProducts();
    fetchMostViewedProducts();
    super.onInit();
  }

  void selectChip(String chipName) {
    selectedChip.value = chipName;
  }

  // Method to get the appropriate product list based on selected chip
  List<ProductModel> get selectedProductList {
    switch (selectedChip.value) {
      case 'Most Viewed':
        return mostViewedProducts;
      case 'Best Sellers':
        return bestSellerProducts;
      case 'Trending':
        return featuredProducts;
      default:
        return bestSellerProducts;
    }
  }

  /// Fetch Featured Products using Stream so, any change can immediately take effect.
  void fetchFeaturedProducts() async {
    try {
      // Show loader while loading Products
      isLoading.value = true;

      // Fetch Products
      final products = await productRepository.getFeaturedProducts();

      // Assign Products
      featuredProducts.assignAll(products);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch Most Viewed Products using Stream so, any change can immediately take effect.
  void fetchMostViewedProducts() async {
    try {
      // Show loader while loading Products
      isLoading.value = true;

      // Fetch Products
      final products = await productRepository.getAllProducts();

      // Sort products by viewCount in descending order
      products.sort((a, b) => b.views!.compareTo(a.views!));

      // Assign Products
      mostViewedProducts.assignAll(products);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Get the product price or price range for variations.
  String getProductPrice(ProductModel product) {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;

    // If no variations exist, return the simple price or sale price
    if (product.productType == ProductType.simple || product.variations!.isEmpty) {
      return (product.salePrice! > 0.0 ? product.salePrice : product.price).toString();
    } else {
      // Calculate the smallest and largest prices among variations
      for (var variation in product.variations!) {
        // Determine the price to consider (sale price if available, otherwise regular price)
        double priceToConsider = variation.salePrice > 0.0 ? variation.salePrice : variation.price;

        // Update smallest and largest prices
        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }

        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }

      // If smallest and largest prices are the same, return a single price
      if (smallestPrice.isEqual(largestPrice)) {
        return largestPrice.toString();
      } else {
        // Otherwise, return a price range
        return '$smallestPrice - \$$largestPrice';
      }
    }
  }

  /// -- Calculate Discount Percentage
  String? calculateSalePercentage(double originalPrice, double? salePrice) {
    if (salePrice == null || salePrice <= 0.0) return null;
    if (originalPrice <= 0) return null;

    double percentage = ((originalPrice - salePrice) / originalPrice) * 100;
    return percentage.toStringAsFixed(0);
  }

  /// -- Check Product Stock Status
  String getProductStockStatus(ProductModel product) {
    if (product.productType.name == ProductType.simple.name) {
      return product.stock > 0 ? 'In Stock' : 'Out of Stock';
    } else {
      final stock = product.variations?.fold(0, (previousValue, element) => previousValue + element.stock);
      return stock != null && stock > 0 ? 'In Stock' : 'Out of Stock';
    }
  }

  Future<void> updateProductStock(String productId, int quantitySold, String variationId) async {
    try {
      // Fetch Products
      final product = await productRepository.getSingleProduct(productId);

      if (variationId.isEmpty) {
        product.soldQuantity += quantitySold;

        await productRepository.updateProduct(product);
      } else {
        final variation = product.variations!.where((variation) => variation.id == variationId).first;
        variation.soldQuantity += quantitySold;
        await productRepository.updateProduct(product);
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<ProductModel> getProduct(String productId) async {
    return await productRepository.getSingleProduct(productId);
  }

  Future<List<ProductModel>> getAllNewArrivalProduct() async {
    return await productRepository.getAllProducts();
  }

  Future<void> updateProductView(String productId, ProductModel product) async {
    int view = product.views ?? 0;
    view++;
    await productRepository.updateSingleField(productId, {"views": view});
  }

  Future<void> addProductLike(String productId, ProductModel product) async {
    // int like = product.likes ?? 0;
    // like++;
    // Will be handled in Future
    // await productRepository.updateSingleField(productId, {"likes": like});
  }

  Future<void> removeProductLike(String productId, ProductModel product) async {
    // int like = product.likes ?? 0;
    // like--;
    // Will be handled in Future
    // await productRepository.updateSingleField(productId, {"likes": like});
  }
}
