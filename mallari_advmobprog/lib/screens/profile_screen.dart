import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../models/user.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'cart_screen.dart';

/// Lab Activity 4 - Enhancement 3
/// The ProfileScreen gets the saved User model from UserService and renders the user's information.
/// The same userId is used when requesting the user's cart from CartService.
class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  late Future<User?> _userFuture;
  late Future<int> _cartCountFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _userFuture = _userService.getUser();
    _cartCountFuture = _getCartCount();
  }

  Future<int> _getCartCount() async {
    final carts = await CartService().getCartsByUser(widget.userId);

    if (carts.isEmpty) {
      return 0;
    }

    return carts.first.totalQuantity;
  }

  Future<void> _refresh() async {
    setState(_loadData);

    await Future.wait([_userFuture, _cartCountFuture]);
  }

  // Logout the current user and return to the Sign In screen.
  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await _userService.logout();

      if (!mounted) return;

      // Remove all previous screens and return to Sign In.
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<User?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorView(
                message:
                    'Unable to load profile.\n'
                    '${snapshot.error}',
                onRetry: () {
                  setState(_loadData);
                },
              );
            }

            final user = snapshot.data;

            if (user == null) {
              return const Center(
                child: CustomText(
                  text: 'No saved user data found.',
                  fontSize: 14,
                ),
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 28.h),
              children: [
                // User profile header.
                _buildProfileHeader(user),

                SizedBox(height: 18.h),

                // User account information.
                _buildInformationCard(user),

                SizedBox(height: 16.h),

                // Cart information based on user ID.
                _buildCartCard(user.id),

                SizedBox(height: 24.h),

                // Logout button.
                _buildLogoutButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    final fullName = '${user.firstName} ${user.lastName}'.trim();

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 46.r,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: user.image.isNotEmpty
                  ? Image.network(
                      user.image,
                      width: 88.r,
                      height: 88.r,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 48.sp,
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                    )
                  : Icon(
                      Icons.person,
                      size: 48.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
          ),

          SizedBox(height: 12.h),

          Text(
            fullName.isEmpty ? user.username : fullName,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 21.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          Text(
            '@${user.username}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard(User user) {
    return _SectionCard(
      title: 'Account Information',
      icon: Icons.person_outline,
      children: [
        _InfoRow(
          icon: Icons.badge_outlined,
          label: 'User ID',
          value: user.id.toString(),
        ),

        _InfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email.isEmpty ? 'Not provided' : user.email,
        ),

        _InfoRow(
          icon: Icons.wc_outlined,
          label: 'Gender',
          value: user.gender.isEmpty ? 'Not provided' : user.gender,
        ),

        _InfoRow(
          icon: Icons.person_outline,
          label: 'Username',
          value: user.username,
        ),
      ],
    );
  }

  Widget _buildCartCard(int userId) {
    return _SectionCard(
      title: 'My Cart',
      icon: Icons.shopping_cart_outlined,
      children: [
        FutureBuilder<int>(
          future: _cartCountFuture,
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return _InfoRow(
                icon: Icons.error_outline,
                label: 'Cart',
                value: 'Unable to load cart',
              );
            }

            return Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 25.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text:
                            '$count item'
                            '${count == 1 ? '' : 's'}',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),

                      SizedBox(height: 3.h),

                      CustomText(
                        text: 'Cart loaded using User ID $userId',
                        fontSize: 10.sp,
                      ),
                    ],
                  ),
                ),

                IconButton(
                  tooltip: 'View cart',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartScreen(userId: userId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: Icon(Icons.logout, size: 20.sp),
        label: Text(
          'Logout',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 21.sp),

                SizedBox(width: 8.w),

                CustomText(
                  text: title,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),

            SizedBox(height: 8.h),

            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp),

          SizedBox(width: 12.w),

          SizedBox(
            width: 72.w,
            child: CustomText(
              text: label,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: CustomText(
              text: value,
              fontSize: 11.sp,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48.sp),

            SizedBox(height: 12.h),

            Text(message, textAlign: TextAlign.center),

            SizedBox(height: 14.h),

            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
