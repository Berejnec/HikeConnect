import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hike_connect/features/auth/splash_screen.dart';
import 'package:hike_connect/features/auth/user_cubit.dart';
import 'package:hike_connect/features/emergency/emergency_tabs_screen.dart';
import 'package:hike_connect/models/hike_event.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:hike_connect/utils/widgets/hikes_timeline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

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

  var key1 = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchUserEventsList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return BlocBuilder<UserCubit, UserState>(
      builder: (BuildContext context, UserState authState) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 50.0,
                backgroundColor: Colors.transparent.withOpacity(0.8),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (context.read<UserCubit>().getHikerUser() != null && context.read<UserCubit>().getHikerUser()!.backgroundUrl != null)
                        CachedNetworkImage(
                          imageUrl: context.read<UserCubit>().getHikerUser()!.backgroundUrl!,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(color: Colors.grey),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Profil',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                  titlePadding: const EdgeInsets.all(16.0),
                ),
                leading: IconButton(
                  onPressed: () => SideSheet.left(
                    body: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: SingleChildScrollView(
                          child: SizedBox(
                            height: MediaQuery.sizeOf(context).height - 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    InkWell(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const EmergencyTabsScreen(),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.emergency,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'Informatii esentiale',
                                            style: TextStyle(color: Colors.white, fontSize: 16.0),
                                          ),
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                              const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            if (await canLaunchUrl(Uri.parse("tel:123"))) {
                                              await launchUrl(Uri.parse("tel:123"));
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.emergency_outlined,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'Apel de urgenta - 112 -',
                                            style: TextStyle(color: Colors.white, fontSize: 16.0),
                                          ),
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                              const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            if (await canLaunchUrl(Uri.parse("tel:0725826668"))) {
                                              await launchUrl(Uri.parse("tel:0725826668"));
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.emergency_outlined,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'Dispeceratul National Salvamont',
                                            style: TextStyle(color: Colors.white, fontSize: 16.0),
                                          ),
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                              const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          onPressed: () {
                                            _signOut();
                                          },
                                          icon: const Icon(Icons.logout, color: Colors.white),
                                          label: const Text('Deconecteaza-te', style: TextStyle(color: Colors.white, fontSize: 16.0)),
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                              const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/logo.png',
                                      width: 48,
                                      height: 48,
                                    ),
                                    const Gap(16.0),
                                    Text(
                                      'HikeConnect',
                                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                            color: const Color(0xFF0B613D),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    context: context,
                    width: MediaQuery.of(context).size.width * 0.66,
                    sheetColor: Colors.grey,
                  ),
                  icon: const Icon(Icons.menu),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      _signOut();
                    },
                    icon: const Icon(Icons.logout),
                  )
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      constraints: const BoxConstraints.expand(height: 300.0),
                      decoration: authState is BackgroundImageUploading
                          ? BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                            )
                          : context.read<UserCubit>().getHikerUser() != null && context.read<UserCubit>().getHikerUser()?.backgroundUrl != null
                              ? BoxDecoration(
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(context.read<UserCubit>().getHikerUser()!.backgroundUrl!),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.5),
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
                              String? userId = context.read<UserCubit>().getHikerUser()?.uid;
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
                                  if (context.read<UserCubit>().getHikerUser()?.avatarUrl != null)
                                    ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: context.read<UserCubit>().getHikerUser()!.avatarUrl!,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  const Gap(25),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        context.read<UserCubit>().getHikerUser()?.displayName ?? 'Loading name...',
                                        style: const TextStyle(
                                          color: HikeColor.white,
                                          fontSize: 40,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        context.read<UserCubit>().getHikerUser()?.email ?? 'Loading email...',
                                        style: const TextStyle(
                                          color: HikeColor.white,
                                          fontSize: 16,
                                        ),
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
                              GestureDetector(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      '${context.read<UserCubit>().getHikerUser()?.favoriteHikingTrails.length ?? '...'}',
                                      style: const TextStyle(color: Colors.black54, fontSize: 24),
                                    ),
                                    const Text(
                                      'Trasee favorite',
                                      style: TextStyle(color: Colors.black54, fontSize: 16),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  showModalBottomSheet<dynamic>(
                                    context: context,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    builder: (BuildContext context) {
                                      return Container(
                                        height: MediaQuery.of(context).size.height * 0.75,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10.0,
                                              offset: Offset(0, -5),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Trasee favorite',
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                              const Divider(),
                                              context.read<UserCubit>().getHikerUser()?.favoriteHikingTrails != null
                                                  ? Expanded(
                                                      child: ListView.builder(
                                                        itemCount: context.read<UserCubit>().getHikerUser()?.favoriteHikingTrails.length,
                                                        itemBuilder: (context, index) {
                                                          return Card(
                                                            elevation: 3,
                                                            color: Colors.white,
                                                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(12.0),
                                                              child: Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons.star,
                                                                    color: HikeColor.infoLightColor,
                                                                    size: 24,
                                                                  ),
                                                                  const SizedBox(width: 16),
                                                                  Expanded(
                                                                    child: Text(
                                                                      '${context.read<UserCubit>().getHikerUser()?.favoriteHikingTrails[index]}',
                                                                      style: const TextStyle(
                                                                        fontWeight: FontWeight.w500,
                                                                        fontSize: 16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: Text('Se incarca traseele favorite'),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Scrollable.ensureVisible(key1.currentContext!, duration: const Duration(milliseconds: 500));
                            },
                            child: Column(
                              children: [
                                Text(
                                  '${userEvents.length}',
                                  style: const TextStyle(color: Colors.black54, fontSize: 24),
                                ),
                                const Text(
                                  'Trasee parcurse',
                                  style: TextStyle(color: Colors.black54, fontSize: 16),
                                ),
                              ],
                            ),
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
                            XFile? file = await imagePicker.pickImage(source: ImageSource.camera);

                            if (file == null) return;

                            try {
                              Reference referenceRoot = FirebaseStorage.instance.ref();
                              Reference referenceDirImages = referenceRoot.child('images');
                              Reference referenceImageToUpload = referenceDirImages.child(DateTime.now().millisecondsSinceEpoch.toString());

                              await referenceImageToUpload.putFile(File(file.path));
                              String imageUrl = await referenceImageToUpload.getDownloadURL();

                              if (!mounted) return;
                              await context.read<UserCubit>().addImageAndUpdate(imageUrl);
                            } catch (error) {
                              print(error);
                            }
                          },
                          icon: const Icon(FontAwesomeIcons.camera),
                          padding: const EdgeInsets.all(12.0),
                        ),
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
                              await context.read<UserCubit>().addImageAndUpdate(imageUrl);
                            } catch (error) {
                              print(error);
                            }
                          },
                          icon: const Icon(FontAwesomeIcons.image),
                          padding: const EdgeInsets.all(12.0),
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
                    if (context.read<UserCubit>().getHikerUser() != null && context.read<UserCubit>().getHikerUser()?.imageUrls != null)
                      context.read<UserCubit>().getHikerUser()!.imageUrls!.length > 1
                          ? CarouselSlider(
                              options: CarouselOptions(),
                              items: context.read<UserCubit>().getHikerUser()?.imageUrls?.map(
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
                                                    child: CachedNetworkImage(imageUrl: imageUrl),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            child: CachedNetworkImage(
                                              imageUrl: imageUrl,
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
                          : context.read<UserCubit>().getHikerUser()!.imageUrls!.isNotEmpty
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
                                              child: Image.network(context.read<UserCubit>().getHikerUser()!.imageUrls![0]),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      child: Image.network(
                                        context.read<UserCubit>().getHikerUser()!.imageUrls![0],
                                        width: 300,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(child: Text('Nicio imagine incarcata.', style: Theme.of(context).textTheme.titleMedium)),
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
                    const Gap(16),
                    if (userEvents.isNotEmpty)
                      Container(
                        key: key1,
                        height: 400,
                        decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: HikeColor.tertiaryColor))),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: HikesTimeline(pastEvents: userEvents),
                        ),
                      ),
                    if (userEvents.isEmpty) ...[
                      const Center(child: Text('Niciun traseu parcurs momentan.')),
                    ],
                    const Gap(16),
                  ],
                ),
              ),
            ],
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
      context.read<UserCubit>().setUser(null, null);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SplashScreen()));
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _uploadImageAndSetBackgroundUrl(String userId) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      if (!mounted) return;
      context.read<UserCubit>().emitBackgroundImageUploading();

      Reference storageReference = _storage.ref().child('background_images').child(userId);
      await storageReference.putFile(File(file.path));

      String imageUrl = await storageReference.getDownloadURL();

      if (!mounted) return;
      await context.read<UserCubit>().updateBackgroundUrl(imageUrl);
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
    if (context.read<UserCubit>().getHikerUser() != null) {
      List<HikeEvent> events = await fetchUserEvents(context.read<UserCubit>().getHikerUser()!.uid);
      setState(() {
        userEvents = events;
      });
    }
  }
}
