import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyectomovil/models/customer.dart';
import 'package:proyectomovil/models/product.dart';
import 'package:proyectomovil/models/user.dart';
import 'package:proyectomovil/models/order.dart';
import 'package:proyectomovil/models/orderdetail.dart';
import '../config/theme.dart';

class ApiService {
  /// Obtiene los headers con el token si existe
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      "Content-Type": "application/json",
      "accept":
          "application/json", // Cambiado a application/json para mejor compatibilidad
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ===========================================================================
  // 🔐 SECCIÓN NUEVA: AUTENTICACIÓN Y REGISTRO DE CLIENTES (PUBLICO)
  // ===========================================================================

  /// ✅ Login exclusivo para Clientes (Endpoint: /api/customers/login)
  Future<Map<String, dynamic>> loginCustomerPublic(
    String email,
    String password,
  ) async {
    try {
      print(
        '🔐 Intentando login de cliente en: ${ApiConfig.baseUrl}/api/customers/login',
      );

      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/customers/login'),
            headers: {
              "Content-Type": "application/json",
              "accept": "application/json",
            },
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      print('Status Code: ${res.statusCode}');
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        // La API devuelve: { "token": "...", "customerId": "ANATR", "name": "..." }
        return {
          'success': true,
          'token': data['token'],
          'customerId': data['customerId'],
          'name': data['name'],
          'message': 'Bienvenido',
        };
      }

      return {
        'success': false,
        'message': data['detail'] ?? 'Credenciales inválidas o acceso denegado',
      };
    } catch (e) {
      print('Error login: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// ✅ Registro público de nuevos clientes (Endpoint: /api/customers/register)
  Future<Map<String, dynamic>> registerCustomerPublic({
    required String customerId,
    required String name,
    required String email,
    required String password,
    required String cedula,
    String? profilePictureBase64,
    // ✅ NUEVOS PARÁMETROS
    String? address,
    String? phone,
    DateTime? birthDate,
  }) async {
    try {
      final body = {
        "id": customerId,
        "name": name,
        "email": email,
        "cedula": cedula,
        "password": password,
        "currentBalance": 0,
        "profilePictureBase64": profilePictureBase64,
        // ✅ ENVIAR AL BACKEND
        "address": address,
        "phone": phone,
        "birthDate": birthDate?.toIso8601String(),
      };

      print(body);

      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/customers/register'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'success': true, 'message': 'Cliente registrado exitosamente'};
      }

      // Manejo de errores 400 (Validaciones)
      try {
        final errorJson = jsonDecode(res.body);

        // CASO A: El backend devuelve una LISTA de errores (Tu caso actual)
        // Estructura: [ { "propertyName": "Cedula", "errorMessage": "..." }, ... ]
        if (errorJson['errors'] is List) {
          Map<String, String> standardizedErrors = {};

          for (var err in errorJson['errors']) {
            // Mapeamos "propertyName" -> "errorMessage"
            if (err['propertyName'] != null && err['errorMessage'] != null) {
              standardizedErrors[err['propertyName']] = err['errorMessage'];
            }
          }

          return {
            'success': false,
            'message': 'Por favor corrige los errores.',
            'errors':
                standardizedErrors, // Devolvemos un Mapa limpio: {"Cedula": "Error...", "Email": "Error..."}
          };
        }

        // CASO B: El backend devuelve un MAPA estándar (ASP.NET por defecto)
        // Estructura: { "Email": ["Error..."], ... }
        if (errorJson['errors'] is Map) {
          // ... código anterior o simplificación ...
          return {
            'success': false,
            'message': 'Error de validación',
            'errors': errorJson['errors'],
          };
        }

        return {
          'success': false,
          'message':
              errorJson['detail'] ??
              errorJson['title'] ??
              'Error en el registro',
        };
      } catch (_) {
        return {
          'success': false,
          'message': 'Error del servidor: ${res.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ===========================================================================
  // 🛠️ MÉTODOS LEGACY / ADMIN (Usuarios del sistema, no clientes)
  // ===========================================================================

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/Login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'token': data['accessToken']};
      }
      return {
        'success': false,
        'message': data['detail'] ?? "Credenciales inválidas",
      };
    } catch (e) {
      return {'success': false, 'message': "Error de conexión"};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/user/Register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return {'success': true};
    final err = jsonDecode(res.body);
    String msg = err['detail'] ?? "Error";
    if (err['errors'] != null) {
      msg = (err['errors'] as List).map((e) => e['errorMessage']).join('\n');
    }
    return {'success': false, 'message': msg};
  }

  // ===========================================================================
  // 📦 GESTIÓN DE PRODUCTOS
  // ===========================================================================

  Future<List<Product>> getProducts(String search) async {
    try {
      final headers = await _headers();
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/products').replace(
        queryParameters: {
          'PageNumber': '1',
          'PageSize': '50',
          'OrderDescending': 'false',
          if (search.isNotEmpty) 'SearchTerm': search,
        },
      );

      var res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      // ⚠️ Fallback para errores de Auth o permisos (Datos Mock)
      if (res.statusCode == 403 || res.statusCode == 401) {
        print('⚠️ Error ${res.statusCode} - Usando productos de ejemplo');
        return _getMockProducts();
      }

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final items = data['items'] as List? ?? [];
        return items.map((e) => Product.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print('Exception en getProducts: $e');
      return _getMockProducts();
    }
  }

  Future<bool> createProduct(Map<String, dynamic> p) async {
    final headers = await _headers();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/CreateProduct'),
      headers: headers,
      body: jsonEncode(p),
    );
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  Future<bool> updateProduct(Product p) async {
    final headers = await _headers();
    final res = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/UpdateProduct/${p.id}'),
      headers: headers,
      body: jsonEncode(p.toJson()),
    );
    return res.statusCode == 200;
  }

  // ===========================================================================
  // 🛒 GESTIÓN DE ÓRDENES (VENTAS)
  // ===========================================================================

  Future<int> createOrder(
    String customerId,
    List<OrderDetail> details,
    String address,
    String city,
    String country,
  ) async {
    final headers = await _headers();
    final payload = {
      "customerId": customerId,
      "shipAddress": address,
      "shipCity": city,
      "shipCountry": country,
      "shipPostalCode": "170101", // Código postal genérico
      "orderDetails": details.map((d) => d.toJson()).toList(),
    };

    print('🛒 Creando orden para CustomerID: $customerId');

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/CreateOrder'),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      // Si retorna { id: 123 }
      try {
        return jsonDecode(res.body)['id'];
      } catch (_) {
        return 0; // Éxito pero sin ID retornado
      }
    }

    throw Exception("Error creando orden (${res.statusCode}): ${res.body}");
  }

