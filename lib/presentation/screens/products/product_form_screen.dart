import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/product_entity.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../widgets/custom_text_field.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductEntity? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  XFile? _selectedImageFile;
  List<int>? _imageBytes; // Para almacenar bytes en web
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _brandController.text = widget.product!.brand;
      _modelController.text = widget.product!.model;
      _colorController.text = widget.product!.color;
      _sizeController.text = widget.product!.size;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock?.toString() ?? '0';
      _descriptionController.text = widget.product!.description ?? '';
      _imageUrlController.text = widget.product!.imageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageFile = image;
            _imageBytes = bytes;
          });
        } else {
          setState(() {
            _selectedImageFile = image;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final price = double.parse(_priceController.text);
      final stock = int.tryParse(_stockController.text) ?? 0;

      if (isEditing) {
        context.read<ProductBloc>().add(
              UpdateProduct(
                id: widget.product!.id,
                name: _nameController.text.trim(),
                brand: _brandController.text.trim(),
                model: _modelController.text.trim(),
                color: _colorController.text.trim(),
                size: _sizeController.text.trim(),
                price: price,
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                imageUrl: _imageUrlController.text.trim().isEmpty
                    ? ''
                    : _imageUrlController.text.trim(),
                imagePath: kIsWeb ? null : _selectedImageFile?.path,
                imageBytes: kIsWeb ? _imageBytes : null,
                imageFileName: _selectedImageFile?.name,
              ),
            );
      } else {
        context.read<ProductBloc>().add(
              CreateProduct(
                name: _nameController.text.trim(),
                brand: _brandController.text.trim(),
                model: _modelController.text.trim(),
                color: _colorController.text.trim(),
                size: _sizeController.text.trim(),
                price: price,
                stock: stock,
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                imageUrl: _imageUrlController.text.trim().isEmpty
                    ? ''
                    : _imageUrlController.text.trim(),
                imagePath: kIsWeb ? null : _selectedImageFile?.path,
                imageBytes: kIsWeb ? _imageBytes : null,
                imageFileName: _selectedImageFile?.name,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(isEditing ? AppStrings.editProduct : AppStrings.addProduct),
        ),
        body: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop(true);
            } else if (state is ProductError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ProductLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _selectedImageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb
                                        ? Image.network(
                                            _selectedImageFile!.path,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(_selectedImageFile!.path),
                                            fit: BoxFit.cover,
                                          ),
                                  )
                                : (_imageUrlController.text.trim().isNotEmpty
                                    ? ClipRRect(
                                        key: ValueKey(
                                            _imageUrlController.text.trim()),
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              _imageUrlController.text.trim(),
                                          fit: BoxFit.cover,
                                          httpHeaders: const {
                                            'User-Agent': 'Mozilla/5.0',
                                          },
                                          placeholder: (context, url) =>
                                              const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.photo,
                                                  size: 64,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Vista previa no disponible',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'La imagen se cargará en el producto',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      )
                                    : (widget.product?.imageUrl != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              widget.product!.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.image_not_supported,
                                                  size: 64,
                                                );
                                              },
                                            ),
                                          )
                                        : const Icon(
                                            Icons.add_photo_alternate,
                                            size: 64,
                                            color: Colors.grey,
                                          ))),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text(AppStrings.uploadImage),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: AppStrings.productName,
                      controller: _nameController,
                      prefixIcon: Icons.shopping_bag,
                      enabled: !isLoading,
                      validator: (value) =>
                          validateRequired(value, AppStrings.productName),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: AppStrings.brand,
                      controller: _brandController,
                      prefixIcon: Icons.branding_watermark,
                      enabled: !isLoading,
                      validator: (value) =>
                          validateRequired(value, AppStrings.brand),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: AppStrings.model,
                      controller: _modelController,
                      prefixIcon: Icons.category,
                      enabled: !isLoading,
                      validator: (value) =>
                          validateRequired(value, AppStrings.model),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: AppStrings.color,
                            controller: _colorController,
                            prefixIcon: Icons.palette,
                            enabled: !isLoading,
                            validator: (value) =>
                                validateRequired(value, AppStrings.color),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            label: AppStrings.size,
                            controller: _sizeController,
                            prefixIcon: Icons.straighten,
                            enabled: !isLoading,
                            validator: (value) =>
                                validateRequired(value, AppStrings.size),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: AppStrings.price,
                            controller: _priceController,
                            prefixIcon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            enabled: !isLoading,
                            validator: (value) =>
                                validateNumber(value, AppStrings.price),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            label: 'Stock',
                            controller: _stockController,
                            prefixIcon: Icons.inventory,
                            keyboardType: TextInputType.number,
                            enabled: !isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El stock es requerido';
                              }
                              final stock = int.tryParse(value);
                              if (stock == null || stock < 0) {
                                return 'Stock debe ser mayor o igual a 0';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: AppStrings.description,
                      controller: _descriptionController,
                      prefixIcon: Icons.description,
                      maxLines: 4,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'URL de imagen (opcional)',
                      controller: _imageUrlController,
                      prefixIcon: Icons.link,
                      enabled: !isLoading,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed:
                          isLoading ? null : () => _handleSubmit(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(isEditing
                              ? 'Actualizar Producto'
                              : 'Crear Producto'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
