import 'dart:convert';

class Post {
  final String postId;
  final String userId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  int likeCount;
  int commentCount;
  bool hasUserLiked;

  Post({
    required this.postId,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    this.hasUserLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      hasUserLiked: json['hasUserLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "content": content,
      "imageUrl": imageUrl,
    };
  }
}
