// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

//testtt

import 'package:bachelor_application/controller/old1.dart';
import 'package:bachelor_application/navigation_bar%20copy.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        GetBuilder<ScanController1>(
          init: ScanController1(),
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CameraPreview(controller.cameraController),
                  )
                : Center(child: Text("Loading Camera..."));
          },
        ),
        Nav2(),
      ],
    ),
  );
}

}

