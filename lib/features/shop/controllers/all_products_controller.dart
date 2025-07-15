import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwt_ecommerce_app/data/repositories/product/product_repository.dart';
import 'package:get/get.dart';

import '../../../utils/popups/loaders.dart';
import '../models/product_model.dart';

class AllProductsController extends GetxController {
  static AllProductsController get instance => Get.find();

  final repository = ProductRepository.instance;
  final RxString selectedSortOption = 'Name'.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  Future<List<ProductModel>> fetchProductsByQuery(Query? query) async {
    try {
      if (query == null) return [];
      return await repository.fetchProductsByQuery(query);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  void assignProducts(List<ProductModel> products) {
    // Assign products to the 'products' list
    this.products.assignAll(products);
    sortProducts('Name');
    refresh();
  }

  void sortProducts(String sortOption) {
    selectedSortOption.value = sortOption;

    switch (sortOption) {
      case 'Name':
        products.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Higher Price':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Lower Price':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Newest':
        products.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        break;
      case 'Sale':
        products.sort((a, b) {
          final saleA = a.salePrice ?? 0; // Default null values to 0
          final saleB = b.salePrice ?? 0;

          if (saleB > 0 && saleA > 0) {
            return saleB.compareTo(saleA); // Higher sale price first
          } else if (saleB > 0) {
            return -1; // Prioritize products with a sale price
          } else if (saleA > 0) {
            return 1;
          } else {
            return 0; // No sale, keep original order
          }
        });
        break;

      default:
        // Default sorting option: Name
        products.sort((a, b) => a.title.compareTo(b.title));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    products.clear();
    super.dispose();
  }
}
