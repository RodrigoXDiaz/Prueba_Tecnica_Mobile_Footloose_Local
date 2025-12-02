import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String color;
  final String size;
  final double price;
  final String? imageUrl;
  final String? description;
  final int? stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.color,
    required this.size,
    required this.price,
    this.imageUrl,
    this.description,
    this.stock,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        model,
        color,
        size,
        price,
        imageUrl,
        description,
        stock,
        createdAt,
        updatedAt,
      ];
}
