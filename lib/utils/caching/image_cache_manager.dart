import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// ... other imports

class ImageCacheManager {
  Future<String> cacheImage(String imagePath) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final defaultCacheManager = DefaultCacheManager();

    final Reference ref = storage.ref().child(imagePath);

    // Get your image url
    final imageUrl = await ref.getDownloadURL();

    // Check if the image file is not in the cache
    if ((await defaultCacheManager.getFileFromCache(imageUrl))?.file == null) {
      // Download your image data
      final imageBytes = await ref.getData(10000000);

      // Put the image file in the cache
      await defaultCacheManager.putFile(
        imageUrl,
        imageBytes ?? Uint8List(0),
        fileExtension: "jpg",
      );
    }

    // Return image download url
    return imageUrl;
  }
}
