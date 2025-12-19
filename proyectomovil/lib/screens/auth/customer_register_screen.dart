import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ IMPORTANTE PARA LOS FORMATTERS
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import 'package:intl/intl.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CRS();
}

class _CRS extends State<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _idController = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _cedula = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  DateTime? _selectedDate;

  // Estados
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  File? _selectedImage;
  String? _base64Image;
  final Map<String, String> _serverErrors = {};
  final _api = ApiService();

  String? _getServerError(String key) {
    final foundKey = _serverErrors.keys.firstWhere(
      (k) => k.toLowerCase() == key.toLowerCase(),
      orElse: () => "",
    );
    return foundKey.isNotEmpty ? _serverErrors[foundKey] : null;
  }

  // ... (Métodos _pickImage, _processImage, _selectDate se mantienen igual) ...
  // COPIA AQUÍ LOS MÉTODOS DE IMAGEN Y FECHA DEL CÓDIGO ANTERIOR

  Future<void> _pickImage() async {
    // ... tu lógica de imagen ...
    final picker = ImagePicker();
    // ... (resumido para no repetir todo el bloque, usa el mismo de antes)
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    _processImage(photo);
  }

  void _processImage(XFile? photo) async {
    if (photo == null) return;
    final bytes = await File(photo.path).readAsBytes();
    setState(() {
      _selectedImage = File(photo.path);
      _base64Image = base64Encode(bytes);
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final minAgeDate = DateTime(
      now.year - 5,
      now.month,
      now.day,
    ); // Mínimo 5 años
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: minAgeDate, // Solo permite fechas hasta hace 5 años
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _registerAndLogin() async {
    setState(() => _serverErrors.clear());
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // Formateo teléfono (Quitar 0 inicial, agregar 593)
    String? finalPhone;
    if (_phone.text.isNotEmpty) {
      String raw = _phone.text.trim();
      if (raw.startsWith('0')) raw = raw.substring(1);
      finalPhone = "593$raw";
    }

    final regRes = await _api.registerCustomerPublic(
      customerId: _idController.text.trim().toUpperCase(),
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      cedula: _cedula.text.trim(),
      profilePictureBase64: _base64Image,
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      phone: finalPhone,
      birthDate: _selectedDate,
    );

    if (!regRes['success']) {
      setState(() => _loading = false);
      if (regRes['errors'] != null) {
        final errorsData = regRes['errors'];
        if (errorsData is Map) {
          errorsData.forEach(
            (k, v) => _serverErrors[k.toString()] = v.toString(),
          );
        }
        _formKey.currentState!.validate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Revisa los errores en rojo"),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(regRes['message']),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return;
    }

    // Login automático tras éxito
    final loginRes = await _api.loginCustomerPublic(
      _email.text.trim(),
      _password.text,
    );
    if (mounted) {
      setState(() => _loading = false);
      if (loginRes['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', loginRes['token']);
        if (loginRes['customerId'] != null)
          await prefs.setString('customerId', loginRes['customerId']);
        if (loginRes['name'] != null)
          await prefs.setString('fullName', loginRes['name']);
        await prefs.setString('userType', 'customer');
        await prefs.setString('email', _email.text.trim());
        if (mounted) context.go('/menu');
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta'), elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // FOTO
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null,
                        child: _selectedImage == null
                            ? const Icon(
                                Icons.person_add,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 1. ID
                    TextFormField(
                      controller: _idController,
                      maxLength:
                          5, // Tu backend usualmente pide 5 chars para ID
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'ID (maximo 10 letras)',
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Z0-9]'),
                        ), // Solo mayúsculas y números
                      ],
                      validator: (v) =>
                          v!.length != 5 ? 'Debe tener 5 caracteres' : null,
                    ),
                    const SizedBox(height: 16),

                    // 2. NOMBRE (SOLO LETRAS)
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      inputFormatters: [
                        // ✅ ESTO BLOQUEA NÚMEROS Y SÍMBOLOS AL ESCRIBIR
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                        ),
                      ],
                      validator: (v) {
                        if (v!.isEmpty) return 'Requerido';
                        if (v.length < 3) return 'Nombre muy corto';
                        return _getServerError('Name');
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. CÉDULA (SOLO NÚMEROS, 10 DÍGITOS)
                    TextFormField(
                      controller: _cedula,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Cédula',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                        counterText: "",
                      ),
                      inputFormatters: [
                        // ✅ ESTO IMPIDE ESCRIBIR LETRAS
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v!.isEmpty) return 'Requerido';
                        if (v.length != 10) return 'Debe tener 10 dígitos';
                        return _getServerError('Cedula');
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. EMAIL
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        hintText: "ejemplo@gmail.com",
                      ),
                      // ✅ AQUÍ ESTÁ LA NUEVA VALIDACIÓN
                      validator: (v) {
                        // 1. Obligatorio
                        if (v == null || v.isEmpty)
                          return 'El correo es obligatorio';

                        // 2. Longitud permitida (RFC estándar)
                        if (v.length < 5) return 'Mínimo 5 caracteres';
                        if (v.length > 254) return 'Máximo 254 caracteres';

                        // 3. Estructura correcta (Regex solicitada)
                        // ^[^\s@]+       -> Empieza con cualquier cosa que NO sea espacio ni @
                        // @              -> Debe tener un arroba
                        // [^\s@]+        -> Sigue con caracteres (dominio) sin espacios ni @
                        // \.             -> Debe tener un punto
                        // [^\s@]+$       -> Termina con la extensión sin espacios ni @
                        final regex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
                        if (!regex.hasMatch(v)) {
                          return 'Formato inválido (ej: nombre@dominio.com)';
                        }

                        // 4. Reglas extra de estructura (Puntos al inicio/final)
                        if (v.startsWith('.') || v.endsWith('.')) {
                          return 'No puede empezar ni terminar con punto';
                        }

                        // 5. Validar que no tenga doble arroba (cubierto por regex, pero por seguridad)
                        if (v.indexOf('@') != v.lastIndexOf('@')) {
                          return 'Solo puede contener un @';
                        }

                        // 6. Verificar errores que devuelve el servidor (si el email ya existe)
                        return _getServerError('Email');
                      },
                    ),
                    const SizedBox(height: 16),

                    // 5. DIRECCIÓN
                    TextFormField(
                      controller: _address,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. TELÉFONO (SOLO NÚMEROS)
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Celular (09...)',
                        hintText: "0991234567",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        counterText: "",
                      ),
                      inputFormatters: [
                        // ✅ ESTO IMPIDE ESCRIBIR LETRAS
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v!.isNotEmpty && v.length < 9)
                          return 'Teléfono inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 7. FECHA
                    TextFormField(
                      controller: _birthDateCtrl,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: const InputDecoration(
                        labelText: 'Fecha Nacimiento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8. PASSWORD
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        helperText: "Mayúscula, número y símbolo (@#*)",
                        helperMaxLines: 1,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v!.length < 4) return 'Muy corta';
                        if (!v.contains(RegExp(r'[A-Z]')))
                          return 'Falta Mayúscula';
                        if (!v.contains(RegExp(r'[0-9]')))
                          return 'Falta Número';
                        if (!v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')))
                          return 'Falta Símbolo';
                        return _getServerError('Password');
                      },
                    ),
                    const SizedBox(height: 24),

                    // 9. CONFIRM PASSWORD
                    TextFormField(
                      controller: _confirmPassword,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirmar',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          v != _password.text ? 'No coinciden' : null,
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _loading ? null : _registerAndLogin,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'REGISTRARSE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text("Volver al login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _name.dispose();
    _email.dispose();
    _cedula.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _address.dispose();
    _phone.dispose();
    _birthDateCtrl.dispose();
    super.dispose();
  }
}
