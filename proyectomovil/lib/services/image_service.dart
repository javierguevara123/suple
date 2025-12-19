import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static Future<File> _file(String type, String id) async {
    final dir = await getApplicationDocumentsDirectory();
    // Limpiamos el ID de caracteres raros para usarlo de nombre de archivo
    final safeId = id.replaceAll(RegExp(r'[^\w\.-]'), '_');
    return File('${dir.path}/${type}_$safeId.jpg');
  }

  static Future<void> saveImage(String type, String id, File img) async {
    final f = await _file(type, id);
    await img.copy(f.path);
    PaintingBinding.instance.imageCache.clear();
  }

  static Widget getImage(
    String type,
    String id, {
    double size = 50,
    IconData fallbackIcon = Icons.image,
  }) {
    return FutureBuilder<File>(
      future: _file(type, id),
      builder: (c, s) {
        if (s.hasData && s.data!.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              s.data!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              key: UniqueKey(),
            ),
          );
        }
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(fallbackIcon, color: Colors.grey),
        );
      },
    );
  }
}
