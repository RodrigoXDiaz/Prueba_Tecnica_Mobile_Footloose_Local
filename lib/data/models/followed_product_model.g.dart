// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'followed_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowedProductModel _$FollowedProductModelFromJson(
        Map<String, dynamic> json) =>
    FollowedProductModel(
      productId: json['productId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      followedAt: DateTime.parse(json['followedAt'] as String),
    );

Map<String, dynamic> _$FollowedProductModelToJson(
        FollowedProductModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'currentPrice': instance.currentPrice,
      'followedAt': instance.followedAt.toIso8601String(),
    };
