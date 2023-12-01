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

  String imageUrl = '';

  List<HikerUser> users = [];

  @override
  void initState() {
    super.initState();
    fetchUserDetails(false);
    // fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      List<HikerUser> hikerUsers = await getAllHikerUsers();
      if (mounted) {
        setState(() {
          users = hikerUsers;
          users.forEach((element) {
            print(element.displayName);
          });
        });
      }
    } catch (e) {
      print('Error fetching hiking trails: $e');
    }
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
            color: Colors.green.shade50,
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  color: HikeColor.infoColor,
                                  fontSize: 40,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                auth.currentUser?.email ?? 'Loading email...',
                                style: const TextStyle(
                                  color: HikeColor.infoColor,
                                  fontSize: 16,
                                ),
                              ),
                              if (user?.phoneNumber != null)
                                Text(
                                  '${user?.phoneNumber}',
                                  style: const TextStyle(color: HikeColor.infoColor, fontSize: 16),
                                ),
                              if (user?.phoneNumber == null && auth.currentUser?.phoneNumber != null)
                                Text(
                                  '${auth.currentUser?.phoneNumber}',
                                  style: const TextStyle(color: HikeColor.infoColor, fontSize: 16),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Column(
                        children: [
                          Text(
                            'Amateur',
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        height: 60,
                        width: 1,
                        color: Colors.black54,
                      ),
                      const Column(
                        children: [
                          Text(
                            '3',
                            style: TextStyle(color: Colors.black54, fontSize: 24),
                          ),
                          Text(
                            'Hikes completed',
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        height: 60,
                        width: 1,
                        color: Colors.black54,
                      ),
                      const Column(
                        children: [
                          Text(
                            '5',
                            style: TextStyle(color: Colors.black54, fontSize: 24),
                          ),
                          Text(
                            'Connections',
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(16),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt),
                            Gap(8),
                            Text('Incarca'),
                          ],
                        ),
                      ),
                      const Gap(16),
                      FilledButton(
                        onPressed: () async {
                          var whatsappUrl = Uri.parse("whatsapp://send?phone=${'+40746431639'}" "&text=${Uri.encodeComponent("")}");
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
                        child: const Row(
                          children: [
                            Icon(FontAwesomeIcons.whatsapp),
                            Gap(8),
                            Text("Send Message"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
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
                        : Container(
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
                          ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<HikerUser>> getAllHikerUsers() async {
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot = await usersCollection.get();

    List<HikerUser> users = querySnapshot.docs.map((DocumentSnapshot document) {
      return HikerUser.fromMap(document.data() as Map<String, dynamic>);
    }).toList();

    return users;
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
            HikerUser hikerUser = HikerUser.fromMap({
              'uid': docSnapshot.data()['uid'],
              'displayName': docSnapshot.data()['displayName'],
              'email': docSnapshot.data()['email'],
              'phoneNumber': docSnapshot.data()['phoneNumber']
            });

            setState(() {
              auth.currentUser = hikerUser;
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
}
