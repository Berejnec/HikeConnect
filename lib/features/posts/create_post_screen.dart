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
  final ImagePicker _imagePicker = ImagePicker();
  bool isUploading = false;

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage();

    if (pickedFiles == null) return;

    setState(() {
      isUploading = true;
    });

    for (var file in pickedFiles) {
      try {
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirImages = referenceRoot.child('post_images');
        Reference referenceImageToUpload = referenceDirImages.child(DateTime.now().millisecondsSinceEpoch.toString());

        await referenceImageToUpload.putFile(File(file.path));
        String imageUrl = await referenceImageToUpload.getDownloadURL();

        setState(() {
          imageUrls.add(imageUrl);
        });
      } catch (error) {
        print(error);
      }
    }

    setState(() {
      isUploading = false;
    });
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('post_images');
      Reference referenceImageToUpload = referenceDirImages.child(DateTime.now().millisecondsSinceEpoch.toString());

      await referenceImageToUpload.putFile(File(photo.path));
      String imageUrl = await referenceImageToUpload.getDownloadURL();

      setState(() {
        imageUrls.add(imageUrl);
      });
    } catch (error) {
      print(error);
    }

    setState(() {
      isUploading = false;
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.isEmpty && imageUrls.isEmpty) return;

    try {
      DateTime now = DateTime.now();

      await FirebaseFirestore.instance.collection('hikingTrails').doc(widget.hikeId).collection('posts').add({
        'content': _contentController.text,
        'imageUrls': imageUrls,
        'hikeId': widget.hikeId,
        'userId': widget.userId,
        'timestamp': now,
      });

      _contentController.clear();
      imageUrls.clear();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adauga postare'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: HikeColor.gradientColors,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Gap(8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                          onPressed: _pickImages,
                          icon: const Icon(Icons.image),
                          padding: const EdgeInsets.all(12.0),
                        ),
                        IconButton(
                          color: HikeColor.infoDarkColor,
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          padding: const EdgeInsets.all(12.0),
                        ),
                      ],
                    ),
                    const Gap(16),
                    if (isUploading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (imageUrls.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        itemCount: imageUrls.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imageUrls[index],
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      imageUrls.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    const Gap(32),
                  ],
                ),
              ),
            ),
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
    );
  }
}
