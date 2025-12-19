import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/image_service.dart';
import '../../config/theme.dart';
// IMPORTANTE: Importa la nueva pantalla que acabas de crear
import '../customer/customer_home.dart';

class MenuPrincipalScreen extends StatefulWidget {
  const MenuPrincipalScreen({super.key});
  @override
  State<MenuPrincipalScreen> createState() => _MS();
}

class _MS extends State<MenuPrincipalScreen> {
  String _n = '', _r = '', _e = '';
  bool _isAdmin = false;
  bool _isCustomer = false; // Bandera para saber si es cliente

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _n = p.getString('fullName') ?? '';
      _r = p.getString('role') ?? 'Customer';
      _e = p.getString('email') ?? '';

      _isAdmin = (_r == 'Administrator' || _r == 'SuperUser');
      // Si no es Admin ni Employee, lo tratamos como Customer
      _isCustomer = !_isAdmin && _r != 'Employee';
    });
  }

  @override
  Widget build(BuildContext context) {
    // SI ES CLIENTE, MUESTRA SOLO EL CARRITO/CATÁLOGO
    if (_isCustomer) {
      return const CustomerHomeScreen();
    }

    // SI ES ADMIN/EMPLEADO, MUESTRA EL MENÚ COMPLETO
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hola, $_n",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _r,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          context.push('/perfil').then((_) => setState(() {})),
                      child: Hero(
                        tag: 'p',
                        child: ImageService.getImage(
                          'user',
                          _e,
                          size: 60,
                          fallbackIcon: Icons.person,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _Card(
                        "Nueva Venta",
                        Icons.point_of_sale,
                        Colors.green,
                        () => context.push('/order'),
                      ),
                      _Card(
                        "Facturas",
                        Icons.receipt_long,
                        Colors.blueGrey,
                        () => context.push('/facturas'),
                      ),
                      _Card(
                        "Productos",
                        Icons.inventory,
                        Colors.orange,
                        () => context.push('/productos'),
                      ),
                      _Card(
                        "Clientes",
                        Icons.people,
                        Colors.blue,
                        () => context.push('/clientes'),
                      ),
                      if (_isAdmin)
                        _Card(
                          "Usuarios",
                          Icons.security,
                          Colors.purple,
                          () => context.push('/usuarios'),
                        ),
                      if (_isAdmin)
                        _Card(
                          "Desbloqueo",
                          Icons.lock_open,
                          Colors.teal,
                          () => context.push('/desbloqueo'),
                        ),
                      _Card(
                        "Salir",
                        Icons.logout,
                        Colors.red,
                        () => context.go('/login'),
                      ),
                    ],
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

class _Card extends StatelessWidget {
  final String t;
  final IconData i;
  final Color c;
  final VoidCallback f;
  const _Card(this.t, this.i, this.c, this.f);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: f,
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, size: 35, color: c),
            const SizedBox(height: 10),
            Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
