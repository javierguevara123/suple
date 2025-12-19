import 'dart:math'; // Necesario para generar ID aleatorio
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RS();
}

class _RS extends State<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _e = TextEditingController();
  final _p = TextEditingController();
  final _cp = TextEditingController();
  final _n = TextEditingController();
  final _l = TextEditingController();
  final _c = TextEditingController();
  bool _load = false;

  // Generar ID de 5 letras aleatorio (Requisito de Northwind antiguo)
  String _generateId(String name) {
    String base = name.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    if (base.length < 3) base = "CUST";
    String suffix = String.fromCharCodes(
      List.generate(2, (index) => Random().nextInt(26) + 65),
    );
    return (base.substring(0, min(3, base.length)) + suffix).padRight(5, 'X');
  }

  void _reg() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _load = true);

    final data = {
      "email": _e.text.trim(),
      "password": _p.text,
      "firstName": _n.text.trim(),
      "lastName": _l.text.trim(),
      "cedula": _c.text.trim(),
    };

    // 1. Registrar Usuario (Identity)
    final res = await ApiService().register(data);

    if (res['success']) {
      // 2. ¡TRUCO! Crear Cliente automáticamente con SALDO
      try {
        final customerId = _generateId(_n.text);

        await ApiService().createCustomer({
          "id": customerId,
          "name": "${_n.text} ${_l.text}",
          "currentBalance": 500.00, // <--- AQUÍ LE DAMOS DINERO
          "address": "Dirección de ${_n.text}",
          "phone": "0999999999",
        });

        // Guardar el ID del cliente temporalmente para el login automático si fuera necesario
        // pero lo buscaremos por email al entrar.
      } catch (e) {
        print("Error creando perfil de cliente: $e");
      }

      if (mounted) {
        setState(() => _load = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cuenta creada con \$500 de saldo!"),
            backgroundColor: AppTheme.success,
          ),
        );
        context.pop();
      }
    } else {
      if (mounted) {
        setState(() => _load = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _key,
          child: Column(
            children: [
              TextFormField(
                controller: _n,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _l,
                decoration: const InputDecoration(labelText: "Apellido"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _c,
                decoration: const InputDecoration(labelText: "Cédula"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.length < 10 ? "Mínimo 10 dígitos" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _e,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? "Email inválido" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _p,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Contraseña"),
                validator: (v) => v!.length < 6 ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _cp,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirmar"),
                validator: (v) => v != _p.text ? "No coinciden" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _load ? null : _reg,
                  child: _load
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("REGISTRARSE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
