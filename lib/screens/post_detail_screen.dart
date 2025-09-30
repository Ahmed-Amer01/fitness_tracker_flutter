import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../utils/api_config.dart';

class Comment {
  final String commentId;
  final String content;
  final String userId;
  final String username;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.content,
    required this.userId,
    required this.username,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // Extract userId - can be direct field or nested in user object
    String userId = '';
    if (json['userId'] != null) {
      userId = json['userId'].toString();
    } else if (json['user'] != null && json['user']['userId'] != null) {
      userId = json['user']['userId'].toString();
    } else if (json['user'] != null && json['user']['id'] != null) {
      userId = json['user']['id'].toString();
    }

    // Extract username - can be direct field or nested in user object
    String username = 'Anonymous';
    if (json['username'] != null && json['username'].toString().isNotEmpty) {
      username = json['username'];
    } else if (json['user'] != null && json['user']['username'] != null && json['user']['username'].toString().isNotEmpty) {
      username = json['user']['username'];
    } else if (json['user'] != null && json['user']['name'] != null && json['user']['name'].toString().isNotEmpty) {
      username = json['user']['name'];
    } else {
      // If no username found, use "User {userId}" as fallback
      username = userId.isNotEmpty ? 'User $userId' : 'Anonymous';
    }

    return Comment(
      commentId: json['commentId']?.toString() ?? json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      userId: userId,
      username: username,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isLoadingComments = true;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasLikeChanged = false;

  @override
  void initState() {
    super.initState();
    _fetchPostDetail();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchPostDetail() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/posts/${widget.postId}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Post detail response: ${response.statusCode}");
      print("Post detail body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check like status
        final likeResponse = await http.get(
          Uri.parse(
              "${ApiConfig.baseUrl}/api/posts/${widget.postId}/likes/hasUserLiked"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Like status response: ${likeResponse.statusCode}");
        print("Like status body: ${likeResponse.body}");

        setState(() {
          _post = Post.fromJson(data);
          if (likeResponse.statusCode == 200) {
            _post!.hasUserLiked = json.decode(likeResponse.body);
          }
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load post");
      }
    } catch (e) {
      print("Error fetching post: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchComments() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/posts/${widget.postId}/comments"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Comments response: ${response.statusCode}");
      print("Comments body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> commentsData;

        // Handle different response formats
        if (responseData is List) {
          commentsData = responseData;
        } else if (responseData is Map && responseData.containsKey('content')) {
          commentsData = responseData['content'];
        } else if (responseData is Map && responseData.containsKey('comments')) {
          commentsData = responseData['comments'];
        } else {
          commentsData = [];
        }

        print("Parsed comments count: ${commentsData.length}");

        setState(() {
          _comments = commentsData.map((json) => Comment.fromJson(json)).toList();
          _isLoadingComments = false;
        });
      } else {
        throw Exception("Failed to load comments");
      }
    } catch (e) {
      print("Error fetching comments: $e");
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;

    // Mark that like status changed
    _hasLikeChanged = true;

    // Optimistically update UI
    setState(() {
      if (_post!.hasUserLiked) {
        _post!.hasUserLiked = false;
        _post!.likeCount = (_post!.likeCount > 0) ? _post!.likeCount - 1 : 0;
      } else {
        _post!.hasUserLiked = true;
        _post!.likeCount += 1;
      }
    });

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      if (!_post!.hasUserLiked) {
        // Unlike
        final response = await http.delete(
          Uri.parse("${ApiConfig.baseUrl}/api/posts/${widget.postId}/likes"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Unlike response: ${response.statusCode}");

        if (response.statusCode != 200 && response.statusCode != 204) {
          // Revert on failure
          setState(() {
            _post!.hasUserLiked = true;
            _post!.likeCount += 1;
          });
          _hasLikeChanged = false;
        }
      } else {
        // Like
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/api/posts/${widget.postId}/likes"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("Like response: ${response.statusCode}");

        if (response.statusCode != 200 && response.statusCode != 201) {
          // Revert on failure
          setState(() {
            _post!.hasUserLiked = false;
            _post!.likeCount = (_post!.likeCount > 0) ? _post!.likeCount - 1 : 0;
          });
          _hasLikeChanged = false;
        }
      }
    } catch (e) {
      // Revert on error
      setState(() {
        if (_post!.hasUserLiked) {
          _post!.hasUserLiked = false;
          _post!.likeCount = (_post!.likeCount > 0) ? _post!.likeCount - 1 : 0;
        } else {
          _post!.hasUserLiked = true;
          _post!.likeCount += 1;
        }
      });
      _hasLikeChanged = false;
      print("Error toggling like: $e");
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/posts/${widget.postId}/comments"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"content": _commentController.text.trim()}),
      );

      print("Add comment response: ${response.statusCode}");
      print("Add comment body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _commentController.clear();
        // Refresh comments to get the new one
        await _fetchComments();
        // Update comment count
        if (_post != null) {
          setState(() {
            _post!.commentCount += 1;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comment added successfully")),
        );
      } else {
        throw Exception("Failed to add comment: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add comment: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await http.delete(
        Uri.parse(
            "${ApiConfig.baseUrl}/api/posts/${widget.postId}/comments/$commentId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Delete comment response: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _fetchComments();
        // Update comment count
        if (_post != null) {
          setState(() {
            _post!.commentCount =
            (_post!.commentCount > 0) ? _post!.commentCount - 1 : 0;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comment deleted successfully")),
        );
      } else {
        throw Exception("Failed to delete comment");
      }
    } catch (e) {
      print("Error deleting comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete comment")),
      );
    }
  }

  void _showDeleteConfirmation(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteComment(commentId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).user?.id;

    return WillPopScope(
      onWillPop: () async {
        // Return true if like status changed to trigger refresh in community screen
        Navigator.pop(context, _hasLikeChanged);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Post Detail")),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _post == null
            ? const Center(child: Text("Post not found"))
            : Column(
          children: [
            // Post Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Image
                    if (_post!.imageUrl != null)
                      Image.network(
                        _post!.imageUrl!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post Content
                          Text(
                            _post!.content,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),

                          // Like and Comment Count
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _post!.hasUserLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: _toggleLike,
                              ),
                              Text("${_post!.likeCount}"),
                              const SizedBox(width: 16),
                              const Icon(Icons.comment,
                                  color: Colors.grey),
                              const SizedBox(width: 4),
                              Text("${_post!.commentCount}"),
                            ],
                          ),

                          const Divider(),

                          Text(
                            "Posted at: ${_post!.createdAt.toLocal()}",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),

                          const SizedBox(height: 16),

                          // Comments Section
                          const Text(
                            "Comments",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          _isLoadingComments
                              ? const Center(
                              child: CircularProgressIndicator())
                              : _comments.isEmpty
                              ? const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 16),
                            child: Text(
                              "No comments yet. Be the first to comment!",
                              style: TextStyle(
                                  color: Colors.grey),
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment =
                              _comments[index];
                              final isCurrentUser =
                                  comment.userId ==
                                      currentUserId;

                              return Card(
                                margin: const EdgeInsets
                                    .symmetric(vertical: 4),
                                child: Padding(
                                  padding:
                                  const EdgeInsets.all(
                                      12),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            comment.username,
                                            style:
                                            const TextStyle(
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (isCurrentUser)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors
                                                    .red,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _showDeleteConfirmation(
                                                      comment
                                                          .commentId),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height: 4),
                                      Text(comment.content),
                                      const SizedBox(
                                          height: 4),
                                      Text(
                                        "${comment.createdAt.toLocal()}",
                                        style:
                                        const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Comment Input
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: "Write a comment...",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.blue),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}