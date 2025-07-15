import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:t_utils/t_utils.dart';

import '../../../utils/constants/enums.dart';
import 'brand_model.dart';
import 'category_model.dart';
import 'product_attribute_model.dart';
import 'product_review_model.dart';
import 'product_variation_model.dart';

class ProductModel {
  // Basic Information
  String id;
  String title;
  String lowerTitle;
  String? sku;
  String? description;
  double price;
  double? salePrice; // Sale or discounted price
  String thumbnail; // Main Image
  List<String>? images; // List of image URLs
  ProductType productType; // simple, digital, variable

  // Inventory Information
  int stock; // Number of items in stock
  bool? isOutOfStock; // Whether product is out of stock
  int soldQuantity; // Total quantity sold

  // Brand & Category
  BrandModel? brand; // Associated brand
  List<String>? tags; // Multiple tags
  List<CategoryModel>? categories; // Multiple categories, including parent-child relationships
  List<String>? categoryIds; // Multiple category Ids, for the app product search

  // Product Unit
  // UnitModel? unit; // Unit of measurement (weight, volume, etc.)

  // Product Attributes
  List<ProductAttributeModel>? attributes; // Product attributes (size, color, etc.)
  List<ProductVariationModel>? variations; // Variations based on attributes

  // Status & Visibility
  bool isRecommended; // Whether product is recommended
  bool isFeatured; // Whether product is featured
  bool isActive; // Product visibility status (active/inactive)
  bool isDraft; // Whether product is still in draft mode
  bool isDeleted; // Soft delete flag

  // Promotion and Pricing
  bool? onSale; // Flag if on sale
  DateTime? saleStartDate; // Sale start date
  DateTime? saleEndDate; // Sale end date

  // Stats
  int? views; // Number of product views
  int? likes; // Number of likes or favorites

  // Ratings
  double? rating; // Average rating
  int? ratingCount; // Number of ratings
  int? reviewsCount; // Number of reviews
  List<ReviewModel>? lastReviews;
  int fiveStarCount;
  int fourStarCount;
  int threeStarCount;
  int twoStarCount;
  int oneStarCount;

  // Audit & History
  String? createdBy; // User who created the product
  DateTime? createdAt; // Creation timestamp
  String? updatedBy; // Last updated by user
  DateTime? updatedAt; // Last update timestamp

  ProductModel({
    required this.id,
    required this.title,
    required this.lowerTitle,
    this.description = '',
    this.sku,
    required this.price,
    this.salePrice,
    required this.thumbnail,
    this.images,
    this.productType = ProductType.simple,
    this.stock = 0,
    this.isOutOfStock,
    this.soldQuantity = 0,
    this.brand,
    this.tags,
    this.categories,
    this.categoryIds,
    // this.unit,
    this.attributes,
    this.variations,
    this.isRecommended = false,
    this.isFeatured = false,
    this.isActive = true,
    this.isDraft = false,
    this.isDeleted = false,
    this.onSale,
    this.saleStartDate,
    this.saleEndDate,
    this.views = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.reviewsCount = 0,
    // Initialize new review distribution fields to 0
    this.fiveStarCount = 0,
    this.fourStarCount = 0,
    this.threeStarCount = 0,
    this.twoStarCount = 0,
    this.oneStarCount = 0,
    this.likes = 0,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  /// Helper Function
  ///
  /// CHECK IF STOCK EXIST
  bool get isInStock {
    if (productType == ProductType.simple) return stock > 0 ? true : false;

    if (productType == ProductType.variable) {
      if (variations == null || variations!.isEmpty) return false;
      return variations!.any((variation) => variation.stock > 0 ? true : false);
    }

    return false;
  }

  /// Helper Function
  ///
  /// CHECK IF PRODUCT ON SALE
  bool get isOnSale {
    bool productOnSale = false;

    if (productType == ProductType.simple) {
      productOnSale = (salePrice != null && salePrice! > 0) ? true : false;
    } else {
      if (variations == null || variations!.isEmpty) return false;
      productOnSale = variations!.any((variation) => variation.salePrice > 0 ? true : false);
    }

    return productOnSale;
  }

  /// Helper Function
  ///
  /// CHECK STOCK TOTAL
  int get getStockTotal {
    if (productType == ProductType.simple) {
      return stock;
    } else {
      if (variations == null || variations!.isEmpty) return 0;
      return variations!.fold<int>(0, (previousValue, newValue) => previousValue + newValue.stock);
    }
  }

  /// Helper Function
  ///
  /// GET PRODUCT PRICE OR PRICE RANGE
  String get getProductPrice {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;

    // If no variations exist, return the simple price or sale price
    if (productType.name == ProductType.simple.name || variations!.isEmpty) {
      return '\$${(salePrice ?? 0) > 0.0 ? salePrice : price}';
    } else {
      // Calculate the smallest and largest prices among variations
      for (var variation in variations!) {
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
        return '\$$smallestPrice - \$$largestPrice';
      }
    }
  }

  /// GET PRODUCT SALE PRICE OR PRICE RANGE
  String get getProductPriceWithoutSalePrice {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;

    // If no variations exist, return the simple price or sale price
    if (productType.name == ProductType.simple.name || variations!.isEmpty) {
      return '\$$price';
    } else {
      // Calculate the smallest and largest prices among variations
      for (var variation in variations!) {
        // Determine the price to consider (sale price if available, otherwise regular price)
        double priceToConsider = variation.price;

        // Update smallest and largest prices
        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }

        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }

      if (largestPrice == 0) return '';

      // If smallest and largest prices are the same, return a single price
      if (smallestPrice.isEqual(largestPrice)) {
        return largestPrice.toString();
      } else {
        // Otherwise, return a price range
        return '\$$smallestPrice - \$$largestPrice';
      }
    }
  }

  /// Helper Function
  ///
  /// GET MAX SALE OF SIMPLE OR VARIABLE PRODUCT
  String? get getMaxDiscountPercentage {
    double maxDiscountPercentage = 0.0;

    // If no variations exist, calculate discount for simple product
    if (productType == ProductType.simple || variations!.isEmpty) {
      return getSimpleProductSalePercentage;
    } else {
      // Loop through each variation to find the maximum discount percentage
      for (var variation in variations!) {
        if (variation.salePrice > 0.0 && variation.price > 0.0) {
          double discountPercentage = ((variation.price - variation.salePrice) / variation.price) * 100;

          // Update maxDiscountPercentage if the current variation has a higher discount
          if (discountPercentage > maxDiscountPercentage) {
            maxDiscountPercentage = discountPercentage;
          }
        }
      }

      // Return the highest discount percentage found
      return maxDiscountPercentage > 0.0 ? maxDiscountPercentage.toStringAsFixed(0) : null;
    }
  }

  /// Helper Function
  ///
  /// GET PRODUCT SALE PERCENTAGE OR PRICE RANGE
  String get getSimpleProductSalePercentage {
    if (salePrice == null || salePrice! <= 0.0) return '';
    if (price <= 0) return '';

    double percentage = ((price - salePrice!) / price) * 100;
    return percentage.toStringAsFixed(0);
  }

  /// Helper Function
  ///
  /// GET PRODUCT SOLD QUANTITY
  String get getSoldQuantity {
    return productType.name == ProductType.simple.name
        ? soldQuantity.toString()
        : variations!.fold<int>(0, (previousValue, element) => previousValue + element.soldQuantity).toString();
  }

  /// Calculates and updates the average rating based on previous and new ratings.
  /// Additionally, it updates the star distribution counts.
  void updateAverageRating(double newRating) {
    if (ratingCount == null || ratingCount == 0) {
      // If there are no existing ratings, the new rating becomes the average.
      rating = newRating;
    } else {
      // Calculate the new average using the previous total and the new rating.
      double totalRatingSum = (rating! * ratingCount!);
      rating = (totalRatingSum + newRating) / (ratingCount! + 1);
    }

    // Increment the rating count as a new rating has been added.
    ratingCount = (ratingCount ?? 0) + 1;

    // --- New Logic for Updating Star Distribution ---
    int intRating = newRating.toInt();
    if (intRating >= 5) {
      fiveStarCount++;
    } else if (intRating == 4) {
      fourStarCount++;
    } else if (intRating == 3) {
      threeStarCount++;
    } else if (intRating == 2) {
      twoStarCount++;
    } else if (intRating <= 1) {
      oneStarCount++;
    }
  }

  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  // toJson method to convert model to JSON format
  Map<String, dynamic> toJson() => {
    'title': title,
    'lowerTitle': lowerTitle,
    'description': description,
    'sku': sku,
    'price': price,
    'salePrice': salePrice,
    'thumbnail': thumbnail,
    'images': images,
    'productType': productType.name,
    'stock': getStockTotal,
    'isOutOfStock': !isInStock,
    'soldQuantity': soldQuantity,
    'brand': brand?.toJson(),
    'tags': tags,
    'categoryIds': categoryIds,
    'categories': categories?.map((c) => c.toJson()).toList(),
    // 'unit': unit?.toJson(),
    'attributes': attributes?.map((attr) => attr.toJson()).toList(),
    'variations': variations?.map((variation) => variation.toJson()).toList(),
    'isRecommended': isRecommended,
    'isFeatured': isFeatured,
    'isActive': isActive,
    'isDraft': isDraft,
    'isDeleted': isDeleted,
    'onSale': isOnSale,
    'saleStartDate': saleStartDate,
    'saleEndDate': saleEndDate,
    'views': views,
    'rating': rating,
    'ratingCount': ratingCount,
    'reviewsCount': reviewsCount,
    'likes': likes,
    // New review distribution fields
    'fiveStarCount': fiveStarCount,
    'fourStarCount': fourStarCount,
    'threeStarCount': threeStarCount,
    'twoStarCount': twoStarCount,
    'oneStarCount': oneStarCount,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedBy': updatedBy,
    'updatedAt': DateTime.now(),
  };

  // fromJson method to create a model instance from JSON
  factory ProductModel.fromJson(String id, Map<String, dynamic> json) => ProductModel(
    id: id,
    title: json.containsKey('title') ? json['title'] : '',
    lowerTitle: json.containsKey('lowerTitle') ? json['lowerTitle'] : '',
    description: json.containsKey('description') ? json['description'] : '',
    sku: json.containsKey('sku') ? json['sku'] : null,
    price: json.containsKey('price') ? json['price'].toDouble() : 0.0,
    salePrice: json.containsKey('salePrice') ? json['salePrice']?.toDouble() : null,
    thumbnail: json.containsKey('thumbnail') ? json['thumbnail'] : '',
    images: json.containsKey('images') ? List<String>.from(json['images']) : [],
    productType: json.containsKey('productType')
        ? ProductType.values.firstWhere((e) => e.name == json['productType'], orElse: () => ProductType.simple)
        : ProductType.simple,
    stock: json.containsKey('stock') ? json['stock'] : 0,
    isOutOfStock: json.containsKey('isOutOfStock') ? json['isOutOfStock'] : null,
    soldQuantity: json.containsKey('soldQuantity') ? json['soldQuantity'] : 0,
    brand: json.containsKey('brand') && json['brand'] != null ? BrandModel.fromJson(json['brand']['id'], json['brand']) : null,
    tags: json.containsKey('tags') && json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
    categoryIds: json.containsKey('categoryIds') && json['categoryIds'] != null ? List<String>.from(json['categoryIds'] as List) : null,
    categories: json.containsKey('categories') && json['categories'] != null
        ? (json['categories'] as List).map((c) => CategoryModel.fromJson(c['id'], c)).toList()
        : null,
    // unit: json.containsKey('unit') && json['unit'] != null ? UnitModel.fromJson(json['unit']['id'], json['unit']) : null,
    attributes: json.containsKey('attributes') && json['attributes'] != null
        ? (json['attributes'] as List).map((attr) => ProductAttributeModel.fromJson(attr)).toList()
        : null,
    variations: json.containsKey('variations') && json['variations'] != null
        ? (json['variations'] as List).map((variation) => ProductVariationModel.fromJson(variation)).toList()
        : null,
    isRecommended: json.containsKey('isRecommended') ? json['isRecommended'] : false,
    isFeatured: json.containsKey('isFeatured') ? json['isFeatured'] : false,
    isActive: json.containsKey('isActive') ? json['isActive'] : true,
    isDraft: json.containsKey('isDraft') ? json['isDraft'] : false,
    isDeleted: json.containsKey('isDeleted') ? json['isDeleted'] : false,
    onSale: json.containsKey('onSale') ? json['onSale'] : null,
    saleStartDate: json.containsKey('saleStartDate') ? json['saleStartDate']?.toDate() : null,
    saleEndDate: json.containsKey('saleEndDate') ? json['saleEndDate']?.toDate() : null,
    views: json.containsKey('views') ? json['views'] : 0,
    rating: json.containsKey('rating') ? json['rating']?.toDouble() : 0.0,
    ratingCount: json.containsKey('ratingCount') ? json['ratingCount'] : 0,
    reviewsCount: json.containsKey('reviewsCount') ? json['reviewsCount'] : 0,
    // New review distribution fields
    fiveStarCount: json.containsKey('fiveStarCount') ? json['fiveStarCount'] : 0,
    fourStarCount: json.containsKey('fourStarCount') ? json['fourStarCount'] : 0,
    threeStarCount: json.containsKey('threeStarCount') ? json['threeStarCount'] : 0,
    twoStarCount: json.containsKey('twoStarCount') ? json['twoStarCount'] : 0,
    oneStarCount: json.containsKey('oneStarCount') ? json['oneStarCount'] : 0,

    likes: json.containsKey('likes') ? json['likes'] : 0,
    createdBy: json.containsKey('createdBy') ? json['createdBy'] : null,
    createdAt: json.containsKey('createdAt') ? json['createdAt']?.toDate() : null,
    updatedBy: json.containsKey('updatedBy') ? json['updatedBy'] : null,
    updatedAt: json.containsKey('updatedAt') ? json['updatedAt']?.toDate() : null,
  );

  /// Factory method to create AttributeModel from Firestore document snapshot
  factory ProductModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProductModel.fromJson(doc.id, data);
  }

  /// Factory method to create a list of AttributeModel from QuerySnapshot (for retrieving multiple attributes)
  static ProductModel fromQuerySnapshot(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromJson(doc.id, data);
  }

  static ProductModel empty() => ProductModel(id: '', title: '', lowerTitle: '', price: 0, thumbnail: '', stock: 0);
}
