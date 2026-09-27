import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product? product;
  final int? productId;
  final int userId;

  const ProductDetailsScreen({
    super.key,
    this.product,
    this.productId,
    this.userId = 1,
  });

  @override
  Widget build(BuildContext context) {
    // Uses the product directly when opened from ProductScreen.
    if (product != null) {
      return _buildDetails(context, product!);
    }

    // Loads the product when opened from CartScreen.
    return FutureBuilder<List<Product>>(
      future: ProductService().getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product Details')),
            body: Center(
              child: CustomText(text: 'Error: ${snapshot.error}', fontSize: 14),
            ),
          );
        }

        final products = snapshot.data ?? [];

        Product? selectedProduct;

        for (final item in products) {
          if (item.id == productId) {
            selectedProduct = item;
            break;
          }
        }

        if (selectedProduct == null) {
          return const Scaffold(
            body: Center(child: Text('Product not found.')),
          );
        }

        return _buildDetails(context, selectedProduct);
      },
    );
  }

  Widget _buildDetails(BuildContext context, Product product) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENHANCEMENT 2: Displays the selected product details.
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                product.thumbnail,
                width: double.infinity,
                height: 250.h,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => SizedBox(
                  height: 250.h,
                  child: Icon(Icons.image, size: 50.sp),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            CustomText(
              text: product.title,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: 8.h),

            CustomText(
              text: '\$${product.price.toStringAsFixed(2)}',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),

            SizedBox(height: 16.h),

            CustomText(text: product.description, fontSize: 15.sp),

            SizedBox(height: 16.h),

            CustomText(text: 'Category: ${product.category}', fontSize: 14.sp),

            SizedBox(height: 6.h),

            CustomText(text: 'Brand: ${product.brand}', fontSize: 14.sp),

            SizedBox(height: 6.h),

            CustomText(text: 'Stock: ${product.stock}', fontSize: 14.sp),

            SizedBox(height: 6.h),

            CustomText(text: 'Rating: ${product.rating}', fontSize: 14.sp),

            SizedBox(height: 20.h),

            // ENHANCEMENT 3: Adds the product to the logged-in user's cart.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await CartService().addToCart(
                      userId: userId,
                      productId: product.id,
                      quantity: 1,
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product added to cart!')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add product: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
