import 'dart:convert';

import 'package:http/http.dart';

import '../constants.dart';
import '../models/comment.dart';

class CommentService {
  // ENHANCEMENT 3
  // Get all comments belonging to a post.
  Future<List<Comment>> getComments(int postId) async {
    final uri = Uri.parse(
      '$HOST/posts/$postId/comments',
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

      final List commentsJson =
          data['comments'] ?? [];

      return commentsJson
          .map(
            (comment) => Comment.fromJson(
              Map<String, dynamic>.from(comment),
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load comments: ${response.statusCode}',
    );
  }

  // ENHANCEMENT 3
  // Add a new comment.
  Future<Comment> addComment({
    required String body,
    required int postId,
    required int userId,
  }) async {
    final uri = Uri.parse(
      '$HOST/comments/add',
    );

    final response = await post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'body': body,
        'postId': postId,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      return Comment.fromJson(data);
    }

    throw Exception(
      'Failed to add comment: ${response.statusCode}',
    );
  }
}