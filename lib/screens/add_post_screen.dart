import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/post.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final post = Post(
      postId: "", // ignored in request
      userId: "", // backend should detect current user
      content: _contentController.text,
      imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      createdAt: DateTime.now(),
      likeCount: 0,
      commentCount: 0,
    );

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8080/api/posts"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true); // go back & refresh
      } else {
        throw Exception("Failed to create post");
      }
    } catch (e) {
      print("Error creating post: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error creating post")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: "Content"),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter content" : null,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL (optional)"),
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                  onPressed: _submitPost, child: const Text("Submit")),
            ],
          ),
        ),
      ),
    );
  }
}
