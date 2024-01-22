import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostScreen extends StatefulWidget {
  final String hikeId;
  final String userId;

  const CreatePostScreen({Key? key, required this.hikeId, required this.userId}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();

  void _createPost() async {
    try {
      // Get current timestamp
      DateTime now = DateTime.now();

      // Create a new post
      await FirebaseFirestore.instance.collection('hikingTrails').doc(widget.hikeId).collection('posts').add({
        'content': _contentController.text,
        'hikeId': widget.hikeId,
        'userId': widget.userId,
        'timestamp': now,
        // Add other fields as needed (likes, imageUrls, etc.)
      });

      // Clear the text field after posting
      _contentController.clear();

      if (!mounted) return;

      // Optionally, you can navigate back to the posts screen
      Navigator.pop(context);
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              textAlignVertical: TextAlignVertical.top,
              textAlign: TextAlign.start,
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Post Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createPost,
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
