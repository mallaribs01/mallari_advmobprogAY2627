import '../widgets/custom_info.dart' as notif;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Background color that automatically changes
    // depending on light/dark mode.
    final Color backgroundColor = theme.scaffoldBackgroundColor;

    // Divider color that automatically adapts
    // to the current theme.
    final Color dividerColor = theme.dividerColor;

    return Container(
      color: backgroundColor,
      width: ScreenUtil().screenWidth,
      child: ListView(
        children: [
          const notif.Notification(
            name: 'Isabel Conklin',
            post: '2d ago',
            description: 'Commented on a post you follow.',
            comment: 'YOU LOOK GORG! ✨ MERRY CHRISTMAS, PRETTY! 🩷',
            hasImage: 'assets/images/christmas_post.jpg',
            profileImageUrl: 'assets/images/belly.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Isabel Conklin',
            post: '2d ago',
            description: 'Reacted ❤️ to your photo.',
            comment: '',
            hasImage: 'assets/images/christmas_post.jpg',
            profileImageUrl: 'assets/images/belly.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Conrad Fisher',
            post: '6d ago',
            description: 'Reacted ❤️ to your photo.',
            comment: '',
            hasImage: 'assets/images/christmas_post.jpg',
            profileImageUrl: 'assets/images/conrad.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Conrad Fisher',
            post: '1w ago',
            description: 'Mentioned you in a comment.',
            comment: 'Merry Christmas, Bherliane! ❤️',
            hasImage: 'assets/images/christmas_post.jpg',
            profileImageUrl: 'assets/images/conrad.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Jeremiah Fisher',
            post: '3d ago',
            description: 'Commented on your post.',
            comment:
                'Merry Christmas, sending love to you and your family! ❤️❤️❤️',
            hasImage: 'assets/images/christmas_post.jpg',
            profileImageUrl: 'assets/images/jeremiah.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Jeremiah Fisher',
            post: '3d ago',
            description: 'Reacted ❤️ to your photo.',
            comment: '',
            hasImage: 'assets/images/christmas_post.jpg',
            profileImageUrl: 'assets/images/jeremiah.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Hannah Padilla',
            post: '3d ago',
            description: 'Reacted ❤️ to your post.',
            comment: '',
            hasImage: 'assets/images/christmas_post.jpg',
            profileImageUrl: 'assets/images/hannah.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Skye Rumbawa',
            post: '1 week ago',
            description: 'Reacted ❤️ to your post.',
            comment: '',
            hasImage: 'assets/images/christmas_post.jpg',
            profileImageUrl: 'assets/images/skye.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Isabel Conklin',
            post: '1 week ago',
            description: 'Commented on your post.',
            comment: 'Come over! Lets watch TSITP!!',
            profileImageUrl: 'assets/images/belly.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Skye Rumbawa',
            post: '2 weeks ago',
            description: 'Commented on your post.',
            comment: 'Merry Christmas, i love you!',
            hasImage: 'assets/images/christmas_post.jpg',
            profileImageUrl: 'assets/images/skye.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Conrad Fisher',
            post: '2 weeks ago',
            description: 'Reacted ❤️ to your post.',
            comment: '',
            hasImage: 'assets/images/nu-manila.png',
            profileImageUrl: 'assets/images/conrad.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Jl Limjoco',
            post: '2 weeks ago',
            description: 'Reacted ❤️ to your post.',
            comment: '',
            hasImage: 'assets/images/christmas_post.jpg',
            profileImageUrl: 'assets/images/bretman.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Hannah Padilla',
            post: '2 weeks ago',
            description: 'Mentioned you in a comment.',
            comment: 'Accla pano ba i2',
            profileImageUrl: 'assets/images/hannah.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Conrad Fisher',
            post: '2 weeks ago',
            description: 'Reacted ❤️ to your post.',
            comment: '',
            hasImage: 'assets/images/bherliane.jpg',
            profileImageUrl: 'assets/images/conrad.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Jeremiah Fisher',
            post: '2 weeks ago',
            description: 'Reacted ❤️ to your post.',
            comment: '',
            hasImage: 'assets/images/bherliane.jpg',
            profileImageUrl: 'assets/images/jeremiah.jpg',
          ),

          Divider(color: dividerColor),

          const notif.Notification(
            name: 'Conrad Fisher',
            post: '6d ago',
            description: 'Commented on your post.',
            comment: '🔥🔥🔥',
            hasImage: 'assets/images/bherliane.jpg',
            profileImageUrl: 'assets/images/conrad.jpg',
            date: '6d ago',
          ),

          Divider(color: dividerColor),
        ],
      ),
    );
  }
}
