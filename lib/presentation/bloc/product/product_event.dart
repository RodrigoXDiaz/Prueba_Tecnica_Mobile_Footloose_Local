import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final String? search;
  final String? brand;
  final String? color;
  final String? size;

  const LoadProducts({
    this.search,
    this.brand,
    this.color,
    this.size,
  });

  @override
  List<Object?> get props => [search, brand, color, size];
}

class LoadProductById extends ProductEvent {
  final String id;

  const LoadProductById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateProduct extends ProductEvent {
  final String name;
  final String brand;
  final String model;
  final String color;
  final String size;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? description;
  final String? imagePath;
  final List<int>? imageBytes;
  final String? imageFileName;

  const CreateProduct({
    required this.name,
    required this.brand,
    required this.model,
    required this.color,
    required this.size,
    required this.price,
    this.stock = 0,
    this.imageUrl,
    this.description,
    this.imagePath,
    this.imageBytes,
    this.imageFileName,
  });

  @override
  List<Object?> get props => [
        name,
        brand,
        model,
        color,
        size,
        price,
        stock,
        imageUrl,
        description,
        imagePath,
        imageBytes,
        imageFileName,
      ];
}

class UpdateProduct extends ProductEvent {
  final String id;
  final String? name;
  final String? brand;
  final String? model;
  final String? color;
  final String? size;
  final double? price;
  final String? imageUrl;
  final String? description;
  final String? imagePath;
  final List<int>? imageBytes;
  final String? imageFileName;

  const UpdateProduct({
    required this.id,
    this.name,
    this.brand,
    this.model,
    this.color,
    this.size,
    this.price,
    this.imageUrl,
    this.description,
    this.imagePath,
    this.imageBytes,
    this.imageFileName,
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
        imagePath,
        imageBytes,
        imageFileName,
      ];
}

class DeleteProduct extends ProductEvent {
  final String id;

  const DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateProductPrice extends ProductEvent {
  final String id;
  final double newPrice;

  const UpdateProductPrice({
    required this.id,
    required this.newPrice,
  });

  @override
  List<Object?> get props => [id, newPrice];
}

class ImportProductsFromExcel extends ProductEvent {
  final String filePath;
  final List<int>? bytes;
  final String? fileName;

  const ImportProductsFromExcel(
    this.filePath, {
    this.bytes,
    this.fileName,
  });

  @override
  List<Object?> get props => [filePath, bytes, fileName];
}

class ExportProductsToExcel extends ProductEvent {
  const ExportProductsToExcel();
}

class GenerateProductPdf extends ProductEvent {
  final String productId;

  const GenerateProductPdf(this.productId);

  @override
  List<Object?> get props => [productId];
}
