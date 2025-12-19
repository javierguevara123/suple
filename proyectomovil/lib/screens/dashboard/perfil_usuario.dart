import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/image_service.dart';

class PerfilUsuarioScreen extends StatefulWidget {
  const PerfilUsuarioScreen({super.key});
  @override
  State<PerfilUsuarioScreen> createState() => _PS();
}

class _PS extends State<PerfilUsuarioScreen> {
  String _email = '';
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then(
      (p) => setState(() => _email = p.getString('email') ?? ''),
    );
  }

  void _pickImg() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) {
      await ImageService.saveImage('user', _email, File(f.path));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Perfil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImg,
              child: Hero(
                tag: 'avatar',
                child: ImageService.getImage('user', _email, size: 150),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _email,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Toca la imagen para cambiarla",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
