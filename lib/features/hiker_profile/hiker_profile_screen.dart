import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/features/auth/sign_in_screen.dart';
import 'package:hike_connect/models/hike_event.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:hike_connect/utils/widgets/timeline.dart';
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

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  String imageUrl = '';

  List<HikeEvent> userEvents = [];

  @override
  void initState() {
    super.initState();
    fetchUserEventsList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState authState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            actions: [
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
                      decoration: authState is BackgroundImageUploading
                          ? BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                            )
                          : context.read<AuthCubit>().getHikerUser() != null && context.read<AuthCubit>().getHikerUser()?.backgroundUrl != null
                              ? BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(context.read<AuthCubit>().getHikerUser()!.backgroundUrl!),
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
                              String? userId = context.read<AuthCubit>().getHikerUser()?.uid;
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
                                  if (context.read<AuthCubit>().getHikerUser()?.avatarUrl != null)
                                    ClipOval(
                                      child: Image.network(
                                        context.read<AuthCubit>().getHikerUser()!.avatarUrl!,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  if (context.read<AuthCubit>().getHikerUser()?.avatarUrl == null) const Text('Loading photo...'),
                                  const Gap(25),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        context.read<AuthCubit>().getHikerUser()?.displayName ?? 'Loading name...',
                                        style: const TextStyle(
                                          color: HikeColor.white,
                                          fontSize: 40,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        context.read<AuthCubit>().getHikerUser()?.email ?? 'Loading email...',
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
                                      if (user?.phoneNumber == null && context.read<AuthCubit>().getHikerUser()?.phoneNumber != null)
                                        Text(
                                          '${context.read<AuthCubit>().getHikerUser()?.phoneNumber}',
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
                    if (authState is BackgroundImageUploading)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(HikeColor.primaryColor),
                          backgroundColor: HikeColor.errorColor,
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
                                '${context.read<AuthCubit>().getHikerUser()?.favoriteHikingTrails.length ?? '...'}',
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
                                '1',
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

                            try {
                              Reference referenceRoot = FirebaseStorage.instance.ref();
                              Reference referenceDirImages = referenceRoot.child('images');
                              Reference referenceImageToUpload = referenceDirImages.child(DateTime.now().millisecondsSinceEpoch.toString());

                              await referenceImageToUpload.putFile(File(file.path));
                              String imageUrl = await referenceImageToUpload.getDownloadURL();

                              if (!mounted) return;
                              // Use the AuthCubit method to add image and update user details
                              await context.read<AuthCubit>().addImageAndUpdate(imageUrl);
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
                            var whatsappUrl = Uri.parse("whatsapp://send?phone=${context.read<AuthCubit>().getHikerUser()?.phoneNumber ?? ''}"
                                "&text=${Uri.encodeComponent("")}");
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
                      child: Row(
                        children: [
                          const Icon(Icons.photo_library_outlined),
                          const Gap(4),
                          Text('Imagini trasee', style: Theme.of(context).textTheme.headlineLarge),
                        ],
                      ),
                    ),
                    const Gap(16),
                    if (context.read<AuthCubit>().getHikerUser() != null && context.read<AuthCubit>().getHikerUser()?.imageUrls != null)
                      context.read<AuthCubit>().getHikerUser()!.imageUrls!.length > 1
                          ? CarouselSlider(
                              options: CarouselOptions(),
                              items: context.read<AuthCubit>().getHikerUser()?.imageUrls?.map(
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
                          : context.read<AuthCubit>().getHikerUser()!.imageUrls!.isNotEmpty
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
                                              child: Image.network(context.read<AuthCubit>().getHikerUser()!.imageUrls![0]),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      child: Image.network(
                                        context.read<AuthCubit>().getHikerUser()!.imageUrls![0],
                                        width: 300,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(child: Text('Nicio image incarcata', style: Theme.of(context).textTheme.titleMedium)),
                    const Gap(16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.hiking),
                          const Gap(4),
                          Text('Trasee parcurse', style: Theme.of(context).textTheme.headlineLarge),
                        ],
                      ),
                    ),
                    if (userEvents.isNotEmpty)
                      Container(
                        height: 400,
                        decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: HikeColor.tertiaryColor))),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Timeline(pastEvents: userEvents),
                        ),
                      ),
                    if (userEvents.isEmpty) const Center(child: Text('No past hiking trails for the user')),
                    const Gap(16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      if (!mounted) return;
      context.read<AuthCubit>().setUser(null, null);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _uploadImageAndSetBackgroundUrl(String userId) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      if (!mounted) return;
      context.read<AuthCubit>().emitBackgroundImageUploading();

      Reference storageReference = _storage.ref().child('background_images').child(userId);
      await storageReference.putFile(File(file.path));

      String imageUrl = await storageReference.getDownloadURL();

      if (!mounted) return;
      await context.read<AuthCubit>().updateBackgroundUrl(imageUrl);
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  Future<List<HikeEvent>> fetchUserEvents(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('events').orderBy('date', descending: true).get();
      List<HikeEvent> userEvents = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        HikeEvent hikeEvent = HikeEvent.fromMap(doc.data()! as Map<String, dynamic>);

        bool isParticipant = hikeEvent.participants.any((participant) => participant.userId == userId);
        bool isPastEvent = hikeEvent.date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

        if (isParticipant && isPastEvent) {
          userEvents.add(hikeEvent);
        }
      }

      return userEvents;
    } catch (e) {
      print('Error fetching user events: $e');
      return [];
    }
  }

  Future<void> fetchUserEventsList() async {
    if (context.read<AuthCubit>().getHikerUser() != null) {
      // context.read<AuthCubit>().printHikerUserDetails();
      List<HikeEvent> events = await fetchUserEvents(context.read<AuthCubit>().getHikerUser()!.uid);
      setState(() {
        userEvents = events;
      });
    }
  }
}
