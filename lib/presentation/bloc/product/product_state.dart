import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;

  const ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductLoaded extends ProductState {
  final ProductEntity product;

  const ProductLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductOperationSuccess extends ProductState {
  final String message;
  final ProductEntity? product;

  const ProductOperationSuccess(this.message, {this.product});

  @override
  List<Object?> get props => [message, product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductExporting extends ProductState {
  const ProductExporting();
}

class ProductExported extends ProductState {
  final List<int> fileBytes;

  const ProductExported(this.fileBytes);

  @override
  List<Object?> get props => [fileBytes];
}

class ProductPdfGenerating extends ProductState {
  const ProductPdfGenerating();
}

class ProductPdfGenerated extends ProductState {
  final List<int> pdfBytes;

  const ProductPdfGenerated(this.pdfBytes);

  @override
  List<Object?> get props => [pdfBytes];
}
