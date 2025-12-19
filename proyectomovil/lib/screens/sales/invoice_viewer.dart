import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proyectomovil/models/order.dart';
import '../../services/api_service.dart';

class InvoiceViewerScreen extends StatelessWidget {
  final String id;
  const InvoiceViewerScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Factura")),
      body: FutureBuilder<Order>(
        future: ApiService().getOrderById(int.parse(id)),
        builder: (c, s) {
          if (!s.hasData)
            return const Center(child: CircularProgressIndicator());
          final o = s.data!;
          return PdfPreview(
            build: (fmt) {
              final doc = pw.Document();
              doc.addPage(
                pw.Page(
                  build: (pc) => pw.Column(
                    children: [
                      pw.Text(
                        "FACTURA #${o.orderId}",
                        style: pw.TextStyle(fontSize: 24),
                      ),
                      pw.Divider(),
                      pw.Text("Cliente: ${o.customerName}"),
                      pw.SizedBox(height: 20),
                      pw.TableHelper.fromTextArray(
                        data: [
                          ["Producto", "Cant", "Precio", "Total"],
                          ...o.details.map(
                            (d) => [
                              d.productName,
                              d.quantity,
                              d.unitPrice,
                              d.subtotal,
                            ],
                          ),
                        ],
                      ),
                      pw.Divider(),
                      pw.Text(
                        "TOTAL: \$${o.totalAmount}",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
              return doc.save();
            },
          );
        },
      ),
    );
  }
}
