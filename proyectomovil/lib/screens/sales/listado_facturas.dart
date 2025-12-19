import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectomovil/models/order.dart';
import '../../services/api_service.dart';

class ListadoFacturasScreen extends StatefulWidget {
  const ListadoFacturasScreen({super.key});
  @override
  State<ListadoFacturasScreen> createState() => _LFS();
}

class _LFS extends State<ListadoFacturasScreen> {
  List<Order> _l = [];
  bool _load = true;
  @override
  void initState() {
    super.initState();
    ApiService()
        .getOrders('')
        .then(
          (r) => setState(() {
            _l = r;
            _load = false;
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Facturas")),
      body: _load
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _l.length,
              itemBuilder: (c, i) => ListTile(
                leading: const Icon(Icons.receipt),
                title: Text("Orden #${_l[i].orderId}"),
                subtitle: Text(_l[i].customerName),
                trailing: Text("\$${_l[i].totalAmount.toStringAsFixed(2)}"),
                onTap: () => context.push('/invoice/${_l[i].orderId}'),
              ),
            ),
    );
  }
}
