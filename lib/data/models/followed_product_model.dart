import 'package:json_annotation/json_annotation.dart';

part 'followed_product_model.g.dart';

@JsonSerializable()
class FollowedProductModel {
  final String productId;
  final String name;
  final String? imageUrl;
  final double currentPrice;
  final DateTime followedAt;

  const FollowedProductModel({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.currentPrice,
    required this.followedAt,
  });

  factory FollowedProductModel.fromJson(Map<String, dynamic> json) {
    // Manejo flexible de tipos
    double convertToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return FollowedProductModel(
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      currentPrice: convertToDouble(json['currentPrice']),
      followedAt: json['followedAt'] != null
          ? DateTime.parse(json['followedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$FollowedProductModelToJson(this);
}
