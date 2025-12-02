import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../core/error/exceptions.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc(this._productRepository) : super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductById>(_onLoadProductById);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<UpdateProductPrice>(_onUpdateProductPrice);
    on<ImportProductsFromExcel>(_onImportProductsFromExcel);
    on<ExportProductsToExcel>(_onExportProductsToExcel);
    on<GenerateProductPdf>(_onGenerateProductPdf);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final products = await _productRepository.getProducts(
        search: event.search,
        brand: event.brand,
        color: event.color,
        size: event.size,
      );
      emit(ProductsLoaded(products));
    } on UnauthorizedException catch (_) {
      // Si no está autorizado, simplemente emitir lista vacía
      emit(const ProductsLoaded([]));
    } on AppException catch (e) {
      emit(ProductError(e.message));
    } catch (e) {
      emit(ProductError('Error al cargar productos: ${e.toString()}'));
    }
  }

  Future<void> _onLoadProductById(
    LoadProductById event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final product = await _productRepository.getProductById(event.id);
      emit(ProductLoaded(product));
    } on AppException catch (e) {
      emit(ProductError(e.message));
    } catch (e) {
      emit(ProductError('Error al cargar producto: ${e.toString()}'));
    }
  }

  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final product = await _productRepository.createProduct(
        name: event.name,
        brand: event.brand,
        model: event.model,
        color: event.color,
        size: event.size,
        price: event.price,
        stock: event.stock,
        imageUrl: event.imageUrl,
        description: event.description,
        imagePath: event.imagePath,
        imageBytes: event.imageBytes,
        imageFileName: event.imageFileName,
      );
      emit(ProductOperationSuccess('Producto creado exitosamente',
          product: product));
    } on AppException catch (e) {
      emit(ProductError(e.message));
    } catch (e) {
      emit(ProductError('Error al crear producto: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final product = await _productRepository.updateProduct(
        id: event.id,
        name: event.name,
        brand: event.brand,
        model: event.model,
        color: event.color,
        size: event.size,
        price: event.price,
        imageUrl: event.imageUrl,
        description: event.description,
        imagePath: event.imagePath,
        imageBytes: event.imageBytes,
        imageFileName: event.imageFileName,
      );
      emit(ProductOperationSuccess('Producto actualizado exitosamente',
          product: product));
    } on AppException catch (e) {
      emit(ProductError(e.message));
    } catch (e) {
      emit(ProductError('Error al actualizar producto: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      await _productRepository.deleteProduct(event.id);
      emit(const ProductOperationSuccess('Producto eliminado exitosamente'));
    } on AppException catch (e) {
      emit(ProductError(e.message));
    } catch (e) {
      emit(ProductError('Error al eliminar producto: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProductPrice(
    UpdateProductPrice event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final product =
          await _productRepository.updatePrice(event.id, event.newPrice);
      emit(ProductOperationSuccess('Precio actualizado exitosamente',
          product: product));
    } on AppException catch (e) {
      emit(ProductError(e.message));
    } catch (e) {
      emit(ProductError('Error al actualizar precio: ${e.toString()}'));
    }
  }

  Future<void> _onImportProductsFromExcel(
    ImportProductsFromExcel event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      await _productRepository.importFromExcel(
        event.filePath,
        bytes: event.bytes,
        fileName: event.fileName,
      );
      // Emitir éxito en lugar de ProductsLoaded
      emit(const ProductOperationSuccess('Productos importados exitosamente'));
    } on AppException catch (e) {
      emit(ProductError(e.message));
    } catch (e) {
      emit(ProductError('Error al importar Excel: ${e.toString()}'));
    }
  }

  Future<void> _onExportProductsToExcel(
    ExportProductsToExcel event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductExporting());
    try {
      final fileBytes = await _productRepository.exportToExcel();
      emit(ProductExported(fileBytes));
    } on AppException catch (e) {
      emit(ProductError(e.message));
    } catch (e) {
      emit(ProductError('Error al exportar Excel: ${e.toString()}'));
    }
  }

  Future<void> _onGenerateProductPdf(
    GenerateProductPdf event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductPdfGenerating());
    try {
      final pdfBytes = await _productRepository.generatePdf(event.productId);
      emit(ProductPdfGenerated(pdfBytes));
    } on AppException catch (e) {
      emit(ProductError(e.message));
    } catch (e) {
      emit(ProductError('Error al generar PDF: ${e.toString()}'));
    }
  }
}
