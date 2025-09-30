// community_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import 'post_detail_screen.dart';
import 'add_post_screen.dart';
import '../utils/api_config.dart';
import '../widgets/custom_app_bar.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  /// Fetch all posts and check if the logged-in user has liked each one
  Future<void> _fetchPosts() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/posts"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> content = data["content"];

        List<Post> loadedPosts =
        content.map((json) => Post.fromJson(json)).toList();

        // Check like status for each post
        for (var post in loadedPosts) {
          final likeResponse = await http.get(
            Uri.parse(
                "${ApiConfig.baseUrl}/api/posts/${post.postId}/likes/hasUserLiked"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          );

          if (likeResponse.statusCode == 200) {
            final bool hasLiked = json.decode(likeResponse.body);
            post.hasUserLiked = hasLiked;
          }
        }

        setState(() {
          _posts = loadedPosts;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load posts: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching posts: $e");
      setState(() => _isLoading = false);
    }
  }

  /// Toggle like/unlike
  Future<void> _toggleLike(Post post) async {
    // Optimistically update UI first
    setState(() {
      if (post.hasUserLiked) {
        post.hasUserLiked = false;
        post.likeCount = (post.likeCount > 0) ? post.likeCount - 1 : 0;
      } else {
        post.hasUserLiked = true;
        post.likeCount += 1;
      }
    });

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      if (!post.hasUserLiked) {
        // Unlike (we already toggled in UI, so check inverse)
        final response = await http.delete(
          Uri.parse("${ApiConfig.baseUrl}/api/posts/${post.postId}/likes"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode != 200 && response.statusCode != 204) {
          // Revert on failure
          setState(() {
            post.hasUserLiked = true;
            post.likeCount += 1;
          });
          print("Failed to unlike: ${response.statusCode}");
        }
      } else {
        // Like (we already toggled in UI, so check inverse)
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/api/posts/${post.postId}/likes"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          // Revert on failure
          setState(() {
            post.hasUserLiked = false;
            post.likeCount = (post.likeCount > 0) ? post.likeCount - 1 : 0;
          });
          print("Failed to like: ${response.statusCode}");
        }
      }
    } catch (e) {
      // Revert on error
      setState(() {
        if (post.hasUserLiked) {
          post.hasUserLiked = false;
          post.likeCount = (post.likeCount > 0) ? post.likeCount - 1 : 0;
        } else {
          post.hasUserLiked = true;
          post.likeCount += 1;
        }
      });
      print("Error toggling like: $e");
    }
  }

  void _navigateToPostDetail(Post post) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: post.postId),
      ),
    );

    // Refresh posts if like status changed in detail screen
    if (shouldRefresh == true) {
      _fetchPosts();
    }
  }

  void _navigateToAddPost() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPostScreen()),
    );
    if (created == true) {
      _fetchPosts(); // refresh after adding post
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Community',
        isDashboard: true,
        showActions: true,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () => _navigateToPostDetail(post),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Content
                    Text(
                      post.content,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Post Image
                    if (post.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Likes, Comments, and Date
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            post.hasUserLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => _toggleLike(post),
                        ),
                        Text("${post.likeCount}"),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment, color: Colors.grey),
                        Text("${post.commentCount}"),
                        const Spacer(),
                        Text(
                          "${post.createdAt.toLocal()}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPost,
        child: const Icon(Icons.add),
      ),
    );
  }
}