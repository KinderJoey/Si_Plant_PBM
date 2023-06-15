
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// class CameraPage extends StatefulWidget {
//   static String routeName = "/camera";
//   @override
//   _CameraPageState createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   CameraController? _cameraController;
//   late Future<void> _initializeCameraControllerFuture;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;

//     _cameraController = CameraController(
//       firstCamera,
//       ResolutionPreset.medium,
//     );

//     _initializeCameraControllerFuture = _cameraController!.initialize();
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   Future<void> _capturePhoto() async {
//     try {
//       await _initializeCameraControllerFuture;

//       final image = await _cameraController!.takePicture();

//       Navigator.pop(context,
//           image.path); // Kembali ke halaman sebelumnya dengan path gambar
//     } catch (e) {
//       print('Error capturing photo: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Camera'),
//       ),
//       body: FutureBuilder<void>(
//         future: _initializeCameraControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.hasError) {
//               return Center(
//                 child: Text('Failed to initialize camera: ${snapshot.error}'),
//               );
//             }

//             return CameraPreview(_cameraController!);
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _capturePhoto,
//         child: Icon(Icons.camera),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }
