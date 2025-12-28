// lib/services/product_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  // IMPORTANT: Update this IP to match your Laravel server
  static const String baseUrl = 'http://192.168.88.230:8000/api'; // Your IP

  // Helper method for API calls
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      print('🌐 API Call: $method $baseUrl$endpoint');

      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: json.encode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: json.encode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('📡 Response: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'error': 'Cannot connect to server. Check your connection.',
      };
    } on FormatException {
      return {'success': false, 'error': 'Invalid response from server.'};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // CREATE - Add new product
  Future<Product> createProduct(Product product) async {
    final result = await _makeRequest(
      'POST',
      '/products',
      body: {
        'product_code': product.productCode,
        'product_name': product.productName,
        'details': product.details,
        'price': product.price,
      },
    );

    if (result['success'] == true) {
      final jsonData = result['data'];
      // Handle nested response format
      if (jsonData is Map && jsonData.containsKey('product')) {
        return Product.fromJson(jsonData['product']);
      } else if (jsonData is Map && jsonData.containsKey('data')) {
        return Product.fromJson(jsonData['data']);
      } else {
        return Product.fromJson(jsonData as Map<String, dynamic>);
      }
    } else {
      throw Exception(result['error']);
    }
  }

  // READ ALL - Get all products
  Future<List<Product>> getProducts() async {
    final result = await _makeRequest('GET', '/products');

    if (result['success'] == true) {
      final jsonData = result['data'];
      List<dynamic> productsList;

      // Handle different response formats
      if (jsonData is List) {
        // Direct array: [{...}, {...}]
        productsList = jsonData;
      } else if (jsonData is Map && jsonData.containsKey('data')) {
        // Wrapped: {"data": [{...}, {...}], "success": true}
        productsList = jsonData['data'] is List ? jsonData['data'] : [];
      } else if (jsonData is Map && jsonData.containsKey('products')) {
        // Wrapped: {"products": [{...}, {...}]}
        productsList = jsonData['products'] is List ? jsonData['products'] : [];
      } else {
        // Try to use as-is
        productsList = jsonData is List ? jsonData : [];
      }

      return productsList
          .where((item) => item is Map)
          .map<Product>(
            (item) => Product.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(result['error']);
    }
  }

  // READ ONE - Get single product
  Future<Product> getProduct(int id) async {
    final result = await _makeRequest('GET', '/products/$id');

    if (result['success'] == true) {
      final jsonData = result['data'];
      // Handle nested response format
      if (jsonData is Map && jsonData.containsKey('product')) {
        return Product.fromJson(jsonData['product']);
      } else if (jsonData is Map && jsonData.containsKey('data')) {
        return Product.fromJson(jsonData['data']);
      } else {
        return Product.fromJson(jsonData as Map<String, dynamic>);
      }
    } else {
      throw Exception(result['error']);
    }
  }

  // UPDATE - Update product
  Future<Product> updateProduct(int id, Product product) async {
    final result = await _makeRequest(
      'PUT',
      '/products/$id',
      body: {
        'product_code': product.productCode,
        'product_name': product.productName,
        'details': product.details,
        'price': product.price,
      },
    );

    if (result['success'] == true) {
      final jsonData = result['data'];
      // Handle nested response format
      if (jsonData is Map && jsonData.containsKey('product')) {
        return Product.fromJson(jsonData['product']);
      } else if (jsonData is Map && jsonData.containsKey('data')) {
        return Product.fromJson(jsonData['data']);
      } else {
        return Product.fromJson(jsonData as Map<String, dynamic>);
      }
    } else {
      throw Exception(result['error']);
    }
  }

  // DELETE - Delete product
  Future<void> deleteProduct(int id) async {
    final result = await _makeRequest('DELETE', '/products/$id');

    if (result['success'] != true) {
      throw Exception(result['error']);
    }
  }

  // SEARCH - Search products
  Future<List<Product>> searchProducts(String query) async {
    final result = await _makeRequest('GET', '/products/search?q=$query');

    if (result['success'] == true) {
      final jsonData = result['data'];
      List<dynamic> productsList;

      if (jsonData is List) {
        productsList = jsonData;
      } else if (jsonData is Map && jsonData.containsKey('data')) {
        productsList = jsonData['data'] is List ? jsonData['data'] : [];
      } else {
        productsList = [];
      }

      return productsList
          .where((item) => item is Map)
          .map<Product>(
            (item) => Product.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(result['error']);
    }
  }

  // DEBUG - Test API connection
  Future<void> debugApi() async {
    print('=== API DEBUG START ===');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Accept': 'application/json'},
      );

      print('URL: $baseUrl/products');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body (first 1000 chars):');
      print(
        response.body.length > 1000
            ? response.body.substring(0, 1000) + '...'
            : response.body,
      );
    } catch (e) {
      print('Debug error: $e');
    }
    print('=== API DEBUG END ===');
  }
}
