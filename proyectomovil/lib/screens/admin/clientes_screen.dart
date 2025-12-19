import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proyectomovil/models/customer.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});
  @override
  State<ClientesScreen> createState() => _CS();
}

class _CS extends State<ClientesScreen> {
  final _api = ApiService();
  List<Customer> _list = [];
  int _page = 1, _size = 10, _total = 0;
  bool _load = false;
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    setState(() => _load = true);
    try {
      final r = await _api.getCustomersPaginated(
        page: _page,
        pageSize: _size,
        searchTerm: _search.text,
      );
      setState(() {
        // Asegúrate de que el modelo Customer coincida con lo que devuelve el backend
        _list = r['items']; 
        _total = r['totalRecords'];
        _load = false;
      });
    } catch (_) {
      setState(() => _load = false);
    }
  }

  void _onSearch(String v) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      setState(() => _page = 1);
      _fetch();
    });
  }

  void _form({Customer? c}) async {
    final isEdit = c != null;
    
    // Si es editar, obtenemos detalles completos (por si falta la cédula en la lista)
    Customer? cFull;
    if (isEdit) {
      cFull = await _api.getCustomerById(c.id);
    }

    final idC = TextEditingController(text: cFull?.id ?? c?.id);
    final nomC = TextEditingController(text: cFull?.name ?? c?.name);
    
    // Nuevos campos
    final cedulaC = TextEditingController(text: cFull?.cedula ?? "");
    final emailC = TextEditingController(text: cFull?.email ?? "");
    
    // Campos opcionales (Address y Phone no son obligatorios en tu backend nuevo, pero si los usas):
    // final addC = TextEditingController(text: cFull?.address); 
    // final telC = TextEditingController(text: cFull?.phone);
    
    final balC = TextEditingController(
      text: cFull?.currentBalance.toString() ?? '0',
    );
    
    final key = GlobalKey<FormState>();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? "Editar Cliente" : "Nuevo Cliente",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // ID
              TextFormField(
                controller: idC,
                enabled: !isEdit, // No editable si ya existe
                maxLength: 5,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: "ID (5 Letras)"),
                validator: (v) {
                  if (isEdit) return null;
                  return (v == null || v.length != 5) ? "5 Caracteres exactos" : null;
                },
              ),
              const SizedBox(height: 10),
              
              // NOMBRE
              TextFormField(
                controller: nomC,
                decoration: const InputDecoration(labelText: "Nombre Completo"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 10),

              // CÉDULA (Nuevo)
              TextFormField(
                controller: cedulaC,
                keyboardType: TextInputType.number,
                maxLength: 13,
                decoration: const InputDecoration(labelText: "Cédula / RUC", counterText: ""),
                validator: (v) => v!.length < 10 ? "Mínimo 10 dígitos" : null,
              ),
              const SizedBox(height: 10),

              // EMAIL (Nuevo)
              TextFormField(
                controller: emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Correo Electrónico"),
                validator: (v) => !v!.contains('@') ? "Email inválido" : null,
              ),
              
              const SizedBox(height: 10),
              
              // SALDO (Solo lectura o admin)
              TextFormField(
                controller: balC,
                decoration: const InputDecoration(labelText: "Saldo Inicial"),
                keyboardType: TextInputType.number,
                enabled: !isEdit, // Bloqueado en edición para evitar corrupción de datos financieros
              ),

              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  onPressed: () async {
                    if (!key.currentState!.validate()) return;
                    
                    Navigator.pop(ctx);
                    
                    Map<String, dynamic> res;
                    
                    if (isEdit) {
                      // UPDATE
                      res = await _api.updateCustomer(
                        id: c!.id,
                        name: nomC.text,
                        cedula: cedulaC.text,
                        email: emailC.text,
                        // No enviamos password ni foto aquí (es admin editing)
                      );
                    } else {
                      // CREATE (Usamos registerCustomerPublic o createCustomerAdmin si existiera)
                      // Como tu backend usa el mismo DTO, podemos reusar la lógica
                      res = await _api.registerCustomerPublic(
                        customerId: idC.text.toUpperCase(),
                        name: nomC.text,
                        email: emailC.text,
                        cedula: cedulaC.text,
                        password: "Password123!", // Contraseña por defecto
                        // profilePictureBase64: null,
                      );
                    }

                    if (res['success'] == true) {
                      _fetch();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Operación exitosa"), backgroundColor: AppTheme.success),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res['message'] ?? "Error"), backgroundColor: AppTheme.error),
                      );
                    }
                  },
                  child: Text(
                    isEdit ? "GUARDAR CAMBIOS" : "CREAR CLIENTE",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int pages = _size > 0 ? (_total / _size).ceil() : 1;
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Clientes")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              onChanged: _onSearch,
              decoration: const InputDecoration(
                hintText: "Buscar por nombre...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _load
                ? const Center(child: CircularProgressIndicator())
                : _list.isEmpty 
                  ? const Center(child: Text("No se encontraron clientes"))
                  : ListView.builder(
                    itemCount: _list.length,
                    itemBuilder: (c, i) {
                      final item = _list[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primary.withOpacity(0.2),
                            child: Text(
                              item.id.length >= 2 ? item.id.substring(0, 2) : "XX",
                              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ID: ${item.id}"),
                              Text("Saldo: \$${item.currentBalance.toStringAsFixed(2)}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _form(c: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  // Confirmación antes de borrar
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Confirmar"),
                                      content: Text("¿Eliminar a ${item.name}?"),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Eliminar", style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  
                                  if (confirm == true) {
                                    await _api.deleteCustomer(item.id);
                                    _fetch();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (pages > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _page > 1
                        ? () {
                            setState(() => _page--);
                            _fetch();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text("Página $_page de $pages", style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _page < pages
                        ? () {
                            setState(() => _page++);
                            _fetch();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _form(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}