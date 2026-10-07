import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';
import '../screens/details_screen.dart';

class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final Future<List<Cart>> _cartsFuture;

  // Stores only the temporary quantity changes.
  // The products themselves remain static from the dummy JSON.
  final Map<int, int> _quantities = {};

  @override
  void initState() {
    super.initState();

    // Load the static dummy cart for this user.
    _cartsFuture = CartService().getCartsByUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Cart>>(
        future: _cartsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: CustomText(
                text: 'Error: ${snapshot.error}',
                fontSize: 14.sp,
              ),
            );
          }

          final carts = snapshot.data ?? [];

          if (carts.isEmpty) {
            return Center(
              child: CustomText(
                text: 'No cart found.',
                fontSize: 14.sp,
              ),
            );
          }

          // Use the first static cart from the dummy JSON.
          final cart = carts.first;

          // Initialize quantities only once.
          if (_quantities.isEmpty) {
            for (final item in cart.products) {
              _quantities[item.id] = item.quantity;
            }
          }

          final subtotal = _calculateSubtotal(cart);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    16.h,
                    16.w,
                    8.h,
                  ),
                  itemCount: cart.products.length,
                  itemBuilder: (context, index) {
                    final item = cart.products[index];

                    return _buildCartItem(
                      context,
                      item,
                    );
                  },
                ),
              ),

              _buildCartSummary(subtotal),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProduct item,
  ) {
    final quantity =
        _quantities[item.id] ?? item.quantity;

    final itemTotal = item.price * quantity;

    return GestureDetector(
      onTap: () {
        // Viewing the product is allowed.
        // This does NOT add another product to the cart.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              productId: item.id,
              userId: widget.userId,
            ),
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product image
            SizedBox(
              width: 72.w,
              height: 72.h,
              child: Image.network(
                item.thumbnail,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) {
                  return Icon(
                    Icons.image,
                    size: 40.sp,
                  );
                },
              ),
            ),

            SizedBox(width: 12.w),

            // Product information
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
                    text:
                        '\$${item.price.toStringAsFixed(2)}',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),

                  SizedBox(height: 3.h),

                  CustomText(
                    text:
                        '${item.discountPercentage.toStringAsFixed(0)}% off • '
                        '\$${itemTotal.toStringAsFixed(2)} total',
                    fontSize: 10.sp,
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Quantity controls
            Column(
              children: [
                // PLUS
                SizedBox(
                  width: 32.w,
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _quantities[item.id] =
                            quantity + 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor:
                          const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.r),
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

                // QUANTITY
                CustomText(
                  text: '$quantity',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),

                SizedBox(height: 4.h),

                // MINUS
                SizedBox(
                  width: 32.w,
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: quantity > 1
                        ? () {
                            setState(() {
                              _quantities[item.id] =
                                  quantity - 1;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor:
                          const Color(0xFFE9E9EF),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor:
                          const Color(0xFFE9E9EF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.r),
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

  // Calculates the subtotal based on the CURRENT quantity.
  double _calculateSubtotal(Cart cart) {
    double subtotal = 0;

    for (final item in cart.products) {
      final quantity =
          _quantities[item.id] ?? item.quantity;

      subtotal += item.price * quantity;
    }

    return subtotal;
  }

  Widget _buildCartSummary(double subtotal) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        8.h,
        16.w,
        12.h,
      ),
      color: const Color(0xFFF9F5FC),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'Subtotal:',
                fontSize: 11.sp,
              ),
              CustomText(
                text:
                    '\$${subtotal.toStringAsFixed(2)}',
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'Delivery Fee:',
                fontSize: 11.sp,
              ),
              CustomText(
                text: '\$0.00',
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),

          SizedBox(height: 12.h),

          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Order confirmed!',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.r),
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