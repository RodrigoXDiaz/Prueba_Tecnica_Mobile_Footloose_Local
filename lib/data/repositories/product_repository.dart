import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/entities/product_entity.dart';
import '../datasources/remote/api_service.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  Future<List<ProductEntity>> getProducts({
    String? search,
    String? brand,
    String? color,
    String? size,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      // El backend no acepta 'search' como query param, filtraremos en cliente
      if (brand != null && brand.isNotEmpty) queryParameters['brand'] = brand;
      if (color != null && color.isNotEmpty) queryParameters['color'] = color;
      if (size != null && size.isNotEmpty) queryParameters['size'] = size;

      final response = await _apiService.get(
        ApiConstants.products,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      List<ProductEntity> products = [];

      // Manejar estructura Firebase
      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          products = data
              .map((json) => ProductModel.fromJson(json).toEntity())
              .toList();
        } else if (data is Map && data['products'] != null) {
          final List<dynamic> productsJson = data['products'];
          products = productsJson
              .map((json) => ProductModel.fromJson(json).toEntity())
              .toList();
        }
      } else {
        // Fallback para otras estructuras
        final List<dynamic> productsJson =
            response.data['products'] ?? response.data['data'] ?? [];
        products = productsJson
            .map((json) => ProductModel.fromJson(json).toEntity())
            .toList();
      }

      // Filtrar por búsqueda en el cliente si se proporciona
      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        products = products.where((product) {
          return product.name.toLowerCase().contains(searchLower) ||
              product.brand.toLowerCase().contains(searchLower) ||
              product.model.toLowerCase().contains(searchLower) ||
              product.color.toLowerCase().contains(searchLower);
        }).toList();
      }

      return products;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al obtener productos: ${e.toString()}');
    }
  }

  Future<ProductEntity> getProductById(String id) async {
    try {
      final response = await _apiService.get(ApiConstants.productById(id));

      // Manejar estructura Firebase
      if (response.data['success'] == true) {
        final productJson = response.data['data'];
        return ProductModel.fromJson(productJson).toEntity();
      }

      // Fallback
      final productJson =
          response.data['product'] ?? response.data['data'] ?? response.data;
      return ProductModel.fromJson(productJson).toEntity();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al obtener producto: ${e.toString()}');
    }
  }

  Future<ProductEntity> createProduct({
    required String name,
    required String brand,
    required String model,
    required String color,
    required String size,
    required double price,
    int stock = 0,
    String? imageUrl,
    String? description,
    String? imagePath,
    List<int>? imageBytes,
    String? imageFileName,
  }) async {
    try {
      final productData = {
        'name': name,
        'brand': brand,
        'model': model,
        'color': color,
        'size': size,
        'price': price,
        'stock': stock,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (description != null) 'description': description,
      };

      final Response response;

      if (imageBytes != null && imageFileName != null) {
        // Web: usar bytes
        response = await _apiService.uploadFileFromBytes(
          ApiConstants.products,
          imageBytes,
          imageFileName,
          fileFieldName: 'image',
          additionalData: productData,
        );
      } else if (imagePath != null) {
        // Mobile: usar path
        response = await _apiService.uploadFile(
          ApiConstants.products,
          imagePath,
          fileFieldName: 'image',
          additionalData: productData,
        );
      } else {
        // Sin imagen
        response = await _apiService.post(
          ApiConstants.products,
          data: productData,
        );
      }

      // Manejar estructura Firebase
      if (response.data['success'] == true) {
        final productJson = response.data['data'];
        return ProductModel.fromJson(productJson).toEntity();
      }

      final productJson =
          response.data['product'] ?? response.data['data'] ?? response.data;
      return ProductModel.fromJson(productJson).toEntity();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al crear producto: ${e.toString()}');
    }
  }

  Future<ProductEntity> updateProduct({
    required String id,
    String? name,
    String? brand,
    String? model,
    String? color,
    String? size,
    double? price,
    String? imageUrl,
    String? description,
    String? imagePath,
    List<int>? imageBytes,
    String? imageFileName,
  }) async {
    try {
      final productData = <String, dynamic>{};
      if (name != null) productData['name'] = name;
      if (brand != null) productData['brand'] = brand;
      if (model != null) productData['model'] = model;
      if (color != null) productData['color'] = color;
      if (size != null) productData['size'] = size;
      if (price != null) productData['price'] = price;
      if (imageUrl != null) productData['imageUrl'] = imageUrl;
      if (description != null) productData['description'] = description;

      final Response response;

      if (imageBytes != null && imageFileName != null) {
        // Web: usar bytes
        response = await _apiService.uploadFileFromBytes(
          ApiConstants.productById(id),
          imageBytes,
          imageFileName,
          fileFieldName: 'image',
          additionalData: productData,
        );
      } else if (imagePath != null) {
        // Mobile: usar path
        response = await _apiService.uploadFile(
          ApiConstants.productById(id),
          imagePath,
          fileFieldName: 'image',
          additionalData: productData,
        );
      } else {
        // Sin imagen
        response = await _apiService.patch(
          ApiConstants.productById(id),
          data: productData,
        );
      }

      // Manejar estructura Firebase
      if (response.data['success'] == true) {
        final productJson = response.data['data'];
        return ProductModel.fromJson(productJson).toEntity();
      }

      final productJson =
          response.data['product'] ?? response.data['data'] ?? response.data;
      return ProductModel.fromJson(productJson).toEntity();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al actualizar producto: ${e.toString()}');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _apiService.delete(ApiConstants.productById(id));
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al eliminar producto: ${e.toString()}');
    }
  }

  Future<ProductEntity> updatePrice(String id, double newPrice) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.updatePrice(id),
        data: {'price': newPrice},
      );

      // Manejar estructura Firebase
      if (response.data['success'] == true) {
        final productJson = response.data['data'];
        return ProductModel.fromJson(productJson).toEntity();
      }

      final productJson =
          response.data['product'] ?? response.data['data'] ?? response.data;
      return ProductModel.fromJson(productJson).toEntity();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al actualizar precio: ${e.toString()}');
    }
  }

  Future<List<ProductEntity>> importFromExcel(
    String filePath, {
    List<int>? bytes,
    String? fileName,
  }) async {
    try {
      final Response response;

      // Si tenemos bytes (web), usar uploadFileFromBytes
      if (bytes != null && fileName != null) {
        response = await _apiService.uploadFileFromBytes(
          ApiConstants.importExcel,
          bytes,
          fileName,
          fileFieldName: 'file',
        );
      } else {
        // Si tenemos path (mobile), usar uploadFile
        response = await _apiService.uploadFile(
          ApiConstants.importExcel,
          filePath,
          fileFieldName: 'file',
        );
      }

      final List<dynamic> productsJson = response.data['products'] ?? [];
      return productsJson
          .map((json) => ProductModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al importar Excel: ${e.toString()}');
    }
  }

  Future<List<int>> exportToExcel() async {
    try {
      // Descargar el archivo como bytes
      final response = await _apiService.dio.get(
        ApiConstants.exportExcel,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data is List<int>) {
        return response.data as List<int>;
      }

      throw ServerException('Formato de respuesta inválido');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al exportar Excel: ${e.toString()}');
    }
  }

  Future<List<int>> generatePdf(String productId) async {
    try {
      // Descargar el archivo como bytes
      final response = await _apiService.dio.get(
        ApiConstants.generatePdf(productId),
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data is List<int>) {
        return response.data as List<int>;
      }

      throw ServerException('Formato de respuesta inválido');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al generar PDF: ${e.toString()}');
    }
  }
}
