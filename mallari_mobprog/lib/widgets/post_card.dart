import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import 'custom_font.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = FB_DARK_PRIMARY,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsFeedCard extends StatefulWidget {
  final String userName;
  final String postContent;
  final String date;
  final int numOfLikes;
  final String hasImage;
  final VoidCallback? onTap;
  final String profileImageUrl;
  final bool isAdvertisement;

  const NewsFeedCard({
    super.key,
    required this.userName,
    required this.postContent,
    required this.date,
    this.numOfLikes = 0,
    this.hasImage = '',
    this.profileImageUrl = '',
    this.onTap,
    this.isAdvertisement = false,
  });

  @override
  State<NewsFeedCard> createState() => _NewsFeedCardState();
}

class _NewsFeedCardState extends State<NewsFeedCard> {
  late int likes;

  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    likes = widget.numOfLikes;
  }

  void toggleLike() {
    setState(() {
      if (isLiked) {
        likes--;
        isLiked = false;
      } else {
        likes++;
        isLiked = true;
      }
    });
  }

  Widget _profileImage(double radius) {
    if (widget.profileImageUrl.isEmpty) {
      return CircleAvatar(radius: radius, child: const Icon(Icons.person));
    }

    if (widget.profileImageUrl.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.profileImageUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const CircularProgressIndicator(strokeWidth: 2),
            errorWidget: (context, url, error) => const Icon(Icons.person),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(widget.profileImageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Main text color.
    // Automatically changes depending on light/dark mode.
    final Color textColor =
        theme.textTheme.bodyLarge?.color ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black);

    // Secondary text color.
    // This is shared by Like, Comment, and Share.
    final Color secondaryTextColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;

    // Comment input background.
    final Color commentBackground = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[200]!;

    // LIKE COLOR
    //
    // Not liked:
    //   Same color as Comment and Share.
    //
    // Liked:
    //   Red.
    final Color likeColor = isLiked ? Colors.red : secondaryTextColor;

    return Card(
      margin: EdgeInsets.all(10.sp),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(10.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // USER HEADER
              Row(
                children: [
                  _profileImage(20),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomFont(
                          text: widget.userName,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),

                        Row(
                          children: [
                            CustomFont(
                              text: widget.date,
                              fontSize: 12.sp,
                              color: secondaryTextColor,
                            ),

                            SizedBox(width: 3.w),

                            Icon(
                              Icons.public,
                              color: secondaryTextColor,
                              size: 15.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Icon(Icons.more_horiz, color: textColor),
                ],
              ),

              SizedBox(height: 8.h),

              // POST CONTENT
              CustomFont(
                text: widget.postContent,
                fontSize: 13.sp,
                color: textColor,
              ),

              // POST IMAGE
              if (widget.hasImage.isNotEmpty) ...[
                SizedBox(height: 10.h),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    widget.hasImage,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image)),
                      );
                    },
                  ),
                ),
              ],

              SizedBox(height: 10.h),

              // ACTION BUTTONS
              Row(
                children: [
                  // LIKE
                  ActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_outline,
                    label: likes == 0 ? 'Like' : likes.toString(),
                    onTap: toggleLike,
                    color: likeColor,
                  ),

                  // COMMENT
                  ActionButton(
                    icon: Icons.mode_comment_outlined,
                    label: 'Comment',
                    onTap: () {
                      widget.onTap?.call();
                    },
                    color: secondaryTextColor,
                  ),

                  // SHARE
                  ActionButton(
                    icon: Icons.ios_share,
                    label: 'Share',
                    onTap: () {},
                    color: secondaryTextColor,
                  ),
                ],
              ),

              Divider(color: secondaryTextColor.withOpacity(0.25)),

              // COMMENT INPUT PREVIEW
              Row(
                children: [
                  _profileImage(15),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10.w),
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: commentBackground,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.centerLeft,
                      child: CustomFont(
                        text: 'Write a comment...',
                        fontSize: 11.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // VIEW COMMENTS
              GestureDetector(
                onTap: () {
                  widget.onTap?.call();
                },
                child: CustomFont(
                  text: 'View comments',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
