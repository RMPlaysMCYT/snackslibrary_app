// lib/screens/products/product_form_screen.dart
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final VoidCallback? onProductSaved;

  const ProductFormScreen({this.product, this.onProductSaved});

  @override
  // ignore: library_private_types_in_public_api
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.product != null;

    if (_isEditMode) {
      _productCodeController.text =
          widget.product!.productCode?.toString() ?? '';
      _productNameController.text = widget.product!.productName ?? '';
      _detailsController.text = widget.product!.details ?? '';
      _priceController.text = widget.product!.price?.toString() ?? '';
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create product with safe parsing
      final product = Product(
        id: _isEditMode ? (widget.product?.id ?? 0) : 0,
        productCode: int.tryParse(_productCodeController.text.trim()) ?? 0,
        productName: _productNameController.text.trim(),
        details: _detailsController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        createdAt: _isEditMode ? widget.product?.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('💾 Saving product: ${product.toJson()}');

      Product updatedProduct;

      if (_isEditMode) {
        updatedProduct = await _productService.updateProduct(
          product.id,
          product,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Product updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        updatedProduct = await _productService.createProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Product created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      print('💾 Saved successfully: ${updatedProduct.productName}');

      // Callback to refresh product list
      if (widget.onProductSaved != null) {
        widget.onProductSaved!();
      }

      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      print('❌ Error saving product: $e');
      print('📋 Stack trace: $stackTrace');

      String errorMessage = 'Error: ${e.toString()}';

      // Provide more user-friendly error messages
      if (e.toString().contains('Null') && e.toString().contains('int')) {
        errorMessage = 'Server returned invalid data. Please try again.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Cannot connect to server. Check your connection.';
      } else if (e.toString().contains('timed out')) {
        errorMessage = 'Request timed out. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${widget.product!.productName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        await _productService.deleteProduct(widget.product!.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Callback to refresh product list
        if (widget.onProductSaved != null) {
          widget.onProductSaved!();
        }

        Navigator.pop(context, true);
      } catch (e) {
        print('❌ Error deleting product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to delete product: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add New Product'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: _isLoading ? null : () => _showDeleteDialog(),
              tooltip: 'Delete Product',
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Code Field
                  TextFormField(
                    controller: _productCodeController,
                    decoration: InputDecoration(
                      labelText: 'Product Code *',
                      hintText: 'Enter product code (e.g., 1001)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                      filled: true,
                      fillColor:
                          Theme.of(context).inputDecorationTheme.fillColor ??
                          Theme.of(context).colorScheme.surface,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product code';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Product Name Field
                  TextFormField(
                    controller: _productNameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name *',
                      hintText: 'Enter product name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag),
                      filled: true,
                      // fillColor: Colors.grey[50],
                      fillColor:
                          Theme.of(context).inputDecorationTheme.fillColor ??
                          Theme.of(context).colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Price Field
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price *',
                      hintText: 'Enter price (e.g., 19.99)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      filled: true,
                      // fillColor: Colors.grey[50],
                      fillColor:
                          Theme.of(context).inputDecorationTheme.fillColor ??
                          Theme.of(context).colorScheme.surface,
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      final price = double.tryParse(value);
                      if (price == null) {
                        return 'Please enter a valid number';
                      }
                      if (price <= 0) {
                        return 'Price must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Details Field
                  TextFormField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      labelText: 'Details',
                      hintText: 'Enter product description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      filled: true,
                      // fillColor: Colors.grey[50],
                      fillColor:
                          Theme.of(context).inputDecorationTheme.fillColor ??
                          Theme.of(context).colorScheme.surface,
                    ),
                    maxLines: 4,
                    minLines: 3,
                  ),
                  SizedBox(height: 30),

                  // Save Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _isEditMode ? Colors.blue : Colors.green,
                    ),
                    icon: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Icon(_isEditMode ? Icons.save : Icons.add),
                    label: Text(
                      _isLoading
                          ? 'PLEASE WAIT...'
                          : _isEditMode
                          ? 'UPDATE PRODUCT'
                          : 'SAVE PRODUCT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Cancel Button
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('CANCEL', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _productNameController.dispose();
    _detailsController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
