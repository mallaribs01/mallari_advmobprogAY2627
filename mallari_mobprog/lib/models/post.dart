class Post {
  final int id;
  final int userId;
  final String body;
  final int likes;
  final int dislikes;
  final String createdAt;
  final String updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.body,
    required this.likes,
    required this.dislikes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final reactions = json['reactions'];

    int likes = 0;
    int dislikes = 0;

    if (reactions is Map<String, dynamic>) {
      likes = (reactions['likes'] as num?)?.toInt() ?? 0;
      dislikes = (reactions['dislikes'] as num?)?.toInt() ?? 0;
    } else {
      likes = (json['likes'] as num?)?.toInt() ?? 0;
      dislikes = (json['dislikes'] as num?)?.toInt() ?? 0;
    }

    return Post(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      body: json['body']?.toString() ?? '',
      likes: likes,
      dislikes: dislikes,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'body': body,
      'reactions': {
        'likes': likes,
        'dislikes': dislikes,
      },
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}