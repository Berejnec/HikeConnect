import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hike_connect/features/auth/sign_in_screen.dart';
import 'package:hike_connect/globals/auth_global.dart' as auth;
import 'package:hike_connect/models/hiker_user.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

const List<String> scopes = <String>['email'];

class HikerProfileScreen extends StatefulWidget {
  const HikerProfileScreen({Key? key}) : super(key: key);

  @override
  State<HikerProfileScreen> createState() => _HikerProfileScreenState();
}

class _HikerProfileScreenState extends State<HikerProfileScreen> {
  User? user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserDetails(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            onPressed: () {
              fetchUserDetails(true);
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              _signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: auth.currentUser != null && auth.currentUser?.backgroundUrl != null
                      ? BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(auth.currentUser!.backgroundUrl!),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.4),
                              BlendMode.darken,
                            ),
                          ),
                        )
                      : const BoxDecoration(color: Colors.grey),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.image, color: HikeColor.white),
                        onPressed: () {
                          String? userId = auth.currentUser?.uid;
                          if (userId != null) {
                            _uploadImageAndSetBackgroundUrl(userId);
                          }
                        },
                        color: Colors.black,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (user?.photoURL != null)
                                ClipOval(
                                  child: Image.network(
                                    user!.photoURL!,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              if (user?.photoURL == null) const Text('Loading photo...'),
                              const Gap(25),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    auth.currentUser?.displayName ?? 'Loading name...',
                                    style: const TextStyle(
                                      color: HikeColor.white,
                                      fontSize: 40,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    auth.currentUser?.email ?? 'Loading email...',
                                    style: const TextStyle(
                                      color: HikeColor.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (user?.phoneNumber != null)
                                    Text(
                                      '${user?.phoneNumber}',
                                      style: const TextStyle(color: HikeColor.white, fontSize: 16),
                                    ),
                                  if (user?.phoneNumber == null && auth.currentUser?.phoneNumber != null)
                                    Text(
                                      '${auth.currentUser?.phoneNumber}',
                                      style: const TextStyle(color: HikeColor.white, fontSize: 16),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${auth.currentUser?.favoriteHikingTrails.length ?? '...'}',
                            style: const TextStyle(color: Colors.black54, fontSize: 24),
                          ),
                          const Text(
                            'Trasee favorite',
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        ],
                      ),
                      const Column(
                        children: [
                          Text(
                            '5',
                            style: TextStyle(color: Colors.black54, fontSize: 24),
                          ),
                          Text(
                            'Conexiuni',
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Container(height: 1, color: HikeColor.tertiaryColor),
                const Gap(8),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      color: HikeColor.infoDarkColor,
                      onPressed: () async {
                        ImagePicker imagePicker = ImagePicker();
                        XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                        if (file == null) return;
                        String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

                        Reference referenceRoot = FirebaseStorage.instance.ref();
                        Reference referenceDirImages = referenceRoot.child('images');

                        Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

                        try {
                          await referenceImageToUpload.putFile(File(file.path));
                          imageUrl = await referenceImageToUpload.getDownloadURL();
                          await FirebaseFirestore.instance.collection('users').doc(auth.currentUser?.uid).collection('images').add({'imageUrl': imageUrl});
                          fetchUserDetails(true);
                        } catch (error) {
                          print(error);
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.camera),
                      padding: const EdgeInsets.all(12.0),
                    ),
                    IconButton(
                      color: HikeColor.infoDarkColor,
                      padding: const EdgeInsets.all(12.0),
                      onPressed: () async {
                        var whatsappUrl = Uri.parse("whatsapp://send?phone=${auth.currentUser?.phoneNumber ?? ''}" "&text=${Uri.encodeComponent("")}");
                        try {
                          if (await canLaunchUrl(whatsappUrl)) {
                            launchUrl(whatsappUrl);
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                dismissDirection: DismissDirection.horizontal,
                                behavior: SnackBarBehavior.floating,
                                content: Text("WhatsApp is required to be installed in order to send message!"),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint(e.toString());
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.whatsapp),
                    ),
                  ],
                ),
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Imagini trasee', style: Theme.of(context).textTheme.headlineMedium),
                ),
                const Gap(16),
                if (auth.currentUser != null && auth.currentUser?.imageUrls != null)
                  auth.currentUser!.imageUrls!.length > 1
                      ? CarouselSlider(
                          options: CarouselOptions(),
                          items: auth.currentUser?.imageUrls?.map(
                            (imageUrl) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              child: GestureDetector(
                                                onTap: () => Navigator.pop(context),
                                                child: Image.network(imageUrl),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        child: Image.network(
                                          imageUrl,
                                          width: 300,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ).toList(),
                        )
                      : auth.currentUser!.imageUrls!.isNotEmpty
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Image.network(auth.currentUser!.imageUrls![0]),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  child: Image.network(
                                    auth.currentUser!.imageUrls![0],
                                    width: 300,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Center(child: Text('Nicio image incarcata', style: Theme.of(context).textTheme.titleMedium)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchUserDetails(bool? fetch) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      user = currentUser;
    });

    if (auth.currentUser == null || fetch == true) {
      print('Fetching data for user');
      FirebaseFirestore.instance.collection('users').where("uid", isEqualTo: currentUser?.uid).get().then(
        (querySnapshot) async {
          for (var docSnapshot in querySnapshot.docs) {
            print('qqq${docSnapshot.data()['favoriteHikingTrails'].length}');
            HikerUser hikerUser = HikerUser.fromMap({
              'uid': docSnapshot.data()['uid'],
              'displayName': docSnapshot.data()['displayName'],
              'email': docSnapshot.data()['email'],
              'phoneNumber': docSnapshot.data()['phoneNumber'],
              'backgroundUrl': docSnapshot.data()['backgroundUrl'],
              'favoriteHikingTrails': docSnapshot.data()['favoriteHikingTrails'],
            });

            setState(() {
              print('fav:${hikerUser.favoriteHikingTrails.length}');
              auth.currentUser = hikerUser;
              auth.currentUser?.favoriteHikingTrails = [...docSnapshot.data()['favoriteHikingTrails']];
            });

            print(
              'User ID: ${hikerUser.uid}, DisplayName: ${hikerUser.displayName}, Email: ${hikerUser.email}, Phone number: ${hikerUser.phoneNumber}',
            );
          }

          CollectionReference imagesCollection = FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).collection('images');

          try {
            QuerySnapshot imagesQuerySnapshot = await imagesCollection.get();

            List<String> imageUrls = imagesQuerySnapshot.docs.map((docSnapshot) => (docSnapshot.data() as Map<String, dynamic>)['imageUrl'] as String).toList();

            setState(() {
              auth.currentUser?.imageUrls = imageUrls;
              print(auth.currentUser?.imageUrls?.length);
            });
          } catch (e) {
            print('Error retrieving images: $e');
          }
        },
        onError: (e) => print('Error completing: $e'),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      auth.currentUser = null;
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _uploadImageAndSetBackgroundUrl(String userId) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      Reference storageReference = _storage.ref().child('background_images').child(userId);
      await storageReference.putFile(File(file.path));

      String imageUrl = await storageReference.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({'backgroundUrl': imageUrl});
      fetchUserDetails(true);
    } catch (error) {
      print('Error uploading image: $error');
    }
  }
}
