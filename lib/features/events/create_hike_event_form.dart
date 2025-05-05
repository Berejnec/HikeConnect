import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/features/auth/user_cubit.dart';
import 'package:hike_connect/models/event_participant.dart';
import 'package:hike_connect/models/hike_event.dart';
import 'package:hike_connect/models/hiker_user.dart';
import 'package:hike_connect/models/hiking_trail.dart';
import 'package:hike_connect/theme/hike_color.dart';

class CreateHikeEventForm extends StatefulWidget {
  final HikingTrail trail;

  const CreateHikeEventForm({Key? key, required this.trail}) : super(key: key);

  @override
  State<CreateHikeEventForm> createState() => _CreateHikeEventFormState();
}

class _CreateHikeEventFormState extends State<CreateHikeEventForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            readOnly: true,
            controller: _dateController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null && pickedDate != _selectedDate) {
                setState(() {
                  _selectedDate = pickedDate;
                  _dateController.text = pickedDate.toLocal().toString().split(' ')[0];
                });
              }
            },
            decoration: const InputDecoration(
              labelText: 'Data evenimentului',
            ),
            validator: (value) {
              if (_selectedDate == null) {
                return 'Data evenimentului este obligatorie!';
              }
              return null;
            },
          ),
          const Gap(8.0),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Descriere (optional)'),
            maxLines: 1,
          ),
          const Gap(32.0),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FilledButton(
              onPressed: () async {
                HikerUser? currentUser = context.read<UserCubit>().getHikerUser();
                if (_formKey.currentState!.validate() && currentUser != null) {
                  EventParticipant owner = EventParticipant(
                    userId: currentUser.uid,
                    displayName: currentUser.displayName,
                    phoneNumber: currentUser.phoneNumber ?? 'No phone number',
                    avatarUrl: currentUser.avatarUrl ?? '',
                  );

                  HikeEvent newEvent = HikeEvent(
                    owner: owner,
                    date: _selectedDate!,
                    hikingTrail: widget.trail,
                    participants: [owner],
                    description: _descriptionController.text,
                  );
                  await addHikeEvent(newEvent);

                  if (!mounted) return;
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: HikeColor.primaryColor,
              ),
              child: const Text('Creeaza eveniment'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addHikeEvent(HikeEvent event) async {
    try {
      CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');
      DocumentReference eventRef = await eventsCollection.add({
        'owner': event.owner?.toMap(),
        'hikingTrail': event.hikingTrail.toMap(),
        'date': event.date,
        'participants': event.participants.map((e) => e.toMap()),
        'description': event.description,
      });

      await eventRef.update({'id': eventRef.id});
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Creare eveniment cu succes!'),
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 16.0),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding event: $e'),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: HikeColor.errorColor,
          margin: const EdgeInsets.only(bottom: 16.0),
        ),
      );
    }
  }
}
