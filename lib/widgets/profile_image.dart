import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileImage extends StatelessWidget {
  final double size;
  final bool isEditable;
  final VoidCallback? onTap;

  const ProfileImage({
    Key? key,
    this.size = 60,
    this.isEditable = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    Widget imageWidget;

    if (authProvider.profileImageBytes != null) {
      // Image fetched from backend
      imageWidget = Image.memory(
        authProvider.profileImageBytes!,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    } else if (authProvider.user?.profilePicUrl != null &&
        authProvider.user!.profilePicUrl!.isNotEmpty) {
      // Fallback to network URL
      imageWidget = Image.network(
        authProvider.user!.profilePicUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, size: size / 2, color: Colors.grey);
        },
      );
    } else {
      imageWidget = Icon(Icons.person, size: size / 2, color: Colors.grey);
    }

    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          color: Colors.grey[200],
        ),
        child: ClipOval(child: imageWidget),
      ),
    );
  }
}