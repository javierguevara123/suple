class Customer {
  final String id;
  final String name;
  final String email;
  final String? cedula;
  final String? profilePictureBase64;
  final double currentBalance;
  
  // ✅ 1. AGREGA ESTAS PROPIEDADES
  final String? address;
  final String? phone;
  final DateTime? birthDate;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.cedula,
    this.profilePictureBase64,
    this.currentBalance = 0.0,
    // ✅ 2. AGRÉGALAS AL CONSTRUCTOR
    this.address,
    this.phone,
    this.birthDate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? json['customerId'] ?? '', // Maneja ambos casos por si acaso
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      cedula: json['cedula'],
      profilePictureBase64: json['profilePictureBase64'],
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      
      // ✅ 3. MAPEA LOS CAMPOS AQUÍ
      address: json['address'],
      phone: json['phone'],
      birthDate: json['birthDate'] != null 
          ? DateTime.tryParse(json['birthDate']) 
          : null,
    );
  }

  // Si tienes un toJson, agrégalos también
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'cedula': cedula,
      'profilePictureBase64': profilePictureBase64,
      'currentBalance': currentBalance,
      // ✅ 4. AGREGAR AL TOJSON
      'address': address,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
    };
  }
}