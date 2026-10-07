import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

class CartService {
  // Stores products added during the current app session.
  static final List<CartProduct> _localCartProducts = [];

  // Gets all carts.
  Future<List<Cart>> getAllCarts() async {
    final response = await http.get(
      Uri.parse('$host/carts'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final List cartsJson = data['carts'] ?? [];

      return cartsJson
          .map((json) => Cart.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to load carts. '
        'Status: ${response.statusCode}',
      );
    }
  }

  // Gets the cart belonging to one user.
  Future<List<Cart>> getCartsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$host/carts/user/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final List cartsJson = data['carts'] ?? [];

      final carts = cartsJson
          .map((json) => Cart.fromJson(json))
          .toList();

      // Adds locally added products to the user's cart.
      

      return carts;
    } else {
      throw Exception(
        'Failed to load user cart. '
        'Status: ${response.statusCode}',
      );
    }
  }

  // Adds a product to a user's cart.
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('$host/carts/add'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'products': [
          {
            'id': productId,
            'quantity': quantity,
          },
        ],
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final cart = Cart.fromJson(data);

      // Saves the product locally so it appears in CartScreen.
      _localCartProducts.addAll(cart.products);

      return cart;
    } else {
      throw Exception(
        'Failed to add product. '
        'Status: ${response.statusCode}, '
        'Response: ${response.body}',
      );
    }
  }
}