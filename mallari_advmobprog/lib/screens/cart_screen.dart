import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';
import '../screens/details_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final Future<List<Cart>> _cartsFuture;

  // Loads the cart for the selected user.
  final int userId = 1;

  // Stores the current quantity of each product.
  final Map<int, int> _quantities = {};

  @override
  void initState() {
    super.initState();

    // Gets the user's cart from the API.
    _cartsFuture = CartService().getCartsByUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Cart>>(
        future: _cartsFuture,
        builder: (context, snapshot) {
          // Shows loading indicator while the API is loading.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Shows an error message if the API fails.
          if (snapshot.hasError) {
            return Center(
              child: CustomText(
                text: 'Error: ${snapshot.error}',
                fontSize: 14.sp,
              ),
            );
          }

          final carts = snapshot.data ?? [];

          // Shows a message when no cart is available.
          if (carts.isEmpty) {
            return Center(
              child: CustomText(text: 'No cart found.', fontSize: 14.sp),
            );
          }

          // Displays the user's first cart.
          final cart = carts.first;

          // Saves the original quantities the first time the cart loads.
          if (_quantities.isEmpty) {
            for (final item in cart.products) {
              _quantities[item.id] = item.quantity;
            }
          }

          // Calculates the subtotal using the current quantities.
          final subtotal = _calculateSubtotal(cart);

          return Column(
            children: [
              // Displays the cart products.
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  itemCount: cart.products.length,
                  itemBuilder: (context, index) {
                    final item = cart.products[index];

                    return _buildCartItem(context, item);
                  },
                ),
              ),

              // Displays the cart summary.
              _buildCartSummary(subtotal),
            ],
          );
        },
      ),
    );
  }

  // Builds one product card in the cart.
  Widget _buildCartItem(BuildContext context, CartProduct item) {
    final quantity = _quantities[item.id] ?? item.quantity;

    // Calculates the total for this product.
    final itemTotal = item.price * quantity;

    return GestureDetector(
      onTap: () {
        // Opens the product detail screen.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(productId: item.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product image.
            SizedBox(
              width: 72.w,
              height: 72.h,
              child: Image.network(
                item.thumbnail,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Icon(Icons.image, size: 40.sp);
                },
              ),
            ),

            SizedBox(width: 12.w),

            // Product information.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: item.title,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 5.h),

                  CustomText(
                    text: '\$${item.price.toStringAsFixed(2)}',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),

                  SizedBox(height: 3.h),

                  CustomText(
                    text:
                        '${item.discountPercentage.toStringAsFixed(0)}% off • \$${itemTotal.toStringAsFixed(2)} total',
                    fontSize: 10.sp,
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Quantity controls.
            Column(
              children: [
                // Increases the product quantity.
                SizedBox(
                  width: 32.w,
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _quantities[item.id] = quantity + 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Displays the current quantity.
                CustomText(
                  text: '$quantity',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),

                SizedBox(height: 4.h),

                // Decreases the product quantity.
                SizedBox(
                  width: 32.w,
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: quantity > 1
                        ? () {
                            setState(() {
                              _quantities[item.id] = quantity - 1;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFFE9E9EF),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: const Color(0xFFE9E9EF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text(
                      '−',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Calculates the subtotal from the current quantities.
  double _calculateSubtotal(Cart cart) {
    double subtotal = 0;

    for (final item in cart.products) {
      final quantity = _quantities[item.id] ?? item.quantity;
      subtotal += item.price * quantity;
    }

    return subtotal;
  }

  // Builds the subtotal and confirmation button.
  Widget _buildCartSummary(double subtotal) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      color: const Color(0xFFF9F5FC),
      child: Column(
        children: [
          // Displays the updated subtotal.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: 'Subtotal:', fontSize: 11.sp),
              CustomText(
                text: '\$${subtotal.toStringAsFixed(2)}',
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Displays the delivery fee.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: 'Delivery Fee:', fontSize: 11.sp),
              CustomText(
                text: '\$0.00',
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Confirms the order.
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order confirmed!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: CustomText(
                text: 'Confirm Order',
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
