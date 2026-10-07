import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;

  const ChatDetailsScreen({
    super.key,
    required this.currentUserEmail,
    required this.tappedUser,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _msgCtrl = TextEditingController();

  final FocusNode _msgFocus = FocusNode();

  final ScrollController _scrollCtrl = ScrollController();

  final ChatService _chatService = ChatService();

  bool _isSending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage(String receiverId) async {
    final text = _msgCtrl.text.trim();

    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendMessage(receiverId, text);

      _msgCtrl.clear();

      _msgFocus.requestFocus();

      if (_scrollCtrl.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));

        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    } finally {
      if (!mounted) return;

      setState(() {
        _isSending = false;
      });
    }
  }

  // ============================================================
  // UPDATE MESSAGE STATUS
  // ============================================================

  Future<void> _updateMessageStatus(String otherUserId) async {
    try {
      // First mark messages as delivered.
      await _chatService.markMessagesAsDelivered(otherUserId);

      // Then mark them as seen.
      await _chatService.markMessagesAsSeen(otherUserId);
    } catch (_) {
      // Do not interrupt the chat UI
      // if status updating fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final currentUserId = currentUser?.uid ?? '';

    final receiverId = (widget.tappedUser['uid'] ?? '').toString();

    final firstName = (widget.tappedUser['firstName'] ?? '').toString();

    final lastName = (widget.tappedUser['lastName'] ?? '').toString();

    final username = (widget.tappedUser['username'] ?? '').toString();

    final displayName = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'
        : username.isNotEmpty
        ? username
        : 'User';

    final avatarLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19.r,
              child: Text(
                avatarLetter,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Chat', style: TextStyle(fontSize: 11.sp)),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // ==================================================
          // MESSAGES
          // ==================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatService.getMessages(currentUserId, receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading messages:\n'
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                // ==================================================
                // UPDATE DELIVERY/SEEN STATUS
                // ==================================================

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted &&
                      receiverId.isNotEmpty &&
                      currentUserId.isNotEmpty) {
                    _updateMessageStatus(receiverId);
                  }
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 55.sp),
                        SizedBox(height: 12.h),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  reverse: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 15.h,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();

                    final senderId = (data['senderId'] ?? '').toString();

                    final message = (data['message'] ?? '').toString();

                    final status = (data['status'] ?? 'sent').toString();

                    final seen = data['seen'] == true;

                    final isMe = senderId == currentUserId;

                    return _AnimatedMessageBubble(
                      key: ValueKey(docs[index].id),
                      message: message,
                      isMe: isMe,
                      status: status,
                      seen: seen,
                    );
                  },
                );
              },
            ),
          ),

          // ==================================================
          // MESSAGE INPUT
          // ==================================================
          SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      focusNode: _msgFocus,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // ==================================================
                  // SEND BUTTON
                  // ==================================================
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isSending
                        ? Container(
                            key: const ValueKey('sending'),
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Material(
                            key: const ValueKey('send'),
                            color: Theme.of(context).colorScheme.primary,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                _sendMessage(receiverId);
                              },
                              child: const SizedBox(
                                height: 48,
                                width: 48,
                                child: Icon(Icons.send, color: Colors.white),
                              ),
                            ),
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

// ============================================================
// ANIMATED MESSAGE BUBBLE
// ============================================================

class _AnimatedMessageBubble extends StatefulWidget {
  final String message;
  final bool isMe;
  final String status;
  final bool seen;

  const _AnimatedMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.status,
    required this.seen,
  });

  @override
  State<_AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<_AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;

  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: widget.isMe ? const Offset(0.15, 0) : const Offset(-0.15, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // MESSAGE STATUS WIDGET
  // ============================================================

  Widget _buildStatus() {
    if (!widget.isMe) {
      return const SizedBox.shrink();
    }

    // SENDING
    if (widget.status == 'sending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sending...',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(width: 4.w),
          SizedBox(
            height: 10,
            width: 10,
            child: const CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    // SEEN
    if (widget.seen || widget.status == 'seen') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Seen',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          SizedBox(width: 4.w),
          const Icon(Icons.done_all, size: 15, color: Colors.white),
        ],
      );
    }

    // DELIVERED
    if (widget.status == 'delivered') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delivered',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          SizedBox(width: 4.w),
          const Icon(Icons.done_all, size: 15, color: Colors.white),
        ],
      );
    }

    // SENT
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sent',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        SizedBox(width: 4.w),
        const Icon(Icons.done, size: 15, color: Colors.white),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.76,
            ),
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: widget.isMe ? primary : Colors.grey.shade300,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(widget.isMe ? 18 : 4),
                bottomRight: Radius.circular(widget.isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                  color: Colors.black.withOpacity(0.08),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: widget.isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

                // STATUS
                if (widget.isMe) ...[SizedBox(height: 4.h), _buildStatus()],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
