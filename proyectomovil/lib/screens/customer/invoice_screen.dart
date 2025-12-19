import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formato de moneda y fecha UI
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

// ✅ IMPORTACIONES PARA PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceScreen extends StatefulWidget {
  final int orderId;

  const InvoiceScreen({super.key, required this.orderId});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _api = ApiService();
  bool _loading = true;
  Map<String, dynamic>? _orderData;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final data = await _api.getOrderFullDetails(widget.orderId);
      if (mounted) {
        setState(() {
          _orderData = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error cargando factura: $e")));
      }
    }
  }

  // 🧮 MÉTODO AUXILIAR: CALCULAR TOTALES
  // Esto asegura que la lógica sea idéntica en el PDF y en la Pantalla
  Map<String, double> _calculateTotals(List<dynamic> items) {
    double subtotal = 0;

    for (var item in items) {
      final double quantity = (item['quantity'] ?? 0).toDouble();
      final double price = (item['unitPrice'] ?? 0).toDouble();
      subtotal += quantity * price;
    }

    final double iva = subtotal * 0.15; // 15% sobre el subtotal
    final double total = subtotal + iva;

    return {"subtotal": subtotal, "iva": iva, "total": total};
  }

  // ===========================================================================
  // 🖨️ LÓGICA DE GENERACIÓN Y DISEÑO DEL PDF
  // ===========================================================================
  Future<void> _printPdf() async {
    if (_orderData == null) return;

    // 1. Preparar datos y formatos
    final pdf = pw.Document();
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // ✅ CORRECCIÓN: Usar el cálculo basado en items
    final List<dynamic> items = _orderData!['orderDetails'] ?? [];
    final totals = _calculateTotals(items);
    final double subtotal = totals['subtotal']!;
    final double iva = totals['iva']!;
    final double total = totals['total']!;

    final String clientName = _orderData!['customerName'] ?? 'Cliente';
    final String shipAddress = _orderData!['shipAddress'] ?? '';
    final String shipCity = _orderData!['shipCity'] ?? '';
    final String shipCountry = _orderData!['shipCountry'] ?? '';
    final String orderDate =
        _orderData!['orderDate'] ?? DateTime.now().toString();

    // 2. Definir el diseño de la página
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        header: (context) =>
            _buildPdfHeader(widget.orderId.toString(), orderDate, dateFormat),
        footer: (context) => _buildPdfFooter(context),

        build: (context) => [
          // Sección de Cliente
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "FACTURAR A:",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        clientName.toUpperCase(),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.Text(
                        shipAddress,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        "$shipCity, $shipCountry",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          // Tabla de productos
          pw.Table.fromTextArray(
            headers: ['CANT', 'DESCRIPCIÓN', 'P. UNIT', 'TOTAL'],
            data: items.map((item) {
              final qty = item['quantity'] ?? 0;
              final price = (item['unitPrice'] ?? 0).toDouble();
              final lineTotal = qty * price;
              final name = item['productName'] ?? 'Producto';

              return [
                qty.toString(),
                name,
                currency.format(price),
                currency.format(lineTotal),
              ];
            }).toList(),

            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: .5),
              ),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 5,
            ),
          ),

          pw.SizedBox(height: 20),
          pw.Divider(),

          // Totales
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 200,
              child: pw.Column(
                children: [
                  _buildPdfTotalRow("Subtotal", currency.format(subtotal)),
                  _buildPdfTotalRow("IVA (15%)", currency.format(iva)),
                  pw.Divider(color: PdfColors.grey400),
                  _buildPdfTotalRow(
                    "TOTAL",
                    currency.format(total),
                    isBold: true,
                    color: PdfColors.blue800,
                    fontSize: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Factura_${widget.orderId}.pdf',
    );
  }

  // --- Widgets Auxiliares para PDF ---

  pw.Widget _buildPdfHeader(String orderId, String dateIso, DateFormat fmt) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "MI EMPRESA S.A.",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
                color: PdfColors.blue900,
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  "ORDEN #$orderId",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.Text(
                  fmt.format(DateTime.parse(dateIso)),
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        "Página ${context.pageNumber} de ${context.pagesCount} - Gracias por su compra",
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
      ),
    );
  }

  pw.Widget _buildPdfTotalRow(
    String label,
    String value, {
    bool isBold = false,
    PdfColor? color,
    double fontSize = 12,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 📱 UI DE LA PANTALLA (FLUTTER)
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_orderData == null) {
      return const Scaffold(body: Center(child: Text("Orden no encontrada")));
    }

    // ✅ CORRECCIÓN: Usar el mismo cálculo que el PDF
    final List<dynamic> items = _orderData!['orderDetails'] ?? [];
    final totals = _calculateTotals(items);
    final double subtotal = totals['subtotal']!;
    final double iva = totals['iva']!;
    final double total = totals['total']!;

    final String clientName = _orderData!['customerName'] ?? 'Cliente';
    final String shipCity = _orderData!['shipCity'] ?? '';
    final String shipCountry = _orderData!['shipCountry'] ?? '';
    final String orderDate =
        _orderData!['orderDate'] ?? DateTime.now().toString();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Detalle de Orden"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printPdf,
            tooltip: "Imprimir Factura",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- TARJETA VISUAL ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado UI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "FACTURA",
                              style: TextStyle(
                                letterSpacing: 2,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "#${widget.orderId}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "FECHA",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              dateFormat.format(DateTime.parse(orderDate)),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 40),

                    // Cliente UI
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enviado a:",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                clientName.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("$shipCity, $shipCountry"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Tabla UI
                    const Row(
                      children: [
                        SizedBox(
                          width: 60, // Más ancho para "Cantidad"
                          child: Text(
                            "Cantidad",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Descripción",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: Text(
                            "P.Unit",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: Text(
                            "Total",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),

                    // Lista Items UI
                    ...items.map((item) {
                      final qty = item['quantity'] ?? 0;
                      final price = (item['unitPrice'] ?? 0).toDouble();
                      final totalLine = qty * price;
                      final prodName = item['productName'] ?? 'Producto';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60, // Igual que el header
                              child: Text(
                                "$qty",
                                style: const TextStyle(fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Espacio entre cantidad y nombre
                            Expanded(
                              child: Text(
                                prodName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Espacio entre nombre y precio
                            SizedBox(
                              width: 70,
                              child: Text(
                                currency.format(price),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Espacio entre precio y total
                            SizedBox(
                              width: 70,
                              child: Text(
                                currency.format(totalLine),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const Divider(height: 40),

                    // Totales UI
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 200,
                        child: Column(
                          children: [
                            _buildUiTotalRow("Subtotal", subtotal, currency),
                            _buildUiTotalRow("IVA (15%)", iva, currency),
                            const Divider(),
                            _buildUiTotalRow(
                              "TOTAL",
                              total,
                              currency,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text("Volver a la Tienda"),
                onPressed: () => context.go('/menu'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: AppTheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUiTotalRow(
    String label,
    double value,
    NumberFormat format, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            format.format(value),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
