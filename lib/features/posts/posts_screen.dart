import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/features/posts/create_post_screen.dart';
import 'package:hike_connect/theme/hike_color.dart';
import 'package:intl/intl.dart';

class PostsScreen extends StatefulWidget {
  final String hikeId;

  const PostsScreen({Key? key, required this.hikeId}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late Future<List<PostCardData>> _postDataFuture;

  @override
  void initState() {
    super.initState();
    _postDataFuture = _fetchPostData();
  }

  Future<List<PostCardData>> _fetchPostData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('hikingTrails')
          .doc(widget.hikeId)
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      List<Post> posts = snapshot.docs.map((doc) => Post.fromSnapshot(doc)).toList();

      List<PostCardData> postDataList = [];

      for (var post in posts) {
        final postData = await getPostData(post);
        if (postData != null) {
          postDataList.add(postData);
        }
      }

      return postDataList;
    } catch (e) {
      print('Error fetching post data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postari traseu'),
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
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<PostCardData>>(
          future: _postDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 6.0));
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading posts'));
            }

            List<PostCardData> postDataList = snapshot.data ?? [];

            return postDataList.isNotEmpty
                ? ListView.builder(
                    itemCount: postDataList.length,
                    itemBuilder: (context, index) {
                      final postData = postDataList[index];
                      return PostCard(postData: postData);
                    },
                  )
                : const Center(child: Text('Nicio postare momentan!'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String? userId = context.read<AuthCubit>().getHikerUser()?.uid;
          if (userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePostScreen(hikeId: widget.hikeId, userId: userId),
              ),
            ).then((value) {
              if (value == true) {
                setState(() {
                  _postDataFuture = _fetchPostData();
                });
              }
            });
          } else {
            print('Not authenticated!');
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postDataFuture = _fetchPostData();
    });
  }
}

class PostCard extends StatelessWidget {
  final PostCardData postData;

  const PostCard({Key? key, required this.postData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2.0,
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(postData.avatarUrl),
                  radius: 16.0,
                ),
                const Gap(16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      postData.username,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      DateFormat('d MMMM y HH:mm', 'ro').format(postData.timestamp),
                      style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(8),
                Row(
                  children: [Flexible(child: Text(postData.content))],
                ),
                const Gap(8),
                if (postData.imageUrls.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Image.network(postData.imageUrls[0]),
                            ),
                          );
                        },
                      );
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Image.network(
                        postData.imageUrls[0],
                        height: 350,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostCardData {
  final String username;
  final String avatarUrl;
  final String hikeName;
  final String content;
  final List<String> imageUrls;
  final int likes;
  final DateTime timestamp;

  PostCardData({
    required this.username,
    required this.avatarUrl,
    required this.hikeName,
    required this.content,
    required this.imageUrls,
    required this.likes,
    required this.timestamp,
  });
}

class Post {
  final String content;
  final String hikeId;
  final List<String> imageUrls;
  final Timestamp timestamp;
  final String userId;

  Post({
    required this.content,
    required this.hikeId,
    required this.imageUrls,
    required this.timestamp,
    required this.userId,
  });

  factory Post.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Post(
      content: data['content'] ?? '',
      hikeId: data['hikeId'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
    );
  }
}

Future<PostCardData?> getPostData(Post post) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance.collection('users').doc(post.userId).get();

    DocumentSnapshot<Map<String, dynamic>> hikeSnapshot = await FirebaseFirestore.instance.collection('hikingTrails').doc(post.hikeId).get();

    if (!userSnapshot.exists || !hikeSnapshot.exists) {
      return null;
    }

    final String username = userSnapshot['displayName'];
    final String avatarUrl = userSnapshot['avatarUrl'];
    final String hikeName = hikeSnapshot['routeName'];

    return PostCardData(
      username: username,
      avatarUrl: avatarUrl,
      hikeName: hikeName,
      content: post.content,
      imageUrls: post.imageUrls,
      likes: 0,
      // You can fetch likes if needed
      timestamp: post.timestamp.toDate(),
    );
  } catch (e) {
    print('Error getting post data: $e');
    return null;
  }
}
