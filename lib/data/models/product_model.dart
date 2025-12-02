import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String? id;
  final String name;
  final String brand;
  final String model;
  final String color;
  final String size;
  final double price;
  final String? imageUrl;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
  final int? stock;
  final bool? isActive;

  ProductModel({
    this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.color,
    required this.size,
    required this.price,
    this.imageUrl,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.stock,
    this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      // Convertir valores a String de forma segura
      String? convertToString(dynamic value) {
        if (value == null) return null;
        return value.toString();
      }

      // Convertir a double de forma segura
      double convertToDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      // Convertir a int de forma segura
      int? convertToInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) return int.tryParse(value);
        return null;
      }

      return ProductModel(
        id: convertToString(json['id']),
        name: convertToString(json['name']) ?? 'Sin nombre',
        brand: convertToString(json['brand']) ?? 'Sin marca',
        model: convertToString(json['model']) ?? 'Sin modelo',
        color: convertToString(json['color']) ?? 'N/A',
        size: convertToString(json['size']) ?? 'N/A',
        price: convertToDouble(json['price']),
        imageUrl: convertToString(json['imageUrl']),
        description: convertToString(json['description']),
        createdAt: convertToString(json['createdAt']),
        updatedAt: convertToString(json['updatedAt']),
        stock: convertToInt(json['stock']),
        isActive: json['isActive'] as bool?,
      );
    } catch (e) {
      // Si hay error, intentar con el generado
      return _$ProductModelFromJson(json);
    }
  }

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductEntity toEntity() {
    return ProductEntity(
      id: id ?? '',
      name: name.isNotEmpty ? name : 'Producto sin nombre',
      brand: brand.isNotEmpty ? brand : 'Sin marca',
      model: model.isNotEmpty ? model : 'Sin modelo',
      color: color.isNotEmpty ? color : 'N/A',
      size: size.isNotEmpty ? size : 'N/A',
      price: price >= 0 ? price : 0.0,
      imageUrl: imageUrl,
      description: description,
      stock: stock,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      brand: entity.brand,
      model: entity.model,
      color: entity.color,
      size: entity.size,
      price: entity.price,
      imageUrl: entity.imageUrl,
      description: entity.description,
      stock: entity.stock,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}