  Future<List<Order>> getOrders(String customerId) async {
    final headers = await _headers();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/orders').replace(
      queryParameters: {
        'PageNumber': '1',
        'PageSize': '20',
        'OrderDescending': 'true',
        if (customerId.isNotEmpty) 'CustomerId': customerId,
      },
    );
    final res = await http.get(uri, headers: headers);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body)['items'] as List)
          .map((e) => Order.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<Order> getOrderById(int id) async {
    final headers = await _headers();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/GetOrderById/$id'),
      headers: headers,
    );
    if (res.statusCode == 200) return Order.fromJson(jsonDecode(res.body));
    throw Exception("Orden no encontrada");
  }

  // ===========================================================================
  // 👥 GESTIÓN DE CLIENTES (ADMINISTRACIÓN)
  // ===========================================================================

  Future<List<Customer>> getCustomers(String query) async {
    try {
      final res = await getCustomersPaginated(
        page: 1,
        pageSize: 50,
        searchTerm: query,
      );
      return (res['items'] as List).map((e) => e as Customer).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getCustomersPaginated({
    required int page,
    required int pageSize,
    String searchTerm = '',
  }) async {
    final headers = await _headers();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/customers').replace(
      queryParameters: {
        'PageNumber': page.toString(),
        'PageSize': pageSize.toString(),
        'OrderDescending': 'false',
        if (searchTerm.isNotEmpty) 'SearchTerm': searchTerm,
      },
    );
    final res = await http.get(uri, headers: headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return {
        'items': (data['customers'] as List)
            .map((e) => Customer.fromJson(e))
            .toList(),
        'totalRecords': data['totalRecords'] ?? 0,
      };
    }
    throw Exception("Error cargando clientes");
  }

  Future<Customer?> getCustomerById(String id) async {
    final headers = await _headers();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/GetCustomerById/$id'),
      headers: headers,
    );
    if (res.statusCode == 200) return Customer.fromJson(jsonDecode(res.body));
    return null;
  }

  // ✅ Actualizar Cliente con manejo de errores de validación
  Future<Map<String, dynamic>> updateCustomer({
    required String id,
    required String name,
    required String cedula,
    required String email,
    String? profilePictureBase64,
    String? password,
    // ✅ NUEVOS PARÁMETROS
    String? address,
    String? phone,
    DateTime? birthDate,
  }) async {
    try {
      final headers = await _headers();
      final body = {
        "id": id,
        "name": name,
        "cedula": cedula,
        "email": email,
        "currentBalance": 0,
        "profilePictureBase64": profilePictureBase64,
        "password": password,
        // ✅ ENVIAR AL BACKEND
        "address": address,
        "phone": phone,
        "birthDate": birthDate?.toIso8601String(),
      };

      final res = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/UpdateCustomer/$id'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      // ÉXITO
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'success': true, 'message': 'Perfil actualizado correctamente'};
      }

      // MANEJO DE ERRORES (400 Bad Request)
      try {
        final errorJson = jsonDecode(res.body);

        // Caso Específico: Lista de errores de validación (Tu Backend)
        // JSON: { "errors": [ { "propertyName": "Email", "errorMessage": "..." } ] }
        if (errorJson['errors'] is List) {
          Map<String, String> standardizedErrors = {};
          for (var err in errorJson['errors']) {
            if (err['propertyName'] != null && err['errorMessage'] != null) {
              // Guardamos: "Email" -> "El correo ya existe..."
              standardizedErrors[err['propertyName']] = err['errorMessage'];
            }
          }
          return {
            'success': false,
            'message': 'Error de validación',
            'errors': standardizedErrors, // Retornamos el mapa limpio
          };
        }

        return {
          'success': false,
          'message': errorJson['detail'] ?? 'Error al actualizar',
        };
      } catch (_) {
        return {
          'success': false,
          'message': 'Error del servidor: ${res.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<bool> deleteCustomer(String id) async {
    final headers = await _headers();
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/DeleteCustomer/$id'),
      headers: headers,
    );
    return res.statusCode == 200;
  }

  // ===========================================================================
  // 🛠️ UTILIDADES Y GESTIÓN DE USUARIOS
  // ===========================================================================

  /// Helper: Generar ID para cliente (Solo letras y longitud fija)
  String _generateCustomerId(String name) {
    String base = name.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    if (base.length < 3) base = "CUST";
    base = base.substring(0, base.length > 3 ? 3 : base.length);

    final random = Random();
    String suffix = String.fromCharCodes(
      List.generate(2, (i) => random.nextInt(26) + 65),
    );

    // Asegurar 5 caracteres
    return (base + suffix).padRight(5, 'X').substring(0, 5);
  }

  Future<List<User>> getUsers() async {
    final headers = await _headers();
    final res = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/user/GetAllUsers?PageNumber=1&PageSize=50',
      ),
      headers: headers,
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body)['items'] as List)
          .map((e) => User.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<List<User>> getLockedUsers() async {
    final headers = await _headers();
    final res = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/user/GetLockedOutUsers?PageNumber=1&PageSize=50',
      ),
      headers: headers,
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body)['items'] as List)
          .map((e) => User.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<bool> unlockUser(String email) async {
    final headers = await _headers();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/user/UnlockUser'),
      headers: headers,
      body: jsonEncode({"email": email}),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteUser(String email) async {
    final headers = await _headers();
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/user/DeleteUser?email=$email'),
      headers: headers,
    );
    return res.statusCode == 200;
  }

  Future<bool> updateUser(Map<String, dynamic> data) async {
    final headers = await _headers();
    final res = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/user/UpdateUser'),
      headers: headers,
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  // --- DATOS MOCK (Para cuando falla la API o token expira) ---
  List<Product> _getMockProducts() {
    return [
      Product(id: 1, name: "Chai (Demo)", unitPrice: 18.0, unitsInStock: 39),
      Product(id: 2, name: "Chang (Demo)", unitPrice: 19.0, unitsInStock: 17),
      Product(
        id: 3,
        name: "Aniseed Syrup (Demo)",
        unitPrice: 10.0,
        unitsInStock: 13,
      ),
      Product(
        id: 4,
        name: "Chef Anton's Cajun Seasoning",
        unitPrice: 22.0,
        unitsInStock: 53,
      ),
      Product(
        id: 11,
        name: "Queso Cabrales",
        unitPrice: 21.0,
        unitsInStock: 22,
      ),
    ];
  }

  Future<String?> createCustomer(Map<String, dynamic> data) async {
    final headers = await _headers();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/CreateCustomer'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return null;
    return res.body;
  }

  // ✅ Obtener mis órdenes (Filtrado por CustomerId)
  Future<List<dynamic>> getMyOrders(String customerId) async {
    try {
      final headers = await _headers();
      // Construimos la URL con los parámetros del Swagger
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/orders').replace(
        queryParameters: {
          'PageNumber': '1',
          'PageSize': '50', // Traemos las últimas 50
          'CustomerId': customerId,
          'OrderDescending': 'true', // Las más recientes primero
        },
      );

      final res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // El JSON devuelve { "items": [...] }
        return data['items'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Error obteniendo órdenes: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getOrderFullDetails(int id) async {
    final headers = await _headers();
    // Intenta con el endpoint que tengas disponible.
    // Opción A: GetOrderById (si devuelve el detalle)
    // Opción B: /api/orders/{id}
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/GetOrderById/$id'),
      headers: headers,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception("No se pudo cargar el detalle de la orden");
  }
}
