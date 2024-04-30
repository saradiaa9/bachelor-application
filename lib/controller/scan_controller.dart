// ignore_for_file: use_super_parameters, prefer_const_constructors, avoid_print, curly_braces_in_flow_control_structures

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bachelor_application/navigation_bar%20copy.dart';
import 'package:camera/camera.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:bachelor_application/main.dart';

late List<CameraDescription> cameras;

class ScanController extends StatefulWidget {
  const ScanController({Key? key}) : super(key: key);

  @override
  State<ScanController> createState() => _ScanControllerState();
}

class _ScanControllerState extends State<ScanController> {
  late FlutterVision vision;

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
  }

  @override
  void dispose() async {
    super.dispose();
    await vision.closeYoloModel();
  }

  @override
  Widget build(BuildContext context) {
    return YoloVideo(vision: vision);
  }
}

class YoloVideo extends StatefulWidget {
  final FlutterVision vision;
  const YoloVideo({Key? key, required this.vision}) : super(key: key);

  @override
  State<YoloVideo> createState() => _YoloVideoState();
}

class _YoloVideoState extends State<YoloVideo> {
  late CameraController controller;
  late List<Map<String, dynamic>> yoloResults;
  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;

  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
    init();
  }

  init() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((value) {
      loadYoloModel().then((value) {
        setState(() {
          isLoaded = true;
          isDetecting = true;
          yoloResults = [];
          startDetection();
        });
      });
    });
  }

  @override
  void dispose() async {
    isDetecting = false;
    yoloResults.clear();
    print(yoloResults.length);
    super.dispose();
    await controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(
          body: Center(
        child: Text("Model not loaded, waiting for it"),
      ));
    }
    return Scaffold(
        body: Stack(
      children: [
        CameraPreview(
          controller,
        ),
        ...displayBoxesAroundRecognizedObjects(MediaQuery.of(context).size),
        Nav2(),
      ],
    ));
  }

  Future<void> loadYoloModel() async {
    await widget.vision.loadYoloModel(
        labels: 'assets/ai/labels2.txt',
        modelPath: 'assets/ai/yolov8n.tflite',
        modelVersion: "yolov8",
        numThreads: 2,
        useGpu: false);
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await widget.vision.yoloOnFrame(
        bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
  }

  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
    });
    if (controller.value.isStreamingImages) {
      return;
    }
    await controller.startImageStream((image) async {
      if (isDetecting) {
        cameraImage = image;
        yoloOnFrame(image);
      }
    });
  }

  Future<void> stopDetection() async {
    setState(() {
      isDetecting = false;
      yoloResults.clear();
      print(yoloResults.length);
    });
  }

  triggerNotification() {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 01,
      channelKey: 'basic_channel',
      title: 'BE CAREFUL !!',
      body: 'A person is infront of you.',
      notificationLayout: NotificationLayout.BigText,
    ));
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '01', // id
      'BE CAREFUL !!', // title
      channelDescription: 'A person is infront of you.', // description
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      'BE CAREFUL !!', // title
      'A person is in front of you.', // body
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];
    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      if (result["tag"] == "person") {
        _showNotification();
      }
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }
}
