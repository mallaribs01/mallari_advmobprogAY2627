import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../models/user.dart';
import '../screens/newsfeed_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/custom_font.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final PageController _pageController =
      PageController();

  late List<String> _titles;

  @override
  void initState() {
    super.initState();

    _titles = [
      'CCIT Connect',
      'Notifications',
      widget.user.username,
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          user: widget.user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: FB_TEXT_COLOR_WHITE,
        backgroundColor: FB_SECONDARY,
        elevation: 2,
        title: CustomFont(
          text: _titles[_selectedIndex],
          fontSize:
              ScreenUtil().setSp(25),
          fontWeight: FontWeight.bold,
          color: FB_PRIMARY,
          fontFamily: 'Klavika',
        ),

        actions: [
          if (_selectedIndex == 2)
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: FB_PRIMARY,
              ),
              onPressed: _openSettings,
            ),
        ],
      ),

      body: PageView(
        controller: _pageController,
        children: [
          const NewsFeedScreen(),

          const NotificationScreen(),

          ProfileScreen(
            user: widget.user,
          ),
        ],
        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
          });
        },
      ),

      bottomNavigationBar:
          BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onTappedBar,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_active,
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
            ),
            label: 'Profile',
          ),
        ],

        selectedItemColor: FB_PRIMARY,
        backgroundColor: FB_SECONDARY,
        currentIndex: _selectedIndex,
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });

    _pageController.jumpToPage(value);
  }
}