import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});
  @override
  State<UsuariosScreen> createState() => _US();
}

class _US extends State<UsuariosScreen> {
  final _api = ApiService();
  List<dynamic> _l = [];
  bool _load = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    final r = await _api.getUsers();
    setState(() {
      _l = r;
      _load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Usuarios")),
      body: _load
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _l.length,
              itemBuilder: (c, i) => ListTile(
                leading: const Icon(Icons.person),
                title: Text("${_l[i].firstName} ${_l[i].lastName}"),
                subtitle: Text(_l[i].email),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.error),
                  onPressed: () async {
                    await _api.deleteUser(_l[i].email);
                    _fetch();
                  },
                ),
              ),
            ),
    );
  }
}
