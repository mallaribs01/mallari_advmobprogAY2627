import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/post_card.dart';
import 'detail_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();

    _postsFuture = _postService.getPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _postService.getPosts();
    });

    await _postsFuture;
  }

  Future<User> _loadUser(int userId) {
    return _userService.getUser(userId);
  }

  String _formatDate(String date) {
    if (date.isEmpty) {
      return 'Recently';
    }

    try {
      final parsedDate = DateTime.parse(date);

      return '${parsedDate.month}/${parsedDate.day}/${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),

                const Icon(
                  Icons.cloud_off_outlined,
                  size: 60,
                  color: Colors.grey,
                ),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    'Unable to load posts.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Please check your internet connection and try again.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: ElevatedButton.icon(
                    onPressed: _refreshPosts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ),
              ],
            );
          }

          final List<Post> posts = snapshot.data ?? [];

          // EMPTY
          if (posts.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                    'No posts found.',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final Post post = posts[index];

              return FutureBuilder<User>(
                future: _loadUser(post.userId),
                builder: (context, userSnapshot) {
                  // USER LOADING
                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return NewsFeedCard(
                      userName: 'User ${post.userId}',
                      profileImageUrl: '',
                      postContent: post.body,
                      numOfLikes: post.likes,
                      date: _formatDate(post.createdAt),
                      hasImage: '',
                    );
                  }

                  // USER ERROR
                  if (userSnapshot.hasError ||
                      !userSnapshot.hasData) {
                    return NewsFeedCard(
                      userName: 'User ${post.userId}',
                      profileImageUrl: '',
                      postContent: post.body,
                      numOfLikes: post.likes,
                      date: _formatDate(post.createdAt),
                      hasImage: '',
                    );
                  }

                  final User user = userSnapshot.data!;

                  final String userName =
                      '${user.firstName} ${user.lastName}'.trim();

                  return NewsFeedCard(
                    userName: userName.isEmpty
                        ? user.username
                        : userName,
                    profileImageUrl: user.image,
                    postContent: post.body,
                    numOfLikes: post.likes,
                    date: _formatDate(post.createdAt),
                    hasImage: '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            post: post,
                            user: user,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}