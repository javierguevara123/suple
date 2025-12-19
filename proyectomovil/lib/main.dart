import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ 1. IMPORTANTE PARA FECHAS

// Configuración y Tema
import 'package:proyectomovil/config/theme.dart';

// Pantallas de Autenticación
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/customer_register_screen.dart';

// Pantallas Generales
import 'screens/dashboard/menu_principal.dart';
import 'screens/dashboard/perfil_usuario.dart';

// Pantallas de Clientes (Customer)
import 'screens/customer/customer_home.dart';
import 'screens/customer/customer_perfil.dart';
import 'screens/customer/invoice_screen.dart'; // ✅ Importamos la nueva pantalla de factura

// Pantallas de Administración
import 'screens/admin/clientes_screen.dart';
import 'screens/admin/usuarios_screen.dart';
import 'screens/admin/desbloquear_cuenta.dart';

// Pantallas de Productos y Ventas
import 'screens/products/gestion_productos.dart';
import 'screens/sales/order_form.dart';
import 'screens/sales/listado_facturas.dart';

void main() {
  // Permitir certificados autofirmados (Solo desarrollo)
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NorthWind',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,

      // ✅ 2. CONFIGURACIÓN DE LOCALIZACIÓN (EVITA QUE SE CONGELE EL DATEPICKER)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // Inglés
        Locale('es', 'ES'), // Español
      ],
    );
  }
}

// Configuración de Rutas (GoRouter)
final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    // --- AUTENTICACIÓN ---
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()), // Registro Admin
    GoRoute(
      path: '/customer-register',
      builder: (context, state) => const CustomerRegisterScreen(),
    ),

    // --- MENÚ PRINCIPAL ---
    GoRoute(path: '/menu', builder: (_, __) => const MenuPrincipalScreen()),

    // --- PERFILES ---
    GoRoute(path: '/perfil', builder: (_, __) => const PerfilUsuarioScreen()), // Perfil Admin
    
    // Perfil de Cliente (Edición propia)
    GoRoute(
      path: '/customer-profile',
      builder: (_, __) => const CustomerProfileScreen(), 
    ),

    // --- ADMINISTRACIÓN ---
    GoRoute(path: '/clientes', builder: (_, __) => const ClientesScreen()),
    GoRoute(path: '/usuarios', builder: (_, __) => const UsuariosScreen()),
    GoRoute(
      path: '/desbloqueo',
      builder: (_, __) => const DesbloquearCuentasScreen(),
    ),

    // --- PRODUCTOS Y VENTAS (ADMIN) ---
    GoRoute(
      path: '/productos',
      builder: (_, __) => const GestionProductosScreen(),
    ),
    GoRoute(path: '/order', builder: (_, __) => const OrderFormScreen()),
    GoRoute(
      path: '/facturas',
      builder: (_, __) => const ListadoFacturasScreen(), // Listado general admin
    ),

    // ✅ RUTA DINÁMICA DE FACTURA (DETALLE)
    GoRoute(
      path: '/invoice/:id',
      builder: (_, state) {
        // Convertimos el ID de string a int
        final orderId = int.parse(state.pathParameters['id']!);
        return InvoiceScreen(orderId: orderId);
      },
    ),

    // --- HOME DE CLIENTE ---
    GoRoute(path: '/customer', builder: (_, __) => const CustomerHomeScreen()),
  ],
);

// Clase para ignorar errores de certificado SSL en desarrollo
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (c, h, p) => true;
  }
}