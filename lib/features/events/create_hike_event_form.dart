import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hike_connect/models/hike_event.dart';
import 'package:hike_connect/models/hiking_trail.dart';

class CreateHikeEventForm extends StatefulWidget {
  final HikingTrail trail;

  const CreateHikeEventForm({Key? key, required this.trail}) : super(key: key);

  @override
  State<CreateHikeEventForm> createState() => _CreateHikeEventFormState();
}

class _CreateHikeEventFormState extends State<CreateHikeEventForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();

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
          const Gap(32),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  HikeEvent newEvent = HikeEvent(
                    id: '',
                    date: _selectedDate!,
                    hikingTrail: widget.trail,
                    participants: [],
                  );
                  addHikeEvent(newEvent);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Creare eveniment cu succes!'),
                      duration: Duration(seconds: 5),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(bottom: 16.0),
                    ),
                  );

                  Navigator.pop(context);
                }
              },
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
        'hikingTrail': event.hikingTrail.toMap(),
        'date': event.date,
        'participants': event.participants,
      });

      await eventRef.update({'id': eventRef.id});
    } catch (e) {
      print('Error adding event: $e');
    }
  }
}
