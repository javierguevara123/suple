import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Mantener por si necesitas ver expiración
import '../../services/api_service.dart';
import '../../config/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LS();
}

class _LS extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _load = false;
  bool _obs = true;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _load = true);

    // ✅ USAMOS EL NUEVO MÉTODO DE CLIENTES
    final res = await ApiService().loginCustomerPublic(
      _email.text.trim(),
      _pass.text,
    );

    setState(() => _load = false);

    if (res['success']) {
      final prefs = await SharedPreferences.getInstance();

      // 1. Guardar Token
      final token = res['token'];
      await prefs.setString('token', token);

      // 2. Guardar datos directos de la respuesta (SIN DECODIFICAR)
      // La API devuelve: { "customerId": "ANATR", "name": "Ana Trujillo..." }
      if (res['customerId'] != null) {
        await prefs.setString('customerId', res['customerId']);
      }
      if (res['name'] != null) {
        await prefs.setString('fullName', res['name']);
      }

      // 3. Configurar tipos
      await prefs.setString('role', 'Customer'); // Asumimos Customer
      await prefs.setString('userType', 'customer');
      await prefs.setString('email', _email.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bienvenido"),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/menu');
      }
    } else {
      if (mounted) {
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Icon(
                        Icons
                            .store_mall_directory, // Icono cambiado para variar un poco
                        size: 60,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "NorthWind Clientes", // Texto actualizado
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) => v!.isEmpty ? "Requerido" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _pass,
                        obscureText: _obs,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obs ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () => setState(() => _obs = !_obs),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? "Requerido" : null,
                      ),
                      const SizedBox(height: 30),

                      // BOTÓN PRINCIPAL (CLIENTES)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _load ? null : _login,
                          child: _load
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "INICIAR SESIÓN",
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // BOTÓN REGISTRO CLIENTES (Visible)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text("Registrarse como Cliente"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => context.push('/customer-register'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🔒 SECCIÓN OCULTA (ADMIN / EMPLEADO)
                      // No se borró el código, solo se ocultó.
                      Visibility(
                        visible: false, // <--- CAMBIAR A TRUE PARA MOSTRAR
                        child: Column(
                          children: [
                            const Divider(),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: const Text(
                                "¿Admin o Empleado? Ingreso Legacy",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
