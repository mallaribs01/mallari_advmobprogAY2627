import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // ============================================================
  // GET ALL USERS
  // ============================================================

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return {
          ...user,
          'uid': doc.id,
          'email': user['emailAddress'] ?? user['email'] ?? '',
        };
      }).toList();
    });
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage(String receiverId, String message) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in.');
    }

    final String currentUserId = currentUser.uid;

    final String currentUserEmail = currentUser.email ?? '';

    final Timestamp timestamp = Timestamp.now();

    final MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    final List<String> ids = [currentUserId, receiverId];

    ids.sort();

    final String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
          ...newMessage.toMap(),

          // Initial message state.
          'status': 'sent',
          'seen': false,
        });
  }

  // ============================================================
  // GET MESSAGES
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
    String userId,
    String otherUserId,
  ) {
    final List<String> ids = [userId, otherUserId];

    ids.sort();

    final String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ============================================================
  // MARK MESSAGES AS DELIVERED
  // ============================================================

  Future<void> markMessagesAsDelivered(String otherUserId) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      return;
    }

    final String currentUserId = currentUser.uid;

    final List<String> ids = [currentUserId, otherUserId];

    ids.sort();

    final String chatRoomId = ids.join('_');

    final snapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final status = data['status']?.toString() ?? 'sent';

      final seen = data['seen'] == true;

      // Only change SENT messages.
      // Do not overwrite messages that
      // are already SEEN.
      if (status == 'sent' && !seen) {
        batch.update(doc.reference, {'status': 'delivered'});
      }
    }

    await batch.commit();
  }

  // ============================================================
  // MARK MESSAGES AS SEEN
  // ============================================================

  Future<void> markMessagesAsSeen(String otherUserId) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      return;
    }

    final String currentUserId = currentUser.uid;

    final List<String> ids = [currentUserId, otherUserId];

    ids.sort();

    final String chatRoomId = ids.join('_');

    final snapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('seen', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'seen': true, 'status': 'seen'});
    }

    await batch.commit();
  }

  // ============================================================
  // GET UID USING EMAIL
  // ============================================================

  Future<String?> getUidByEmail(String email) async {
    final query = await _firestore
        .collection('users')
        .where('emailAddress', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return query.docs.first.data()['uid']?.toString();
  }
}
