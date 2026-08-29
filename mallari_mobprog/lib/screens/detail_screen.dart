import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/comment_service.dart';
import '../widgets/custom_font.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  final User user;

  const DetailScreen({
    super.key,
    required this.post,
    required this.user,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int likes;

  bool isLiked = false;
  bool isAddingComment = false;

  final TextEditingController _commentController =
      TextEditingController();

  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();

    likes = widget.post.likes;

    _commentsFuture = CommentService().getComments(
      widget.post.id,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void toggleLike() {
    setState(() {
      if (isLiked) {
        if (likes > 0) {
          likes--;
        }

        isLiked = false;
      } else {
        likes++;
        isLiked = true;
      }
    });
  }

  Future<void> _addComment() async {
    final body = _commentController.text.trim();

    if (body.isEmpty) {
      return;
    }

    setState(() {
      isAddingComment = true;
    });

    try {
      final Comment newComment =
          await CommentService().addComment(
        body: body,
        postId: widget.post.id,
        userId: widget.user.id,
      );

      _commentController.clear();

      setState(() {
        _commentsFuture = _commentsFuture.then(
          (comments) {
            return [
              ...comments,
              newComment,
            ];
          },
        );
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Comment added successfully!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to add comment.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAddingComment = false;
        });
      }
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) {
      return 'Recently';
    }

    try {
      final parsed = DateTime.parse(date);

      return '${parsed.month}/${parsed.day}/${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  Widget _userImage(
    String image,
    double radius,
  ) {
    final theme = Theme.of(context);

    final Color imageBackground =
        theme.brightness == Brightness.dark
            ? Colors.grey[800]!
            : Colors.grey[200]!;

    if (image.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: imageBackground,
        child: Icon(
          Icons.person,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: imageBackground,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: image,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const CircularProgressIndicator(
            strokeWidth: 2,
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _commentItem(Comment comment) {
    final theme = Theme.of(context);

    final Color textColor =
        theme.textTheme.bodyLarge?.color ??
            theme.colorScheme.onSurface;

    final Color secondaryTextColor =
        theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.black54;

    final Color commentBackground =
        theme.brightness == Brightness.dark
            ? Colors.grey[800]!
            : Colors.grey[200]!;

    final String name =
        comment.user.fullName.isNotEmpty
            ? comment.user.fullName
            : comment.user.username;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: commentBackground,
            child: Icon(
              Icons.person,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: commentBackground,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    comment.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Text(
                        '${comment.likes} likes',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ============================================================
    // THEME COLORS
    // ============================================================

    final Color textColor =
        theme.textTheme.bodyLarge?.color ??
            theme.colorScheme.onSurface;

    final Color secondaryTextColor =
        theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.black54;

    final Color iconColor =
        theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.black54;

    final Color dividerColor =
        theme.dividerColor;

    final Color commentBackground =
        theme.brightness == Brightness.dark
            ? Colors.grey[800]!
            : Colors.grey[200]!;

    // Keep Like format the same.
    // Only the color changes.
    final Color likeColor =
        isLiked
            ? Colors.red
            : secondaryTextColor;

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: FB_SECONDARY,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: FB_PRIMARY,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: CustomFont(
          text: 'Post',
          fontSize: ScreenUtil().setSp(18),
          fontWeight: FontWeight.bold,
          color: FB_PRIMARY,
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ========================================================
                  // USER HEADER
                  // ========================================================

                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        _userImage(
                          widget.user.image,
                          25,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.user.firstName} ${widget.user.lastName}',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 17,
                                  color: textColor,
                                ),
                              ),

                              Row(
                                children: [
                                  Text(
                                    _formatDate(
                                      widget.post.createdAt,
                                    ),
                                    style: TextStyle(
                                      color:
                                          secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(width: 5),

                                  Icon(
                                    Icons.public,
                                    size: 14,
                                    color:
                                        secondaryTextColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons.more_horiz,
                          color: iconColor,
                        ),
                      ],
                    ),
                  ),

                  // ========================================================
                  // POST CONTENT
                  // ========================================================

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Text(
                      widget.post.body,
                      style: TextStyle(
                        fontSize: 17,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Divider(
                    color: dividerColor,
                  ),

                  // ========================================================
                  // LIKE / COMMENT / SHARE
                  // ========================================================

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Row(
                      children: [
                        // LIKE
                        Expanded(
                          child: TextButton.icon(
                            onPressed: toggleLike,
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: likeColor,
                            ),
                            label: Text(
                              likes.toString(),
                              style: TextStyle(
                                color: likeColor,
                              ),
                            ),
                          ),
                        ),

                        // COMMENT
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons
                                  .mode_comment_outlined,
                              color: iconColor,
                            ),
                            label: Text(
                              'Comment',
                              style: TextStyle(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ),

                        // SHARE
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.ios_share_outlined,
                              color: iconColor,
                            ),
                            label: Text(
                              'Share',
                              style: TextStyle(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    color: dividerColor,
                  ),

                  // ========================================================
                  // COMMENTS TITLE
                  // ========================================================

                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),

                  // ========================================================
                  // COMMENTS
                  // ========================================================

                  FutureBuilder<List<Comment>>(
                    future: _commentsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding:
                              const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Unable to load comments.',
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      }

                      final comments =
                          snapshot.data ?? [];

                      if (comments.isEmpty) {
                        return Padding(
                          padding:
                              const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No comments yet.',
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: comments
                            .map(_commentItem)
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ============================================================
          // ADD COMMENT BAR
          // ============================================================

          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      theme.brightness ==
                              Brightness.dark
                          ? 0.3
                          : 0.1,
                    ),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _userImage(
                    widget.user.image,
                    18,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) =>
                          _addComment(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Write a comment...',
                        hintStyle: TextStyle(
                          color: secondaryTextColor,
                        ),
                        filled: true,
                        fillColor:
                            commentBackground,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                          borderSide:
                              BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  IconButton(
                    onPressed:
                        isAddingComment
                            ? null
                            : _addComment,
                    icon: isAddingComment
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color:
                                theme.colorScheme.primary,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
