// ignore_for_file: avoid_print, await_only_futures, prefer_typing_uninitialized_variables, unused_local_variable, non_constant_identifier_names

import 'dart:typed_data';
//import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
//import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter_image_compress/flutter_image_compress.dart';

class ScanController1 extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
    // initTFLite();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
    // Tflite.close();
  }

  late CameraController cameraController;

  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;
  var cameraCount = 0;

  var detector;

  var result;

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = await CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            // objectDetector(image);
            sendFrames(image);
          }
          update();
        });
      });
      isCameraInitialized(true);
      update();
    } else {
      print("Permission Denied");
    }
  }

  // initTFLite() async {
  //   await Tflite.loadModel(
  //     model: "assets/ai/model.tflite",
  //     labels: "assets/ai/labels.txt",
  //     isAsset: true,
  //     numThreads: 1,
  //     useGpuDelegate: false,
  //   );
  // }

  // objectDetector(CameraImage image) async {
  //   detector = await Tflite.detectObjectOnFrame(
  //     bytesList: image.planes.map((plane) {
  //       return plane.bytes;
  //     }).toList(),
  //     imageHeight: image.height,
  //     imageWidth: image.width,
  //     imageMean: 127.5,
  //     imageStd: 127.5,
  //     numResultsPerClass: 1,
  //     threshold: 0.4,
  //     rotation: 90,
  //   );

  //   if (detector != null) {
  //     var ourDetectedObject = detector.first;
  //     if (ourDetectedObject["confidenceInClass"] * 100 > 45) {
  //       x = ourDetectedObject["rect"]["x"];
  //       y = ourDetectedObject["rect"]["y"];
  //       w = ourDetectedObject["rect"]["w"];
  //       h = ourDetectedObject["rect"]["h"];
  //       label = ourDetectedObject["detectedClass"].toString();
  //     }
  //     update();
  //   }
  // }

  Future<void> sendFrames(CameraImage image) async {
    // Encode image to JPEG
    var image_jpeg = encodeJpeg(image);
    // Send image to Flask API
    String apiUrl = 'http://192.168.1.16:5000/video_feed';
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type':
              'application/octet-stream', // Set content type appropriately
        },
        body: image_jpeg,
      );
      if (response.statusCode == 200) {
        // Handle successful response
        result = response.bodyBytes;
        print('Image sent successfully');
      } else {
        // Handle error
        print('Failed to send image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception
      print('Error sending image: $e');
    }
  }

  Future<List<int>> encodeJpeg(CameraImage image) async {
    try {
      // Convert YUV to RGBA
      var rgbaBytes = await convertYUV420toRGBA8888(image);


      // Encode RGBA image to JPEG
      Uint8List jpegData = JpegEncoder().compress(
        rgbaBytes,
        image.width,
        image.height,
        90, // Adjust quality as needed
      );


      return jpegData;
    } catch (e) {
      print('Error encoding image: $e');
      return [];
    }
  }

  Future<Uint8List> convertYUV420toRGBA8888(CameraImage image) async {
    int width = image.width;
    int height = image.height;

    // Allocate memory for the RGBA byte array
    int size = width * height * 4;
    Uint8List rgbaBytes = Uint8List(size);

    // Convert YUV to RGBA
    int uvIndex = width * height;
    int uIndex = 0;
    int vIndex = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int yIndex = y * width + x;
        int yValue = image.planes[0].bytes[yIndex];
        int uValue =
            image.planes[1].bytes[uIndex + (y >> 1) * width + (x >> 1)];
        int vValue =
            image.planes[2].bytes[vIndex + (y >> 1) * width + (x >> 1)];

        // Convert YUV to RGB
        int r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        int g = (yValue - 0.344 * (uValue - 128) - 0.714 * (vValue - 128))
            .clamp(0, 255)
            .toInt();
        int b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

        // Store RGBA values in the byte array
        rgbaBytes[yIndex * 4] = r;
        rgbaBytes[yIndex * 4 + 1] = g;
        rgbaBytes[yIndex * 4 + 2] = b;
        rgbaBytes[yIndex * 4 + 3] = 255; // Alpha channel
      }
    }

    return rgbaBytes;
  }
}
