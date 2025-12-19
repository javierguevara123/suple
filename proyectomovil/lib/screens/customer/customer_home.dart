import 'dart:async';
import 'dart:convert'; // ✅ Necesario para base64Decode
import 'dart:typed_data'; // ✅ Necesario para Uint8List
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyectomovil/config/theme.dart';
import 'package:proyectomovil/models/customer.dart';
import 'package:proyectomovil/models/orderdetail.dart';
import 'package:proyectomovil/models/product.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _api = ApiService();
  int _selectedIndex = 0;
  final List<OrderDetail> _cart = [];

  Customer? _myCustomerProfile;

  final _addressCtrl = TextEditingController(text: "Mi Domicilio");
  final _cityCtrl = TextEditingController(text: "Quito");
  final _countryCtrl = TextEditingController(text: "Ecuador");
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _autoSelectClient();
  }

  Uint8List? _getProfileImageBytes(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      final cleanBase64 = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanBase64);
    } catch (e) {
      return null;
    }
  }

  void _autoSelectClient() async {
    final prefs = await SharedPreferences.getInstance();
    final myName = prefs.getString('fullName') ?? '';
    final myEmail = prefs.getString('email') ?? '';
    final myCustomerId = prefs.getString('customerId') ?? '';

    try {
      if (myCustomerId.isNotEmpty) {
        final customer = await _api.getCustomerById(myCustomerId);
        if (customer != null) {
          if (mounted) {
            setState(() {
              _myCustomerProfile = customer;
            });
          }
          return;
        }
      }

      final customers = await _api.getCustomers(myName);
      final myClient = customers.firstWhere(
        (c) => c.name.toLowerCase().trim() == myName.toLowerCase().trim(),
        orElse: () => Customer(
          id: "TEMP1",
          name: myName.isEmpty ? "Cliente Nuevo" : myName,
          email: myEmail.isEmpty ? "cliente@example.com" : myEmail,
          currentBalance: 500.00,
        ),
      );

      if (mounted) {
        setState(() {
          _myCustomerProfile = myClient;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _myCustomerProfile = Customer(
            id: "TEMP1",
            name: myName.isEmpty ? "Cliente Nuevo" : myName,
            email: myEmail.isEmpty ? "cliente@example.com" : myEmail,
            currentBalance: 500.00,
          );
        });
      }
    }
  }

  void _addToCart(Product product) {
    setState(() {
      final alreadyInCart = _cart.any((item) => item.productId == product.id);

      if (alreadyInCart) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ ${product.name} ya está en tu carrito"),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: "VER CARRITO",
              textColor: Colors.white,
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
          ),
        );
      } else {
        if (product.unitsInStock > 0) {
          _cart.add(
            OrderDetail(
              productId: product.id,
              productName: product.name,
              unitPrice: product.unitPrice,
              quantity: 1,
              maxStock: product.unitsInStock,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Agregado: ${product.name}"),
              backgroundColor: AppTheme.success,
              duration: const Duration(milliseconds: 800),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Producto agotado"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() => _cart.removeAt(index));
  }

  void _updateCartQuantity(int index, int newQty) {
    setState(() {
      _cart[index].quantity = newQty;
    });
  }

  void _processOrder() async {
    if (_cart.isEmpty) return _showError("Carrito vacío");

    final clientToUse =
        _myCustomerProfile ??
        Customer(
          id: "GUEST",
          name: "Invitado",
          email: "guest@example.com",
          currentBalance: 0,
        );

    setState(() => _loading = true);
    try {
      final orderId = await _api.createOrder(
        clientToUse.id,
        _cart,
        _addressCtrl.text,
        _cityCtrl.text,
        _countryCtrl.text,
      );

      if (mounted) {
        setState(() => _cart.clear());
        context.push('/invoice/$orderId');
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _ProductCatalog(api: _api, onAdd: _addToCart);
      case 1:
        return _CartView(
          cart: _cart,
          client: _myCustomerProfile,
          addressCtrl: _addressCtrl,
          cityCtrl: _cityCtrl,
          countryCtrl: _countryCtrl,
          loading: _loading,
          onRemove: _removeFromCart,
          onCheckout: _processOrder,
          onUpdateQuantity: _updateCartQuantity,
        );
      case 2:
        return _OrdersHistoryView(
          api: _api,
          customerId: _myCustomerProfile?.id ?? "",
        );
      default:
        return const Center(child: Text("Vista no encontrada"));
    }
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Productos";
      case 1:
        return "Mi Carrito";
      case 2:
        return "Mis Pedidos";
      default:
        return "NorthWind";
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileBytes = _getProfileImageBytes(
      _myCustomerProfile?.profilePictureBase64,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          // ✅ CAMBIO: Actualización instantánea al volver del perfil
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () async {
                // 1. Esperar a que regrese de la pantalla de perfil
                await context.push('/customer-profile');
                // 2. Recargar datos inmediatamente
                _autoSelectClient();
              },
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                // Key para forzar repintado si cambia la imagen
                key: ValueKey(_myCustomerProfile?.profilePictureBase64),
                backgroundImage: profileBytes != null
                    ? MemoryImage(profileBytes)
                    : null,
                child: profileBytes == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Limpiar sesión
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Tienda",
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _cart.isNotEmpty,
              label: Text('${_cart.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: "Carrito",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Pedidos",
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// VISTA HISTORIAL PEDIDOS
// -----------------------------------------------------------------------------
class _OrdersHistoryView extends StatefulWidget {
  final ApiService api;
  final String customerId;

  const _OrdersHistoryView({required this.api, required this.customerId});

  @override
  State<_OrdersHistoryView> createState() => _OrdersHistoryViewState();
}

class _OrdersHistoryViewState extends State<_OrdersHistoryView> {
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void didUpdateWidget(covariant _OrdersHistoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customerId != oldWidget.customerId) {
      _fetchOrders();
    }
  }

  Future<void> _fetchOrders() async {
    if (widget.customerId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (mounted) setState(() => _loading = true);
    try {
      final list = await widget.api.getMyOrders(widget.customerId);
      if (mounted) {
        setState(() {
          _orders = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (widget.customerId.isEmpty)
      return const Center(child: Text("Identifícate para ver tus pedidos"));
    if (_orders.isEmpty)
      return const Center(child: Text("No has realizado pedidos aún."));

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _orders.length,
        itemBuilder: (ctx, i) {
          final order = _orders[i];
          final subtotal = (order['totalAmount'] ?? 0).toDouble();
          final iva = subtotal * 0.15;
          final total = subtotal + iva; // <-- Cambia esto

          final dateStr = order['orderDate'] ?? '';

          String formattedDate = dateStr;
          try {
            final date = DateTime.parse(dateStr);
            formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
          } catch (_) {}

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: const Icon(Icons.receipt, color: AppTheme.primary),
              ),
              title: Text(
                "Orden #${order['orderId']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formattedDate),
                  Text("${order['shipCity']}, ${order['shipCountry']}"),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${total.toStringAsFixed(2)}", // <-- Muestra el total con IVA
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ],
              ),
              onTap: () {
                context.push('/invoice/${order['orderId']}');
              },
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CATÁLOGO DE PRODUCTOS (CON IMÁGENES)
// -----------------------------------------------------------------------------
class _ProductCatalog extends StatefulWidget {
  final ApiService api;
  final Function(Product) onAdd;
  const _ProductCatalog({required this.api, required this.onAdd});
  @override
  State<_ProductCatalog> createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<_ProductCatalog> {
  List<Product> _products = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    if (mounted) setState(() => _loading = true);
    try {
      final list = await widget.api.getProducts(_searchCtrl.text);
      if (mounted) {
        setState(() {
          // ✅ CHANGE: Filter products with stock > 0
          _products = list.where((p) => p.unitsInStock > 0).toList();

          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _loadProducts);
  }

  // Helper para decodificar base64
  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }
      return base64Decode(base64String!);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            decoration: const InputDecoration(
              hintText: "Buscar...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (ctx, i) {
                    final p = _products[i];
                    final imageBytes = _decodeImage(p.profilePictureBase64);

                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: imageBytes != null
                                  ? Image.memory(
                                      imageBytes,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                          ),
                                    )
                                  : Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "\$${p.unitPrice}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Stock: ${p.unitsInStock}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => widget.onAdd(p),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                            ),
                            child: const Text("AGREGAR"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// VISTA DEL CARRITO
// -----------------------------------------------------------------------------
class _CartView extends StatelessWidget {
  final List<OrderDetail> cart;
  final Customer? client;
  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController countryCtrl;
  final bool loading;
  final Function(int) onRemove;
  final VoidCallback onCheckout;
  final Function(int index, int newQty) onUpdateQuantity;

  const _CartView({
    required this.cart,
    required this.client,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.countryCtrl,
    required this.loading,
    required this.onRemove,
    required this.onCheckout,
    required this.onUpdateQuantity,
  });

  Uint8List? _decodeClientImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      final cleanBase64 = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanBase64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientImageBytes = _decodeClientImage(client?.profilePictureBase64);
    double subtotalCalc = cart.fold(0.0, (sum, item) => sum + item.subtotal);
    double ivaCalc = subtotalCalc * 0.15;
    double totalCalc = subtotalCalc + ivaCalc;

    bool hasErrors = cart.any(
      (item) => item.quantity > item.maxStock || item.quantity <= 0,
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              // ✅ FOTO EN EL CARRITO (Se actualiza sola gracias a que 'client' viene actualizado)
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                backgroundImage: clientImageBytes != null
                    ? MemoryImage(clientImageBytes)
                    : null,
                child: clientImageBytes == null
                    ? const Icon(Icons.person, size: 30, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Facturar a:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    client?.name ?? "Cargando...",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Saldo Disponible: \$${client?.currentBalance ?? 0}",
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (hasErrors)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.red.shade100,
            child: const Text(
              "⚠️ Revisa las cantidades en rojo",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),

        Expanded(
          child: cart.isEmpty
              ? const Center(child: Text("Carrito vacío"))
              : ListView.separated(
                  itemCount: cart.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) => _CartItemTile(
                    item: cart[i],
                    onRemove: () => onRemove(i),
                    onQuantityChanged: (val) => onUpdateQuantity(i, val),
                  ),
                ),
        ),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dirección de Envío",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  hintText: "Dirección",
                  isDense: true,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cityCtrl,
                      decoration: const InputDecoration(
                        hintText: "Ciudad",
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: countryCtrl,
                      decoration: const InputDecoration(
                        hintText: "País",
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),

              _SummaryRow(label: "Subtotal:", value: subtotalCalc),
              _SummaryRow(label: "IVA (15%):", value: ivaCalc),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "\$${totalCalc.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (loading || hasErrors) ? null : onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasErrors ? Colors.grey : AppTheme.primary,
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "PAGAR AHORA",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  const _SummaryRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            "\$${value.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatefulWidget {
  final OrderDetail item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const _CartItemTile({
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  late TextEditingController _qtyCtrl;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: widget.item.quantity.toString());
    _checkError(widget.item.quantity);
  }

  @override
  void didUpdateWidget(covariant _CartItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.quantity != int.tryParse(_qtyCtrl.text)) {
      _qtyCtrl.text = widget.item.quantity.toString();
      _checkError(widget.item.quantity);
    }
  }

  void _checkError(int val) {
    setState(() {
      _error = val > widget.item.maxStock || val < 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        widget.item.productName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Precio: \$${widget.item.unitPrice}"),
          Text(
            "Stock máx: ${widget.item.maxStock}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (_error)
            Text(
              widget.item.quantity < 1 ? "Mínimo 1" : "Excede Stock",
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            child: TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _error ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _error ? Colors.red : AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                color: _error ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (val) {
                int newQty = int.tryParse(val) ?? 0;
                _checkError(newQty);
                widget.onQuantityChanged(newQty);
              },
            ),
          ),
          const SizedBox(width: 15),
          Text(
            "\$${widget.item.subtotal.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
