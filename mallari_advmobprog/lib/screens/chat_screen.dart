import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchChatController = TextEditingController();

  final ChatService _chatService = ChatService();

  String _currentUserId = '';
  String _currentUserEmail = '';
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    setState(() {
      _currentUserId = user?.uid ?? '';
      _currentUserEmail = user?.email ?? '';
    });
  }

  @override
  void dispose() {
    _searchChatController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEARCH USER
  // ============================================================

  bool _matchesSearch(Map<String, dynamic> user) {
    if (_searchText.isEmpty) {
      return true;
    }

    final search = _searchText.toLowerCase();

    final firstName = (user['firstName'] ?? '').toString().toLowerCase();

    final lastName = (user['lastName'] ?? '').toString().toLowerCase();

    final username = (user['username'] ?? '').toString().toLowerCase();

    final email = (user['emailAddress'] ?? user['email'] ?? '')
        .toString()
        .toLowerCase();

    final fullName = '$firstName $lastName'.trim();

    return firstName.contains(search) ||
        lastName.contains(search) ||
        fullName.contains(search) ||
        username.contains(search) ||
        email.contains(search);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats'), centerTitle: true),
      body: Column(
        children: [
          SizedBox(height: 16.h),

          // ==================================================
          // SEARCH BAR
          // ==================================================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: _searchChatController,
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchChatController.clear();
                            _searchText = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // ==================================================
          // USER LIST
          // ==================================================
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Text(
                        'Error loading users:\n'
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('No users found.'));
                }

                // ==================================================
                // ENHANCEMENT 1:
                // REMOVE CURRENT LOGGED-IN USER
                // ==================================================

                final otherUsers = snapshot.data!.where((user) {
                  final uid = (user['uid'] ?? '').toString();

                  return uid.isNotEmpty && uid != _currentUserId;
                }).toList();

                // ==================================================
                // ENHANCEMENT 2:
                // SEARCH/FILTER USERS
                // ==================================================

                final filteredUsers = otherUsers.where(_matchesSearch).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, size: 60.sp),
                          SizedBox(height: 12.h),
                          Text(
                            _searchText.isEmpty
                                ? 'No other users found.'
                                : 'No users match your search.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    final uid = (user['uid'] ?? '').toString();

                    final firstName = (user['firstName'] ?? '').toString();

                    final lastName = (user['lastName'] ?? '').toString();

                    final username = (user['username'] ?? '').toString();

                    final email =
                        (user['emailAddress'] ?? user['email'] ?? 'No email')
                            .toString();

                    final displayName = '$firstName $lastName'.trim().isNotEmpty
                        ? '$firstName $lastName'
                        : username.isNotEmpty
                        ? username
                        : 'User';

                    final avatarLetter = displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?';

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 250 + (index * 40)),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 15 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        elevation: 1,
                        margin: EdgeInsets.symmetric(vertical: 5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 5.h,
                          ),
                          leading: CircleAvatar(
                            radius: 25.r,
                            child: Text(
                              avatarLetter,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                          title: CustomText(
                            text: displayName,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (username.isNotEmpty)
                                Text(
                                  '@$username',
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              Text(email, style: TextStyle(fontSize: 12.sp)),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailsScreen(
                                  currentUserEmail: _currentUserEmail,
                                  tappedUser: user,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
