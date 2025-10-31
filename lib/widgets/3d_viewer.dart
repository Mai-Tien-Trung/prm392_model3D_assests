import 'dart:io';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ThreeDViewer extends StatelessWidget {
  final String? filePath;
  final double height;

  const ThreeDViewer({super.key, this.filePath, this.height = 300});

  @override
  Widget build(BuildContext context) {
    if (filePath == null || !File(filePath!).existsSync()) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text("Chưa có mô hình", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ModelViewer(
          src: 'file://$filePath',
          alt: "3D Model",
          ar: false,
          autoRotate: true,
          cameraControls: true,
          iosSrc: filePath,
        ),
      ),
    );
  }
}