class CartItemModel {
  String productId;
  String title;
  double price;
  double salePrice;
  String? image;
  int quantity;
  String variationId;
  String retailerId;
  String? brandName;
  Map<String, String>? selectedVariation;

  /// Constructor
  CartItemModel({
    required this.productId,
    required this.quantity,
    this.variationId = '',
    this.retailerId = '',
    this.image,
    this.price = 0.0,
    this.salePrice = 0.0,
    this.title = '',
    this.brandName,
    this.selectedVariation,
  });

  /// Calculate Total Amount
  double get totalAmount => ((salePrice > 0 ? salePrice : price) * quantity);

  double get discount => ((price - salePrice) * quantity);

  double get totalAmountWithoutSale => (price * quantity);

  double get salePercentage => (100 - ((salePrice / price) * 100));

  /// Empty Cart
  static CartItemModel empty() => CartItemModel(productId: '', quantity: 0);

  /// Convert a CartItem to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'salePrice': salePrice,
      'image': image,
      'quantity': quantity,
      'variationId': variationId,
      'retailerId': retailerId,
      'brandName': brandName,
      'selectedVariation': selectedVariation,
    };
  }

  /// Create a CartItemModel from a JSON Map
  factory CartItemModel.fromJson(Map<String, dynamic> json) {

    return CartItemModel(
      productId: json.containsKey('productId') ? json['productId'] ?? '' : '',
      title: json.containsKey('title') ? json['title'] ?? '' : '',
      price: json.containsKey('price') ? json['price']?.toDouble() : 0.0,
      salePrice: json.containsKey('salePrice') ? json['salePrice']?.toDouble() : 0.0,
      image: json.containsKey('image') ? json['image'] ?? '' : '',
      quantity: json.containsKey('quantity') ? json['quantity'] : 1,
      variationId: json.containsKey('variationId') ? json['variationId'] ?? '' : '',
      retailerId: json.containsKey('retailerId') ? json['retailerId'] ?? '' : '',
      brandName: json.containsKey('brandName') ? json['brandName'] ?? '' : '',
      selectedVariation: json.containsKey('selectedVariation')
          ? Map<String, String>.from(json['selectedVariation'] ?? {})
          : {},
    );
  }
}
