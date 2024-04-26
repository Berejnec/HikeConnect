import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  final String hikeId;
  final String userId;

  const CreatePostScreen({Key? key, required this.hikeId, required this.userId}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  List<String> imageUrls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adauga postare'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(8),
              TextFormField(
                textAlignVertical: TextAlignVertical.top,
                textAlign: TextAlign.start,
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Descriere'),
                maxLines: 2,
              ),
              const Gap(16),
              Row(
                children: [
                  IconButton(
                    color: HikeColor.infoDarkColor,
                    onPressed: () async {
                      ImagePicker imagePicker = ImagePicker();
                      XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                      if (file == null) return;

                      try {
                        Reference referenceRoot = FirebaseStorage.instance.ref();
                        Reference referenceDirImages = referenceRoot.child('post_images');
                        Reference referenceImageToUpload = referenceDirImages.child(DateTime.now().millisecondsSinceEpoch.toString());

                        await referenceImageToUpload.putFile(File(file.path));
                        String imageUrl = await referenceImageToUpload.getDownloadURL();

                        if (!mounted) return;
                        setState(() {
                          imageUrls.add(imageUrl);
                        });
                      } catch (error) {
                        print(error);
                      }
                    },
                    icon: const Icon(Icons.image),
                    padding: const EdgeInsets.all(12.0),
                  ),
                  IconButton(
                    color: HikeColor.infoDarkColor,
                    onPressed: () async {
                      ImagePicker imagePicker = ImagePicker();
                      XFile? file = await imagePicker.pickImage(source: ImageSource.camera);

                      if (file == null) return;

                      try {
                        Reference referenceRoot = FirebaseStorage.instance.ref();
                        Reference referenceDirImages = referenceRoot.child('post_images');
                        Reference referenceImageToUpload = referenceDirImages.child(DateTime.now().millisecondsSinceEpoch.toString());

                        await referenceImageToUpload.putFile(File(file.path));
                        String imageUrl = await referenceImageToUpload.getDownloadURL();

                        if (!mounted) return;
                        setState(() {
                          imageUrls.add(imageUrl);
                        });
                      } catch (error) {
                        print(error);
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    padding: const EdgeInsets.all(12.0),
                  ),
                ],
              ),
              const Gap(16),
              if (imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.network(
                    imageUrls[0],
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              const Gap(32),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FilledButton(
                  onPressed: _createPost,
                  child: const Text(
                    'Posteaza',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    try {
      DateTime now = DateTime.now();

      print({
        'content': _contentController.text,
        'imageUrls': imageUrls,
        'hikeId': widget.hikeId,
        'userId': widget.userId,
        'timestamp': now,
        // Add other fields as needed (likes, etc.)
      });

      if (_contentController.text.isNotEmpty) {
        await FirebaseFirestore.instance.collection('hikingTrails').doc(widget.hikeId).collection('posts').add({
          'content': _contentController.text,
          'imageUrls': imageUrls,
          'hikeId': widget.hikeId,
          'userId': widget.userId,
          'timestamp': now,
          // Add other fields as needed (likes, etc.)
        });

        _contentController.clear();
        imageUrls.clear();
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error creating post: $e');
    }
  }
}
