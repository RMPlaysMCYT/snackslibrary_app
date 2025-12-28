// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get productCount => _products.length;

  // Get all products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _products = await _productService.getProducts();
      _error = '';
    } catch (e) {
      _error = 'Failed to load products: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get single product
  Future<Product?> getProduct(int id) async {
    try {
      return await _productService.getProduct(id);
    } catch (e) {
      _error = 'Failed to load product: $e';
      notifyListeners();
      return null;
    }
  }

  // Add product
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newProduct = await _productService.createProduct(product);
      _products.add(newProduct);
      _error = '';
    } catch (e) {
      _error = 'Failed to add product: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedProduct = await _productService.updateProduct(
        product.id,
        product,
      );
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _error = '';
    } catch (e) {
      _error = 'Failed to update product: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete product
  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productService.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      _error = '';
    } catch (e) {
      _error = 'Failed to delete product: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products.where((product) {
      return product.productName.toLowerCase().contains(query.toLowerCase()) ||
          product.productCode.toString().contains(query) ||
          product.details.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Clear all products
  void clearProducts() {
    _products = [];
    notifyListeners();
  }
}
