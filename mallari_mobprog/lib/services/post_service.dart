import 'dart:convert';

import 'package:http/http.dart';

import '../constants.dart';
import '../models/post.dart';

class PostService {
  Future<List<Post>> getPosts({
    int limit = 30,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '$HOST/posts?limit=$limit&skip=$skip',
    );

    final response = await get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final List postsJson = data['posts'] ?? [];

      return postsJson
          .map(
            (post) => Post.fromJson(
              Map<String, dynamic>.from(post),
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load posts: ${response.statusCode}',
    );
  }

  // ENHANCEMENT 2
  // Get posts belonging to a specific user.
  Future<List<Post>> getPostsByUser(int userId) async {
    final uri = Uri.parse(
      '$HOST/posts/user/$userId',
    );

    final response = await get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final List postsJson = data['posts'] ?? [];

      return postsJson
          .map(
            (post) => Post.fromJson(
              Map<String, dynamic>.from(post),
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load user posts: ${response.statusCode}',
    );
  }
}