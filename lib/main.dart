import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: const CompassScreen(),
    );
  }
}

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          if (_hasPermission) {
            return _buildCompass();
          } else {
            return _buildPermissionSheet();
          }
        },
      ),
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((value) {
      if (mounted) {
        setState(() {
          _hasPermission = (value == PermissionStatus.granted);
        });
      }
    });
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error.toString()}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }


        double? direction = snapshot.data!.heading;

        if (direction == null){
          return const Center(child: Text("No sensors found."));
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('$direction'),
                Transform.rotate(
                    angle: direction * (pi / 180) * -1,
                    child: Image.asset("assets/compass.png"),
                ),
              ],
            ),
          ),
        );

      },
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: const Text('request permission'),
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
      ),
    );
  }
}
