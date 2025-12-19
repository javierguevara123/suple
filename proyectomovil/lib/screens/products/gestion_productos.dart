import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyectomovil/models/product.dart';
import '../../services/api_service.dart';
import '../../services/image_service.dart';
import '../../config/theme.dart';

class GestionProductosScreen extends StatefulWidget {
  const GestionProductosScreen({super.key});

  @override
  State<GestionProductosScreen> createState() => _GPSState();
}

class _GPSState extends State<GestionProductosScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();

  // Estado
  List<Product> _productos = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE DATOS ---

  Future<void> _cargarProductos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Usamos el servicio API. Si tu API soporta paginación real para productos,
      // aquí deberías implementar la misma lógica que en Clientes.
      // Por ahora cargamos la lista basada en la búsqueda.
      final lista = await _api.getProducts(_searchCtrl.text);

      setState(() {
        _productos = lista;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al cargar inventario"),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _cargarProductos);
  }

  // --- LÓGICA DE IMÁGENES ---

  Future<void> _cambiarImagen(Product producto) async {
    final picker = ImagePicker();
    // Mostrar selector inferior
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );
                if (image != null)
                  _guardarImagen(producto.id, File(image.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                );
                if (image != null)
                  _guardarImagen(producto.id, File(image.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarImagen(int id, File imagen) async {
    await ImageService.saveImage('product', id.toString(), imagen);
    setState(() {}); // Forzar repintado para mostrar la nueva imagen
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Imagen actualizada"),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  // --- FORMULARIO (CREAR / EDITAR) ---

  void _mostrarFormulario({Product? producto}) {
    final esEdicion = producto != null;
    final nameCtrl = TextEditingController(text: producto?.name);
    final priceCtrl = TextEditingController(
      text: producto?.unitPrice.toString(),
    );
    final stockCtrl = TextEditingController(
      text: producto?.unitsInStock.toString(),
    );
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado del Modal
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: esEdicion
                            ? Colors.orange.withOpacity(0.1)
                            : AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        esEdicion ? Icons.edit : Icons.add_box,
                        color: esEdicion ? Colors.orange : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      esEdicion ? "Editar Producto" : "Nuevo Producto",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Formulario
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nombre del Producto",
                          prefixIcon: Icon(Icons.shopping_bag_outlined),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "El nombre es obligatorio" : null,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: priceCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: "Precio Unit.",
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return "Requerido";
                                final n = double.tryParse(value);
                                if (n == null || n < 0) return "Inválido";
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextFormField(
                              controller: stockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Stock",
                                prefixIcon: Icon(Icons.inventory_2_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return "Requerido";
                                final n = int.tryParse(value);
                                if (n == null || n < 0) return "Inválido";
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Botón de Guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;

                            setModalState(() => isSaving = true);

                            // Preparar datos
                            final dataMap = {
                              "name": nameCtrl.text,
                              "unitPrice": double.parse(priceCtrl.text),
                              "unitsInStock": int.parse(stockCtrl.text),
                            };

                            bool success;
                            if (esEdicion) {
                              // Crear objeto producto actualizado
                              final prodUpdate = Product(
                                id: producto.id,
                                name: dataMap['name'] as String,
                                unitPrice: dataMap['unitPrice'] as double,
                                unitsInStock: dataMap['unitsInStock'] as int,
                              );
                              success = await _api.updateProduct(prodUpdate);
                            } else {
                              success = await _api.createProduct(dataMap);
                            }

                            setModalState(() => isSaving = false);

                            if (success) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              _cargarProductos();
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    esEdicion
                                        ? "Producto actualizado"
                                        : "Producto creado",
                                  ),
                                  backgroundColor: AppTheme.success,
                                ),
                              );
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Error al guardar"),
                                  backgroundColor: AppTheme.error,
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Guardar Producto",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- VISTA PRINCIPAL ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Fondo Decorativo Superior
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Gestión de Productos",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Barra de Búsqueda
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: "Buscar producto...",
                        prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        fillColor: Colors
                            .transparent, // Transparente porque el contenedor ya es blanco
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Lista de Productos
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _productos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "No se encontraron productos",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          itemCount: _productos.length,
                          itemBuilder: (context, index) {
                            final prod = _productos[index];
                            final bool agotado = prod.unitsInStock == 0;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                // Imagen del producto (o placeholder)
                                leading: GestureDetector(
                                  onTap: () => _cambiarImagen(prod),
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Hero(
                                        tag: 'prod_${prod.id}',
                                        child: ImageService.getImage(
                                          'product',
                                          prod.id.toString(),
                                          size: 60,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  prod.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        // Badge de Stock
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: agotado
                                                ? Colors.red.withOpacity(0.1)
                                                : Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            agotado
                                                ? "Agotado"
                                                : "${prod.unitsInStock} un.",
                                            style: TextStyle(
                                              color: agotado
                                                  ? Colors.red
                                                  : Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$${prod.unitPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () =>
                                          _mostrarFormulario(producto: prod),
                                      child: const Text(
                                        "Editar",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: AppTheme.secondary,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text(
          "Nuevo Producto",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
