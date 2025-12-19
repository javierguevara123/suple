import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectomovil/models/customer.dart';
import 'package:proyectomovil/models/orderdetail.dart';
import 'package:proyectomovil/models/product.dart';
import '../../services/api_service.dart';
import '../../services/image_service.dart';
import '../../config/theme.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});
  @override
  State<OrderFormScreen> createState() => _OFS();
}

class _OFS extends State<OrderFormScreen> {
  final _api = ApiService();
  Customer? _c;
  final List<OrderDetail> _k = [];
  bool _s = false;

  // --- CONTROLADORES DE DIRECCIÓN ---
  // Estos recogen lo que el usuario escribe
  final _addressCtrl = TextEditingController(text: "Av. Principal");
  final _cityCtrl = TextEditingController(text: "Quito");
  final _countryCtrl = TextEditingController(text: "Ecuador");

  double get _subtotal => _k.fold(0, (s, i) => s + i.subtotal);
  double get _iva => _subtotal * 0.15;
  double get _total => _subtotal + _iva;

  void _selCli() async {
    await showDialog(
      context: context,
      builder: (ctx) => _SearchDialog<Customer>(
        t: "Cliente",
        // Usamos el wrapper para adaptar la paginación al buscador simple
        f: _api.getCustomersPaginatedWrapper,
        b: (x) => ListTile(
          leading: const Icon(Icons.person),
          title: Text(x.name),
          subtitle: Text("ID: ${x.id}"),
        ),
        s: (x) => setState(() => _c = x),
      ),
    );
  }

  void _addProd() async {
    if (_c == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione cliente primero")),
      );
      return;
    }
    await showDialog(
      context: context,
      builder: (ctx) => _SearchDialog<Product>(
        t: "Producto",
        f: _api.getProducts,
        b: (x) => ListTile(
          leading: ImageService.getImage('product', x.id.toString()),
          title: Text(x.name),
          subtitle: Text("Stock: ${x.unitsInStock}"),
          enabled: x.unitsInStock > 0,
        ),
        s: (x) {
          setState(() {
            final idx = _k.indexWhere((e) => e.productId == x.id);
            if (idx >= 0) {
              if (_k[idx].quantity < x.unitsInStock) {
                _k[idx].quantity++;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Stock insuficiente")),
                );
              }
            } else {
              _k.add(
                OrderDetail(
                  productId: x.id,
                  productName: x.name,
                  unitPrice: x.unitPrice,
                  quantity: 1,
                ),
              );
            }
          });
        },
      ),
    );
  }

  void _send() async {
    // 1. Validaciones
    if (_c == null) return;
    if (_k.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Agregue productos")));
      return;
    }
    if (_addressCtrl.text.isEmpty ||
        _cityCtrl.text.isEmpty ||
        _countryCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos de envío incompletos")),
      );
      return;
    }

    setState(() => _s = true);
    try {
      // 2. Llamada a la API con los 5 parámetros (ID, Detalles, Dirección, Ciudad, País)
      final id = await _api.createOrder(
        _c!.id,
        _k,
        _addressCtrl.text,
        _cityCtrl.text,
        _countryCtrl.text,
      );

      if (mounted) context.pushReplacement('/invoice/$id');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: AppTheme.error),
        );
    } finally {
      if (mounted) setState(() => _s = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Orden")),
      body: Column(
        children: [
          // Selección de Cliente
          ListTile(
            title: Text(
              _c?.name ?? "Seleccionar Cliente",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: _c != null ? Text("ID: ${_c!.id}") : null,
            leading: const CircleAvatar(child: Icon(Icons.person)),
            onTap: _selCli,
            trailing: const Icon(Icons.arrow_drop_down),
          ),
          const Divider(height: 1),

          // --- FORMULARIO DE DIRECCIÓN (NUEVO) ---
          ExpansionTile(
            title: const Text("Datos de Envío"),
            leading: const Icon(Icons.local_shipping),
            initiallyExpanded: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: "Dirección",
                        isDense: true,
                        prefixIcon: Icon(Icons.map),
                      ),
                      // PROTECCIÓN: Máximo 60 caracteres para evitar error de BD
                      maxLength: 60,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityCtrl,
                            decoration: const InputDecoration(
                              labelText: "Ciudad",
                              isDense: true,
                            ),
                            // PROTECCIÓN: Máximo 15 caracteres
                            maxLength: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _countryCtrl,
                            decoration: const InputDecoration(
                              labelText: "País",
                              isDense: true,
                            ),
                            // PROTECCIÓN: Máximo 15 caracteres
                            maxLength: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1),

          // Lista de Productos
          Expanded(
            child: _k.isEmpty
                ? Center(
                    child: Text(
                      "Sin productos",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  )
                : ListView.separated(
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _k.length,
                    itemBuilder: (c, i) => ListTile(
                      title: Text(_k[i].productName),
                      subtitle: Text(
                        "${_k[i].quantity} x \$${_k[i].unitPrice}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "\$${_k[i].subtotal.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () => setState(() => _k.removeAt(i)),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Botones y Totales
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOTAL:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "\$${_total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _addProd,
                        child: const Text("AGREGAR PRODUCTO"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _k.isEmpty || _s ? null : _send,
                        child: _s
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("PAGAR"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extensión necesaria para conectar la paginación con el buscador simple
extension on ApiService {
  Future<List<Customer>> getCustomersPaginatedWrapper(String q) async {
    try {
      final r = await getCustomersPaginated(
        page: 1,
        pageSize: 20,
        searchTerm: q,
      );
      return r['items'];
    } catch (_) {
      return [];
    }
  }
}

// Widget de búsqueda (Dialog)
class _SearchDialog<T> extends StatefulWidget {
  final String t;
  final Future<List<T>> Function(String) f;
  final Widget Function(T) b;
  final Function(T) s;
  const _SearchDialog({
    required this.t,
    required this.f,
    required this.b,
    required this.s,
  });
  @override
  State<_SearchDialog<T>> createState() => _SDS<T>();
}

class _SDS<T> extends State<_SearchDialog<T>> {
  List<T> _l = [];
  final _c = TextEditingController();

  @override
  void initState() {
    super.initState();
    _q();
  }

  void _q() async {
    try {
      final r = await widget.f(_c.text);
      if (mounted) setState(() => _l = r);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Buscar ${widget.t}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _c,
              onSubmitted: (_) => _q(),
              decoration: InputDecoration(
                hintText: "Escriba para buscar...",
                suffixIcon: IconButton(
                  onPressed: _q,
                  icon: const Icon(Icons.search),
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: _l.isEmpty
                  ? const Center(child: Text("Sin resultados"))
                  : ListView.separated(
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: _l.length,
                      itemBuilder: (c, i) => InkWell(
                        onTap: () {
                          widget.s(_l[i]);
                          Navigator.pop(context);
                        },
                        child: widget.b(_l[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
