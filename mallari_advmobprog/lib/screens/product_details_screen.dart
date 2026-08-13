import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../widgets/custom_text.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
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
                errorBuilder: (_, __, ___) => SizedBox(
                  height: 250.h,
                  child: Icon(
                    Icons.image,
                    size: 50.sp,
                  ),
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

            CustomText(
              text: product.description,
              fontSize: 15.sp,
            ),

            SizedBox(height: 16.h),

            CustomText(
              text: 'Category: ${product.category}',
              fontSize: 14.sp,
            ),

            SizedBox(height: 6.h),

            CustomText(
              text: 'Brand: ${product.brand}',
              fontSize: 14.sp,
            ),

            SizedBox(height: 6.h),

            CustomText(
              text: 'Stock: ${product.stock}',
              fontSize: 14.sp,
            ),

            SizedBox(height: 6.h),

            CustomText(
              text: 'Rating: ${product.rating}',
              fontSize: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}