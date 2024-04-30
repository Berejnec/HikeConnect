import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/theme/hike_color.dart';

class ChatMessages extends StatelessWidget {
  final String eventId;

  const ChatMessages({Key? key, required this.eventId}) : super(key: key);

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
            final isSenderLoggedUser =
                message['sender'] == context.read<AuthCubit>().getHikerUser()?.uid;
            return FutureBuilder<DocumentSnapshot>(
              key: Key(eventId),
              future: FirebaseFirestore.instance.collection('users').doc(message['sender']).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || userSnapshot.data?.data() == null) {
                  return const SizedBox(height: 0);
                }

                final senderData = userSnapshot.data?.data() as Map<String, dynamic>;

                return ListTile(
                  key: Key(messages[index].id),
                  title: Text(senderData['displayName'],
                      textAlign: isSenderLoggedUser ? TextAlign.end : TextAlign.start),
                  subtitle: Text(message['content'],
                      textAlign: isSenderLoggedUser ? TextAlign.end : TextAlign.start),
                  // tileColor: isSenderLoggedUser ? Colors.green[200] : HikeColor.fourthColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  trailing: isSenderLoggedUser
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(senderData['avatarUrl'] ?? ''),
                          radius: 16.0)
                      : null,
                  leading: !isSenderLoggedUser
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(senderData['avatarUrl'] ?? ''),
                          radius: 16.0)
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }
}
