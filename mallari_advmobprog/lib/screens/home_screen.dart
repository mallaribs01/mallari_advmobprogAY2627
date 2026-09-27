import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'product_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const HomeScreen({super.key, this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  // Gets the logged-in user's ID.
  // The default value of 1 keeps the app working if no user data
  // is provided.
  int get userId {
    return widget.userData?['id'] ?? 1;
  }

  // Gets the logged-in user's username.
  String get username {
    return widget.userData?['username'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
          title: (_selectedIndex == 0)
              ? Image.asset('assets/images/nubdexchange_logo.png', scale: 11.sp)
              : CustomText(
                  text: (_selectedIndex == 1)
                      ? 'Cart'
                      : (_selectedIndex == 2)
                      ? 'Profile'
                      : 'Home',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),

        // Displays the selected screen.
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: <Widget>[
            ProductScreen(userId: userId),

            CartScreen(userId: userId),

            // Lab Activity 4 - Enhancement 3:
            // Render the saved User model in the ProfileScreen
            // and pass the same userId so the user's cart can be loaded.
            ProfileScreen(userId: userId),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),

        // Bottom navigation for Shop, Cart, and Profile.
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),

        // Chat button is hidden when Cart is selected.
        floatingActionButton: _selectedIndex == 1
            ? null
            : FloatingActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Chat')));
                },
                child: const Icon(Icons.chat),
              ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // Changes the selected navigation page.
  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });

    _pageController.jumpToPage(value);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
