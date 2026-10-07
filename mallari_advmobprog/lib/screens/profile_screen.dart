import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../models/user.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'cart_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  late Future<_ProfileData> _profileFuture;
  late Future<int> _cartCountFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _profileFuture = _loadProfile();
    _cartCountFuture = _getCartCount();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<_ProfileData> _loadProfile() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    // Firebase account
    if (firebaseUser != null) {
      // Reload Firebase user so displayName is up to date.
      await firebaseUser.reload();

      final updatedFirebaseUser =
          firebase_auth.FirebaseAuth.instance.currentUser;

      final firebaseData = await _userService.getFirebaseUserData();

      return _ProfileData(
        type: LoginType.firebase,
        firebaseUser: updatedFirebaseUser,
        firebaseData: firebaseData,
        dummyUser: null,
      );
    }

    // DummyJSON account
    final dummyUser = await _userService.getUser();

    return _ProfileData(
      type: LoginType.dummyJson,
      firebaseUser: null,
      firebaseData: {},
      dummyUser: dummyUser,
    );
  }

  // ============================================================
  // CART
  // ============================================================

  Future<int> _getCartCount() async {
    try {
      final carts = await CartService().getCartsByUser(widget.userId);

      if (carts.isEmpty) {
        return 0;
      }

      return carts.first.totalQuantity;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    setState(() {
      _loadData();
    });

    await Future.wait([_profileFuture, _cartCountFuture]);
  }

  // ============================================================
  // UPDATE USERNAME
  // ============================================================

  Future<void> _showUpdateUsernameDialog(String currentUsername) async {
    final controller = TextEditingController(text: currentUsername);

    try {
      final newUsername = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Update Username'),
            content: TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'New Username',
                hintText: 'Enter your new username',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = controller.text.trim();

                  if (value.isEmpty) {
                    return;
                  }

                  Navigator.of(dialogContext).pop(value);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (newUsername == null ||
          newUsername.trim().isEmpty ||
          newUsername.trim() == currentUsername.trim()) {
        return;
      }

      // Update Firebase Authentication
      // and Firestore.
      await _userService.updateUsername(newUsername.trim());

      if (!mounted) return;

      // Reload the profile with the updated username.
      setState(() {
        _loadData();
      });

      // Wait for the new profile data to finish loading.
      await _profileFuture;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update username: $e')));
    } finally {
      // Dispose only after the dialog and update process
      // have completely finished.
      controller.dispose();
    }
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();

    final newPasswordController = TextEditingController();

    final confirmPasswordController = TextEditingController();

    try {
      final passwordData = await showDialog<Map<String, String>>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Change Password'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('For security, enter your current password.'),

                  const SizedBox(height: 16),

                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop({
                    'currentPassword': currentPasswordController.text,
                    'newPassword': newPasswordController.text,
                    'confirmPassword': confirmPasswordController.text,
                  });
                },
                child: const Text('Change'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (passwordData == null) {
        return;
      }

      final currentPassword = passwordData['currentPassword'] ?? '';

      final newPassword = passwordData['newPassword'] ?? '';

      final confirmPassword = passwordData['confirmPassword'] ?? '';

      if (currentPassword.isEmpty ||
          newPassword.isEmpty ||
          confirmPassword.isEmpty) {
        _showMessage('Please complete all password fields.');
        return;
      }

      if (newPassword.length < 6) {
        _showMessage('New password must be at least 6 characters.');
        return;
      }

      if (newPassword != confirmPassword) {
        _showMessage('New passwords do not match.');
        return;
      }

      await _userService.resetPasswordFromCurrentPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      _showMessage('Password changed successfully!');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to change password: $e');
    } finally {
      // Dispose only after the dialog has completely
      // finished using the controllers.
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to permanently delete '
            'your Firebase account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _userService.deleteAccount();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to delete account: $e');
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

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
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
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
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        await _userService.signOut();
      } else {
        await _userService.logout();
      }

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      if (!mounted) return;

      _showMessage('Logout failed: $e');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_ProfileData>(
          future: _profileFuture,
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
                  setState(() {
                    _loadData();
                  });
                },
              );
            }

            final profile = snapshot.data;

            if (profile == null) {
              return const Center(
                child: CustomText(text: 'No user data found.', fontSize: 14),
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 28.h),
              children: [
                _buildProfileHeader(profile),

                SizedBox(height: 18.h),

                _buildInformationCard(profile),

                SizedBox(height: 16.h),

                _buildAccountActions(profile),

                SizedBox(height: 16.h),

                _buildCartCard(widget.userId),

                SizedBox(height: 24.h),

                _buildLogoutButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(_ProfileData profile) {
    String name;
    String username;
    String email;
    String image = '';

    if (profile.type == LoginType.firebase) {
      final firebaseUser = profile.firebaseUser!;

      final data = profile.firebaseData;

      name =
          '${data['firstName'] ?? ''} '
                  '${data['lastName'] ?? ''}'
              .trim();

      username = data['username']?.toString() ?? firebaseUser.displayName ?? '';

      email = firebaseUser.email ?? '';
    } else {
      final user = profile.dummyUser!;

      name = '${user.firstName} ${user.lastName}'.trim();

      username = user.username;
      email = user.email;
      image = user.image;
    }

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
              child: image.isNotEmpty
                  ? Image.network(
                      image,
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
            name.isEmpty ? username : name,
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
            username.isEmpty ? email : '@$username',
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

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard(_ProfileData profile) {
    if (profile.type == LoginType.firebase) {
      final data = profile.firebaseData;
      final user = profile.firebaseUser!;

      return _SectionCard(
        title: 'Firebase Account',
        icon: Icons.local_fire_department,
        children: [
          _InfoRow(icon: Icons.badge_outlined, label: 'UID', value: user.uid),

          _InfoRow(
            icon: Icons.person_outline,
            label: 'Username',
            value:
                data['username']?.toString() ??
                user.displayName ??
                'Not provided',
          ),

          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email ?? 'Not provided',
          ),

          _InfoRow(
            icon: Icons.person,
            label: 'Name',
            value:
                '${data['firstName'] ?? ''} '
                        '${data['lastName'] ?? ''}'
                    .trim(),
          ),

          _InfoRow(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: data['age']?.toString() ?? 'Not provided',
          ),

          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Contact',
            value: data['contactNo']?.toString() ?? 'Not provided',
          ),
        ],
      );
    }

    final user = profile.dummyUser!;

    return _SectionCard(
      title: 'DummyJSON Account',
      icon: Icons.api,
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

  // ============================================================
  // ACCOUNT ACTIONS
  // ============================================================

  Widget _buildAccountActions(_ProfileData profile) {
    if (profile.type != LoginType.firebase) {
      return const SizedBox.shrink();
    }

    final data = profile.firebaseData;

    final username =
        data['username']?.toString() ?? profile.firebaseUser?.displayName ?? '';

    return _SectionCard(
      title: 'Account Settings',
      icon: Icons.settings_outlined,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Update Username'),
          subtitle: const Text('Change your Firebase username'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showUpdateUsernameDialog(username);
          },
        ),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock_reset),
          title: const Text('Change Password'),
          subtitle: const Text('Update your Firebase password'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showChangePasswordDialog,
        ),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.delete_forever,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text('Permanently delete your Firebase account'),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          onTap: _deleteAccount,
        ),
      ],
    );
  }

  // ============================================================
  // CART CARD
  // ============================================================

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

  // ============================================================
  // LOGOUT BUTTON
  // ============================================================

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

// ================================================================
// PROFILE DATA
// ================================================================

enum LoginType { firebase, dummyJson }

class _ProfileData {
  final LoginType type;
  final firebase_auth.User? firebaseUser;
  final Map<String, dynamic> firebaseData;
  final User? dummyUser;

  _ProfileData({
    required this.type,
    required this.firebaseUser,
    required this.firebaseData,
    required this.dummyUser,
  });
}

// ================================================================
// SECTION CARD
// ================================================================

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

// ================================================================
// INFO ROW
// ================================================================

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
              text: value.isEmpty ? 'Not provided' : value,
              fontSize: 11.sp,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ERROR VIEW
// ================================================================

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
