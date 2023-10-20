import 'dart:io';

import 'package:back_location/back_location.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionStatusWidget extends StatefulWidget {
  const PermissionStatusWidget({super.key});

  @override
  State<PermissionStatusWidget> createState() => _PermissionStatusWidgetState();
}

class _PermissionStatusWidgetState extends State<PermissionStatusWidget> {
  PermissionStatus? _permissionGranted;
  bool? _androidNetworkProviderGranted;

  Future<void> _checkWhenInUsePermissions() async {
    final permissionGrantedResult = await Permission.locationWhenInUse.status;
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
  }

  Future<void> _checkAndroidNetworkProvider() async {
    final androidNetworkProviderGranted =
        await isAndroidNetworkProviderEnabled();
    setState(() {
      _androidNetworkProviderGranted = androidNetworkProviderGranted;
    });
  }

  Future<void> _requestPermission() async {
    final permissionRequestedResult =
        await Permission.locationWhenInUse.request();
    setState(() {
      _permissionGranted = permissionRequestedResult;
    });
  }

  Future<void> _promptAndroidNetworkProvider() async {
    await promptUserToEnableAndroidNetworkProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Permission status: $_permissionGranted',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 42),
                child: ElevatedButton(
                  onPressed: _checkWhenInUsePermissions,
                  child: const Text('Check'),
                ),
              ),
              ElevatedButton(
                onPressed: _permissionGranted?.isGranted ?? true
                    ? null
                    : _requestPermission,
                child: const Text('Request'),
              ),
            ],
          ),
          if (Platform.isAndroid) ...[
            const SizedBox(height: 20),
            ..._androidNetworkProvider(context),
          ],
        ],
      ),
    );
  }

  List<Widget> _androidNetworkProvider(BuildContext context) {
    return [
      Text(
        'Android Network Provider: $_androidNetworkProviderGranted',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 42),
            child: ElevatedButton(
              onPressed: _checkAndroidNetworkProvider,
              child: const Text('Check'),
            ),
          ),
          ElevatedButton(
            onPressed: _promptAndroidNetworkProvider,
            child: const Text('Request'),
          ),
        ],
      ),
    ];
  }
}
