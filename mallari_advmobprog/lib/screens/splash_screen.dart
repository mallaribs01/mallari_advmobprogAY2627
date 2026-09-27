import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();

    _checkAuthentication();
  }

  // Lab Activity 4 - Enhancement 1:
  // The splash screen waits briefly, checks the saved authentication
  // token through UserService, and redirects the user to Home or Sign In.
  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final loggedIn = await _userService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      final userData = await _userService.getUserData();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home', arguments: userData);
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(28.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 118.r,
                  height: 118.r,
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/nubdexchange_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.shopping_bag_rounded,
                      size: 60.sp,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                SizedBox(height: 25.h),

                Text(
                  'Bhie Liane (Bili Yan)',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 7.h),

                Text(
                  'What is money, paper only.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                SizedBox(height: 30.h),

                SizedBox(
                  width: 30.r,
                  height: 30.r,
                  child: const CircularProgressIndicator(strokeWidth: 3),
                ),

                SizedBox(height: 12.h),

                Text(
                  'Checking your account...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
