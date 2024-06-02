import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hike_connect/features/auth/user_cubit.dart';
import 'package:hike_connect/theme/hike_color.dart';

class ChatMessages extends StatelessWidget {
  final String eventId;
  final List<Map<String, dynamic>> userData;

  const ChatMessages({Key? key, required this.eventId, required this.userData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('events/$eventId/chat_messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          key: Key(eventId),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data();
            final isSenderLoggedUser = message['sender'] ==
                context.read<UserCubit>().getHikerUser()?.uid;
            final senderData = userData.firstWhere(
                (user) => user['uid'] == message['sender'],
                orElse: () => {});

            return ListTile(
              key: Key(messages[index].id),
              title: Text(senderData['displayName'] ?? '',
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: HikeColor.primaryColor,
                      fontWeight: FontWeight.w600),
                  textAlign:
                      isSenderLoggedUser ? TextAlign.end : TextAlign.start),
              subtitle: Text(message['content'] ?? '',
                  style: const TextStyle(fontSize: 18.0),
                  textAlign:
                      isSenderLoggedUser ? TextAlign.end : TextAlign.start),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              trailing: isSenderLoggedUser
                  ? CircleAvatar(
                      backgroundImage: senderData['avatarUrl'] != null
                          ? NetworkImage(senderData['avatarUrl'])
                          : null,
                      radius: 18.0,
                      backgroundColor: senderData['avatarUrl'] != null
                          ? null
                          : HikeColor.green,
                      child: senderData['avatarUrl'] == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    )
                  : null,
              leading: !isSenderLoggedUser
                  ? CircleAvatar(
                      backgroundImage: senderData['avatarUrl'] != null
                          ? NetworkImage(senderData['avatarUrl'])
                          : null,
                      radius: 18.0,
                      backgroundColor: senderData['avatarUrl'] != null
                          ? null
                          : HikeColor.green,
                      child: senderData['avatarUrl'] == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
