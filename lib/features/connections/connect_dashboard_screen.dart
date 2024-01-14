import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/models/hiker_user.dart';

class ConnectDashboardScreen extends StatefulWidget {
  const ConnectDashboardScreen({super.key});

  @override
  State<ConnectDashboardScreen> createState() => _ConnectDashboardScreenState();
}

class _ConnectDashboardScreenState extends State<ConnectDashboardScreen> {
  List<HikerUser> users = [];

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  final CollectionReference connectionsCollection = FirebaseFirestore.instance.collection('connections');

  String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<String> connectedUserNames = [];
  List<HikerUser> connectedHikerUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchConnectedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.construction),
            Text('Conexiuni / Trasee favorite'),
            Icon(Icons.construction),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Favorite Hiking Trails
              context.read<AuthCubit>().getHikerUser()?.favoriteHikingTrails != null
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: context.read<AuthCubit>().getHikerUser()?.favoriteHikingTrails.length,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Text('${index + 1}. ${context.read<AuthCubit>().getHikerUser()?.favoriteHikingTrails[index]}')),
                            ],
                          );
                        },
                      ),
                    )
                  : const Center(child: Text('Se incarca traseele favorite')),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Conecteaza-te cu alti drumeti: '),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(users[index].displayName),
                            IconButton(
                              onPressed: () async {
                                await connectUsers(currentUid, users[index].uid);
                              },
                              icon: const Icon(Icons.connect_without_contact, size: 24),
                            ),
                          ],
                        ),
                        const Gap(16),
                        const Text('Conexiunile tale: '),
                        Text(connectedHikerUsers.isNotEmpty ? "${connectedHikerUsers[0].displayName}" : "Nicio conexiune"),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> getConnectedUserDisplayNames(List<String> connectedUserUids) async {
    List<String> displayNames = [];

    await Future.forEach(connectedUserUids, (String uid) async {
      DocumentSnapshot userSnapshot = await usersCollection.doc(uid).get();
      if (userSnapshot.exists) {
        String displayName = userSnapshot['displayName'] ?? '';
        displayNames.add(displayName);
      }
    });

    print(displayNames);

    return displayNames;
  }

  Future<void> fetchUsers() async {
    print('fetch users');
    try {
      List<HikerUser> hikerUsers = await getAllHikerUsers();

      String myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (mounted) {
        setState(() {
          users = hikerUsers.where((user) => user.uid != myUid).toList();

          users.forEach((element) {
            print(element.displayName);
          });
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<List<HikerUser>> getAllHikerUsers() async {
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot = await usersCollection.get();

    List<HikerUser> users = querySnapshot.docs.map((DocumentSnapshot document) {
      return HikerUser.fromMap(document.data() as Map<String, dynamic>);
    }).toList();

    return users;
  }

  Future<void> connectUsers(String user1Uid, String user2Uid) async {
    String connectionId = createConnectionId(user1Uid, user2Uid);

    await connectionsCollection.doc(connectionId).set({
      'user1Uid': user1Uid,
      'user2Uid': user2Uid,
    });
  }

  String createConnectionId(String user1Uid, String user2Uid) {
    List<String> sortedUids = [user1Uid, user2Uid]..sort();

    return sortedUids.join('_');
  }

  fetchConnectedUsers() async {
    try {
      List<HikerUser> connectedUsers = await getConnectedUsers(currentUid);
      List<String> connectedNames = await getConnectedUserDisplayNames(['fYF5HEyKZnM1A8Mjn9VL3WhQ8cC2']);
      if (mounted) {
        setState(() {
          connectedUsers = connectedUsers;
          connectedUserNames = connectedNames;
          connectedHikerUsers = connectedUsers;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<HikerUser>> getConnectedUsers(String userUid) async {
    QuerySnapshot querySnapshot = await connectionsCollection.where('user1Uid', isEqualTo: userUid).get();

    List connectedUserUids = querySnapshot.docs.map((doc) => doc['user2Uid']).toList();

    List<HikerUser> connectedUsers = await Future.wait(
      connectedUserUids.map((uid) => getUserDetails(uid)),
    );

    return connectedUsers;
  }

  Future<HikerUser> getUserDetails(String userUid) async {
    DocumentSnapshot userSnapshot = await usersCollection.doc(userUid).get();
    return HikerUser.fromMap(userSnapshot.data() as Map<String, dynamic>);
  }
}
