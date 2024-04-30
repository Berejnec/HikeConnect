import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hike_connect/features/auth/auth_cubit.dart';
import 'package:hike_connect/features/events/chat/chat_messages.dart';
import 'package:hike_connect/theme/hike_color.dart';

class ChatRoomScreen extends StatefulWidget {
  final String eventId;
  const ChatRoomScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _userData = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _userData = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HikeConnect Event Chat'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ChatMessages(eventId: widget.eventId, userData: _userData),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Scrie mesaj...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_messageController.text.isNotEmpty) {
                        sendMessage(_messageController.text);
                        _messageController.clear();
                      }
                    },
                    icon: const Icon(Icons.send, color: HikeColor.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String content) {
    FirebaseFirestore.instance.collection('events/${widget.eventId}/chat_messages').add({
      'sender': context.read<AuthCubit>().getHikerUser()?.uid,
      'content': content,
      'timestamp': Timestamp.now(),
    }).then((value) {
      print('Message sent successfully');
    }).catchError((error) {
      print('Failed to send message: $error');
    });
  }
}
