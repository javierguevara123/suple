import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DesbloquearCuentasScreen extends StatefulWidget {
  const DesbloquearCuentasScreen({super.key});
  @override
  State<DesbloquearCuentasScreen> createState() => _DCS();
}

class _DCS extends State<DesbloquearCuentasScreen> {
  final _api = ApiService();
  List<dynamic> _l = [];
  bool _load = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    final r = await _api.getLockedUsers();
    setState(() {
      _l = r;
      _load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Desbloqueo")),
      body: _load
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _l.length,
              itemBuilder: (c, i) => ListTile(
                title: Text(_l[i].email),
                subtitle: Text("Bloqueado hasta: ${_l[i].lockoutEnd}"),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _api.unlockUser(_l[i].email);
                    _fetch();
                  },
                  child: const Text("Desbloquear"),
                ),
              ),
            ),
    );
  }
}
