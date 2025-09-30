import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/api_config.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({Key? key}) : super(key: key);

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  Future<void> _submitPost() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      final newPost = {
        "content": _contentController.text,
        "imageUrl":
        _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
      };

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/posts"), // ✅ correct endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(newPost),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true); // return success to refresh posts
      } else {
        print("Error creating post: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create post")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                hintText: "Image URL (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitPost, // ✅ no context param needed
              icon: const Icon(Icons.send),
              label: const Text("Post"),
            ),
          ],
        ),
      ),
    );
  }
}
