import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/features/posts/create_post_screen.dart';
import 'package:hike_connect/models/post.dart';
import 'package:intl/intl.dart';

class PostsScreen extends StatefulWidget {
  final String hikeId;

  const PostsScreen({Key? key, required this.hikeId}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postari'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hikingTrails')
            .doc(widget.hikeId)
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 6.0));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading posts'));
          }

          List<Post> posts = snapshot.data!.docs.map((doc) => Post.fromMap(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();

          return posts.isNotEmpty
              ? ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<PostCardData?>(
                      future: getPostData(posts[index]),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Error loading post data');
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return const SizedBox.shrink();
                        } else {
                          return Column(
                            children: [
                              // Text(snapshot.data!.hikeName),
                              PostCard(post: posts[index], postData: snapshot.data!),
                            ],
                          );
                        }
                      },
                    );
                  },
                )
              : const Center(child: Text('Nicio postare momentan!'));
        },
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
            );
          } else {
            print('Not authenticated!');
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final PostCardData postData;

  const PostCard({Key? key, required this.post, required this.postData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
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
                      DateFormat('d MMMM y HH:mm', 'ro').format(post.timestamp.toDate()),
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
                  children: [Flexible(child: Text(post.content))],
                ),
                const Gap(8),
                if (postData.imageUrls.isNotEmpty) ...[
                  CarouselSlider(
                    options: CarouselOptions(),
                    items: postData.imageUrls.map(
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
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ).toList(),
                  ),
                  const Gap(24),
                ],
                Text('Likes: ${post.likes}'),
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
      likes: post.likes,
      timestamp: post.timestamp.toDate(),
    );
  } catch (e) {
    print('Error getting post data: $e');
    return null;
  }
}
