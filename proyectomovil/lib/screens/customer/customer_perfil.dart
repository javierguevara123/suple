import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Importante para los formatters
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import 'package:intl/intl.dart'; // Para formateo de fecha

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  // Controladores
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // ✅ NUEVOS CONTROLADORES
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  DateTime? _selectedDate;

  bool _loading = false;

  // Variables para imagen
  File? _newImageFile;
  String? _newBase64Image;
  Uint8List? _currentImageBytes;

  // Errores del servidor
  Map<String, String> _serverErrors = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar datos del usuario
  Future<void> _loadUserData() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('customerId');

    if (id != null && id.isNotEmpty) {
      _idCtrl.text = id;
      try {
        final customer = await _api.getCustomerById(id);
        if (customer != null) {
          setState(() {
            _nameCtrl.text = customer.name;
            _emailCtrl.text = customer.email;
            _cedulaCtrl.text = customer.cedula ?? "";

            // ✅ CARGAR NUEVOS DATOS
            _addressCtrl.text = customer.address ?? "";

            // Formatear teléfono (quitar prefijo 593 si viene)
            String rawPhone = customer.phone ?? "";
            if (rawPhone.startsWith("593")) {
              rawPhone = "0${rawPhone.substring(3)}";
            }
            _phoneCtrl.text = rawPhone;

            // Formatear Fecha
            if (customer.birthDate != null) {
              _selectedDate = customer.birthDate;
              _birthDateCtrl.text = DateFormat(
                'dd/MM/yyyy',
              ).format(customer.birthDate!);
            }

            if (customer.profilePictureBase64 != null &&
                customer.profilePictureBase64!.isNotEmpty) {
              try {
                String cleanBase64 =
                    customer.profilePictureBase64!.contains(',')
                    ? customer.profilePictureBase64!.split(',')[1]
                    : customer.profilePictureBase64!;
                _currentImageBytes = base64Decode(cleanBase64);
              } catch (e) {
                print("Error imagen: $e");
              }
            }
          });
        }
      } catch (e) {
        print("Error carga: $e");
      }
    }
    setState(() => _loading = false);
  }

  // --- SELECCIONAR FECHA ---
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final minAgeDate = DateTime(
      now.year - 5,
      now.month,
      now.day,
    ); // mínimo 5 años
    final initialDate = _selectedDate ?? DateTime(2000);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(minAgeDate) ? minAgeDate : initialDate,
      firstDate: DateTime(1900),
      lastDate: minAgeDate,
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // --- SUBIR IMAGEN ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 70,
    );
    if (photo != null) {
      final bytes = await File(photo.path).readAsBytes();
      setState(() {
        _newImageFile = File(photo.path);
        _newBase64Image = base64Encode(bytes);
      });
    }
  }

  // Limpia el error del servidor
  void _clearError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() {
        _serverErrors.remove(field);
      });
    }
  }

  // --- GUARDAR CAMBIOS ---
  Future<void> _saveChanges() async {
    setState(() {
      _serverErrors.clear();
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // Formatear teléfono para guardar (593...)
    String? finalPhone;
    if (_phoneCtrl.text.isNotEmpty) {
      String raw = _phoneCtrl.text.trim();
      if (raw.startsWith('0')) raw = raw.substring(1);
      finalPhone = "593$raw";
    }

    final res = await _api.updateCustomer(
      id: _idCtrl.text,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      cedula: _cedulaCtrl.text.trim(),
      profilePictureBase64: _newBase64Image, // Si es null, el back no actualiza
      password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null,

      // ✅ NUEVOS CAMPOS
      address: _addressCtrl.text.trim().isEmpty
          ? null
          : _addressCtrl.text.trim(),
      phone: finalPhone,
      birthDate: _selectedDate,
    );

    setState(() => _loading = false);

    if (res['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', _nameCtrl.text.trim());
      await prefs.setString('email', _emailCtrl.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perfil actualizado con éxito"),
            backgroundColor: Colors.green,
          ),
        );
        _newImageFile = null;
        _newBase64Image = null;
        _passwordCtrl.clear();
        _loadUserData();
      }
    } else {
      if (res['errors'] != null) {
        setState(() {
          _serverErrors = Map<String, String>.from(res['errors']);
        });
        _formKey.currentState!.validate();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Error desconocido"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Perfil")),
      body: _loading && _nameCtrl.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // FOTO
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _newImageFile != null
                                ? FileImage(_newImageFile!)
                                : (_currentImageBytes != null
                                          ? MemoryImage(_currentImageBytes!)
                                          : null)
                                      as ImageProvider?,
                            child:
                                (_newImageFile == null &&
                                    _currentImageBytes == null)
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.primary,
                            child: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 1. ID (Read Only)
                    TextFormField(
                      controller: _idCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'ID Cliente',
                        prefixIcon: Icon(Icons.tag),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFEEEEEE),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. NOMBRE (Solo Letras)
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _clearError("Name"),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                        ), // Solo letras
                      ],
                      validator: (v) {
                        if (v!.isEmpty) return 'Requerido';
                        if (v.length < 3) return 'Muy corto';
                        if (_serverErrors.containsKey("Name"))
                          return _serverErrors["Name"];
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. CÉDULA (Solo Números)
                    TextFormField(
                      controller: _cedulaCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Cédula',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      onChanged: (_) => _clearError("Cedula"),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v!.length != 10) return 'Debe tener 10 dígitos';
                        if (_serverErrors.containsKey("Cedula"))
                          return _serverErrors["Cedula"];
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. EMAIL
                    // 4. EMAIL (Validación Estricta)
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        hintText: "ejemplo@gmail.com",
                      ),
                      onChanged: (_) => _clearError(
                        "Email",
                      ), // Limpia errores del back al escribir
                      validator: (v) {
                        // 1. Obligatorio
                        if (v == null || v.isEmpty) return 'Requerido';

                        // 2. Longitud permitida (Estándar RFC)
                        if (v.length < 5) return 'Mínimo 5 caracteres';
                        if (v.length > 254) return 'Máximo 254 caracteres';

                        // 3. Estructura correcta (Regex solicitada)
                        // ^[^\s@]+       -> Inicio sin espacios ni @
                        // @              -> Arroba obligatorio
                        // [^\s@]+        -> Dominio sin espacios ni @
                        // \.             -> Punto obligatorio
                        // [^\s@]+$       -> Extensión sin espacios ni @
                        final regex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
                        if (!regex.hasMatch(v)) {
                          return 'Formato inválido (ej: nombre@dominio.com)';
                        }

                        // 4. Reglas extra de estructura
                        if (v.startsWith('.') || v.endsWith('.')) {
                          return 'No puede empezar ni terminar con punto';
                        }

                        // 5. Validar que no tenga doble arroba
                        if (v.indexOf('@') != v.lastIndexOf('@')) {
                          return 'Solo puede contener un @';
                        }

                        // 6. Verificar si el servidor devolvió error (ej: Email duplicado)
                        if (_serverErrors.containsKey("Email")) {
                          return _serverErrors["Email"];
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ 5. DIRECCIÓN
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ 6. TELÉFONO (Solo Números)
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Celular (09...)',
                        hintText: "0991234567",
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      inputFormatters: [
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

                    // ✅ 7. FECHA NACIMIENTO
                    TextFormField(
                      controller: _birthDateCtrl,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Nacimiento',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8. PASSWORD (Opcional)
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nueva Contraseña (Opcional)',
                        hintText: 'Dejar vacío para no cambiar',
                        helperText:
                            '4-10 caracteres, Mayús, Minús, Núm, Especial',
                        helperMaxLines: 2,
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return null; // No cambia password

                        if (v.length < 4 || v.length > 10)
                          return 'Longitud 4-10';
                        if (!v.contains(RegExp(r'[A-Z]')))
                          return 'Falta Mayúscula';
                        if (!v.contains(RegExp(r'[a-z]')))
                          return 'Falta Minúscula';
                        if (!v.contains(RegExp(r'[0-9]')))
                          return 'Falta Número';
                        if (!v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')))
                          return 'Falta Símbolo';

                        if (_serverErrors.containsKey("Password"))
                          return _serverErrors["Password"];
                        return null;
                      },
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
                        onPressed: _loading ? null : _saveChanges,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'GUARDAR CAMBIOS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
