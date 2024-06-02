import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/features/auth/user_cubit.dart';
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
  late Stream<List<PostCardData>> _postDataStream;

  @override
  void initState() {
    super.initState();
    _postDataStream = _getPostDataStream();
  }

  Stream<List<PostCardData>> _getPostDataStream() {
    return FirebaseFirestore.instance
        .collection('hikingTrails')
        .doc(widget.hikeId)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Post.fromSnapshot(doc)).toList())
        .asyncMap((posts) async {
      List<PostCardData> postDataList = [];
      for (var post in posts) {
        final postData = await getPostData(post);
        if (postData != null) {
          postDataList.add(postData);
        }
      }
      return postDataList;
    });
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
        child: StreamBuilder<List<PostCardData>>(
          stream: _postDataStream,
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
                      return PostCard(
                        postData: postData,
                        hikeId: widget.hikeId,
                      );
                    },
                  )
                : const Center(child: Text('Nicio postare momentan!'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String? userId = context.read<UserCubit>().getHikerUser()?.uid;
          if (userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePostScreen(hikeId: widget.hikeId, userId: userId),
              ),
            ).then((value) {
              if (value == true) {
                setState(() {
                  _postDataStream = _getPostDataStream();
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
      _postDataStream = _getPostDataStream();
    });
  }
}

class PostCard extends StatelessWidget {
  final PostCardData postData;
  final String hikeId;

  const PostCard({Key? key, required this.postData, required this.hikeId}) : super(key: key);

  Future<void> _upvote(BuildContext context, {bool withoutToggle = false}) async {
    String? userId = context.read<UserCubit>().getHikerUser()?.uid;
    if (userId == null) {
      print('User not authenticated');
      return;
    }

    final postRef = FirebaseFirestore.instance.collection('hikingTrails').doc(hikeId).collection('posts').doc(postData.postId);

    try {
      final upvoteDoc = postRef.collection('upvotes').doc(userId);
      final upvoteSnap = await upvoteDoc.get();

      if (withoutToggle) {
        if (!upvoteSnap.exists) {
          await upvoteDoc.set({'upvoted': true});
          await postRef.update({'likes': FieldValue.increment(1)});
          Fluttertoast.showToast(
              msg: "Postare apreciata!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP_RIGHT,
              timeInSecForIosWeb: 1,
              backgroundColor: HikeColor.primaryColor,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      } else {
        if (upvoteSnap.exists) {
          await upvoteDoc.delete();
          await postRef.update({'likes': FieldValue.increment(-1)});
        } else {
          await upvoteDoc.set({'upvoted': true});
          await postRef.update({'likes': FieldValue.increment(1)});
          Fluttertoast.showToast(
              msg: "Postare apreciata!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP_RIGHT,
              timeInSecForIosWeb: 1,
              backgroundColor: HikeColor.primaryColor,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      }
    } catch (e) {
      print('Error toggling upvote: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        _upvote(context, withoutToggle: true);
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 2.0,
        child: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(postData.avatarUrl),
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
                    children: [
                      Flexible(
                        child: Text(
                          postData.content,
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                  if (postData.imageUrls.isNotEmpty) ...[
                    const Gap(8),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: CachedNetworkImage(imageUrl: postData.imageUrls[0]),
                              ),
                            );
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: CachedNetworkImage(
                          imageUrl: postData.imageUrls[0],
                          height: 350,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined, color: HikeColor.primaryColor),
                        onPressed: () => _upvote(context),
                        tooltip: 'Apreciază',
                      ),
                      Text('${postData.likes} aprecieri'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCardData {
  final String postId;
  final String username;
  final String avatarUrl;
  final String hikeName;
  final String content;
  final List<String> imageUrls;
  final int likes;
  final DateTime timestamp;

  PostCardData({
    required this.postId,
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
  final String postId;
  final String content;
  final String hikeId;
  final List<String> imageUrls;
  final Timestamp timestamp;
  final String userId;
  final int likes;

  Post({
    required this.postId,
    required this.content,
    required this.hikeId,
    required this.imageUrls,
    required this.timestamp,
    required this.userId,
    required this.likes,
  });

  factory Post.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Post(
      postId: snapshot.id,
      content: data['content'] ?? '',
      hikeId: data['hikeId'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
      likes: data['likes'] ?? 0,
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
      postId: post.postId,
      username: username,
      avatarUrl: avatarUrl,
      hikeName: hikeName,
      content: post.content,
      imageUrls: post.imageUrls,
      likes: post.likes,
      timestamp: post.timestamp.toDate(),
    );
  } catch (e) {
    print('Error getting post data: $e');
    return null;
  }
}
