import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/format_helper.dart';
import '../../../core/utils/download_helper.dart';
import '../../../data/datasources/local/storage_service.dart';
import '../../../domain/entities/product_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../widgets/loading_widget.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

// Importación condicional para web
import 'web_download_stub.dart' if (dart.library.html) 'dart:html' as html;

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  String? _selectedBrand;
  String? _selectedColor;
  String? _selectedSize;
  bool _isImporting = false;
  List<ProductEntity> _cachedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    if (!mounted) return;
    context.read<ProductBloc>().add(LoadProducts(
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
          brand: _selectedBrand,
          color: _selectedColor,
          size: _selectedSize,
        ));
  }

  Future<void> _downloadFile(
      List<int> bytes, String fileName, String mimeType) async {
    if (kIsWeb) {
      // Para web, usar dart:html
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Para móvil, guardar archivo
      final filePath = await DownloadHelper.saveFile(
        bytes: bytes,
        fileName: fileName,
      );

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo guardado en: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _FilterDialog(
        selectedBrand: _selectedBrand,
        selectedColor: _selectedColor,
        selectedSize: _selectedSize,
        onApply: (brand, color, size) {
          setState(() {
            _selectedBrand = brand;
            _selectedColor = color;
            _selectedSize = size;
          });
          _loadProducts();
        },
        onClear: () {
          setState(() {
            _selectedBrand = null;
            _selectedColor = null;
            _selectedSize = null;
          });
          _loadProducts();
        },
      ),
    );
  }

  Future<void> _importFromExcel(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Importante para Flutter web
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final fileName = result.files.single.name;
        if (!mounted) return;

        setState(() {
          _isImporting = true;
        });

        context.read<ProductBloc>().add(
              ImportProductsFromExcel(
                '', // path vacío para web
                bytes: bytes,
                fileName: fileName,
              ),
            );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Importando productos...'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar archivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      context.read<ProductBloc>().add(const ExportProductsToExcel());

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Exportando productos...'),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(ProductEntity product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteProduct),
        content: Text('¿Estás seguro de eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProductBloc>().add(DeleteProduct(product.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2D1B4E),
                const Color(0xFF2D1B4E).withOpacity(0.9),
              ],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppStrings.searchProducts,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFFE63946)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                              _loadProducts();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE63946), width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Para actualizar el botón clear
                    if (value.isEmpty) {
                      _loadProducts();
                    }
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty || value.isEmpty) {
                      _loadProducts();
                    }
                  },
                  textInputAction: TextInputAction.search,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: (_selectedBrand != null ||
                          _selectedColor != null ||
                          _selectedSize != null)
                      ? const Color(0xFFE63946)
                      : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: (_selectedBrand != null ||
                            _selectedColor != null ||
                            _selectedSize != null)
                        ? Colors.white
                        : const Color(0xFFE63946),
                  ),
                  onPressed: _showFilterDialog,
                  tooltip: AppStrings.filters,
                ),
              ),
            ],
          ),
        ),

        // Active Filters con colores FOOTLOOSE
        if (_selectedBrand != null ||
            _selectedColor != null ||
            _selectedSize != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B4E).withOpacity(0.05),
              border: Border(
                bottom:
                    BorderSide(color: const Color(0xFF2D1B4E).withOpacity(0.1)),
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_selectedBrand != null)
                  Chip(
                    label: Text('Marca: $_selectedBrand'),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    backgroundColor: const Color(0xFF2D1B4E),
                    deleteIconColor: const Color(0xFFE63946),
                    side: BorderSide.none,
                    onDeleted: () {
                      setState(() => _selectedBrand = null);
                      _loadProducts();
                    },
                  ),
                if (_selectedColor != null)
                  Chip(
                    label: Text('Color: $_selectedColor'),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    backgroundColor: const Color(0xFFE63946),
                    deleteIconColor: Colors.white,
                    side: BorderSide.none,
                    onDeleted: () {
                      setState(() => _selectedColor = null);
                      _loadProducts();
                    },
                  ),
                if (_selectedSize != null)
                  Chip(
                    label: Text('Talla: $_selectedSize'),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    backgroundColor: const Color(0xFF2D1B4E),
                    deleteIconColor: const Color(0xFFE63946),
                    side: BorderSide.none,
                    onDeleted: () {
                      setState(() => _selectedSize = null);
                      _loadProducts();
                    },
                  ),
              ],
            ),
          ),

        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final isAdmin =
                authState is AuthAuthenticated && authState.user.isAdmin;
            if (!isAdmin) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _importFromExcel(context),
                      icon: const Icon(Icons.upload_file, size: 20),
                      label: const Text('Importar Excel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D1B4E),
                        side: const BorderSide(color: Color(0xFF2D1B4E)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _exportToExcel(context),
                      icon: const Icon(Icons.download, size: 20),
                      label: const Text('Exportar Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D1B4E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        Expanded(
          child: BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) async {
              if (state is ProductError) {
                if (_isImporting &&
                    Navigator.canPop(context) &&
                    context.mounted) {
                  Navigator.of(context).pop();
                }
                setState(() {
                  _isImporting = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is ProductOperationSuccess) {
                if (_isImporting &&
                    Navigator.canPop(context) &&
                    context.mounted) {
                  Navigator.of(context).pop();
                }
                setState(() {
                  _isImporting = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                if (state.message.contains('eliminado') ||
                    state.message.contains('importado')) {
                  _loadProducts();
                }
              } else if (state is ProductExported) {
                if (Navigator.canPop(context) && context.mounted) {
                  Navigator.of(context).pop();
                }
                await _downloadFile(state.fileBytes, 'productos.xlsx',
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Excel descargado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is ProductLoading && _cachedProducts.isEmpty) {
                return const LoadingWidget(message: 'Cargando productos...');
              }

              if (state is ProductsLoaded) {
                // Cachear los productos para mantenerlos durante exportación
                _cachedProducts = state.products;

                if (state.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.noProducts,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadProducts(),
                  child: ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return _ProductCard(
                        product: product,
                        onProductUpdated: _loadProducts,
                        onDelete: _showDeleteDialog,
                      );
                    },
                  ),
                );
              }

              if (_cachedProducts.isNotEmpty) {
                return RefreshIndicator(
                  onRefresh: () async => _loadProducts(),
                  child: ListView.builder(
                    itemCount: _cachedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _cachedProducts[index];
                      return _ProductCard(
                        product: product,
                        onProductUpdated: _loadProducts,
                        onDelete: _showDeleteDialog,
                      );
                    },
                  ),
                );
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Desliza para cargar productos'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadProducts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Cargar Productos'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onProductUpdated;
  final Function(ProductEntity) onDelete;

  const _ProductCard({
    required this.product,
    required this.onProductUpdated,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con badges
            Stack(
              children: [
                // Imagen del producto
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildProductImage(context),
                ),

                if (product.stock != null && product.stock! > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2D1B4E),
                            Color(0xFF3D2B5E),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inventory_2,
                            color: Color(0xFFE63946),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.stock}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated && state.user.isAdmin) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2D1B4E),
                                Color(0xFF3D2B5E),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                size: 20, color: Colors.white),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductFormScreen(product: product),
                                  ),
                                );
                                if (result == true) {
                                  onProductUpdated();
                                }
                              } else if (value == 'delete') {
                                onDelete(product);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        color: Color(0xFF2D1B4E), size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      AppStrings.edit,
                                      style: TextStyle(
                                        color: Color(0xFF2D1B4E),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        color: Color(0xFFE63946), size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      AppStrings.delete,
                                      style: TextStyle(
                                        color: Color(0xFFE63946),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),

            // Contenido del producto
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Marca con fondo
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D1B4E).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.brand.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Color(0xFF2D1B4E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF2D1B4E).withOpacity(0.1),
                                const Color(0xFF2D1B4E).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF2D1B4E).withOpacity(0.3),
                                width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'COLOR',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2D1B4E),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                product.color,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2D1B4E),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFE63946).withOpacity(0.15),
                                const Color(0xFFE63946).withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFE63946).withOpacity(0.4),
                                width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TALLA',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFE63946),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                product.size,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE63946),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE63946),
                          Color(0xFFD62839),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE63946).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      FormatHelper.formatCurrency(product.price),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    // Validar URL de imagen
    final isValidUrl = product.imageUrl != null &&
        product.imageUrl!.startsWith('http') &&
        !product.imageUrl!.contains('example.com') &&
        Uri.tryParse(product.imageUrl!)?.hasAbsolutePath == true;

    if (isValidUrl) {
      return Container(
        width: double.infinity,
        height: 280,
        color: Colors.white,
        child: CachedNetworkImage(
          imageUrl: product.imageUrl!,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          placeholder: (context, url) => Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Cargando imagen...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          errorWidget: (context, url, error) => _buildPlaceholderImage(context),
        ),
      );
    }

    return _buildPlaceholderImage(context);
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin imagen',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final String? selectedBrand;
  final String? selectedColor;
  final String? selectedSize;
  final Function(String?, String?, String?) onApply;
  final VoidCallback onClear;

  const _FilterDialog({
    this.selectedBrand,
    this.selectedColor,
    this.selectedSize,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String? _brand;
  late String? _color;
  late String? _size;

  final List<String> _brands = [
    'Nike',
    'Adidas',
    'Puma',
    'Reebok',
    'New Balance'
  ];
  final List<String> _colors = [
    'Rojo',
    'Azul',
    'Negro',
    'Blanco',
    'Verde',
    'Amarillo'
  ];
  final List<String> _sizes = [
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44'
  ];

  @override
  void initState() {
    super.initState();
    _brand = widget.selectedBrand;
    _color = widget.selectedColor;
    _size = widget.selectedSize;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.filters),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.filterByBrand,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _brands.map((brand) {
                return ChoiceChip(
                  label: Text(brand),
                  selected: _brand == brand,
                  onSelected: (selected) {
                    setState(() => _brand = selected ? brand : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.filterByColor,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colors.map((color) {
                return ChoiceChip(
                  label: Text(color),
                  selected: _color == color,
                  onSelected: (selected) {
                    setState(() => _color = selected ? color : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.filterBySize,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _sizes.map((size) {
                return ChoiceChip(
                  label: Text(size),
                  selected: _size == size,
                  onSelected: (selected) {
                    setState(() => _size = selected ? size : null);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClear();
            Navigator.of(context).pop();
          },
          child: const Text(AppStrings.clearFilters),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_brand, _color, _size);
            Navigator.of(context).pop();
          },
          child: const Text(AppStrings.applyFilters),
        ),
      ],
    );
  }
}
