import 'dart:io';

import 'package:back_location/back_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ChangeNotificationWidget extends StatefulWidget {
  const ChangeNotificationWidget({super.key});

  @override
  State<ChangeNotificationWidget> createState() =>
      _ChangeNotificationWidgetState();
}

class _ChangeNotificationWidgetState extends State<ChangeNotificationWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _channelController = TextEditingController(
    text: 'Location background service',
  );

  final TextEditingController _channelDescriptionController =
      TextEditingController(
    text:
        'This channel is used to ensure that tracking works in the background',
  );

  final TextEditingController _titleController = TextEditingController(
    text: 'Location background service running',
  );

  bool _ongoing = false;

  String? _iconName = 'navigation_empty_icon';

  @override
  void dispose() {
    _channelController.dispose();
    _titleController.dispose();
    _channelDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isAndroid) {
      return const Text(
        'Change notification settings not available on this platform',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Android Notification Settings',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _channelController,
              decoration: const InputDecoration(
                labelText: 'Channel Name',
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _channelDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Channel Description',
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _iconName,
              onChanged: (String? value) {
                setState(() {
                  _iconName = value;
                });
              },
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'navigation_empty_icon',
                  child: Text('Empty'),
                ),
                DropdownMenuItem<String>(
                  value: 'circle',
                  child: Text('Circle'),
                ),
                DropdownMenuItem<String>(
                  value: 'square',
                  child: Text('Square'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              value: _ongoing,
              title: const Text('Set ongoing'),
              onChanged: (value) {
                setState(() {
                  _ongoing = value;
                });
              },
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () async {
                await Permission.notification.request();
                await updateBackgroundNotification(
                  channelName: _channelController.text,
                  channelDescription: _channelDescriptionController.text,
                  contentTitle: _titleController.text,
                  setOngoing: _ongoing,
                );
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }
}
