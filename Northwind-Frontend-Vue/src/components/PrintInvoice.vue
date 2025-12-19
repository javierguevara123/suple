<template>
  <div class="full-screen-page">
    <div class="overlay">
      
      <div class="toolbar-container no-print">
        <div class="container-fluid d-flex justify-content-between align-items-center px-4 py-2">
          
          <button class="btn btn-light rounded-pill shadow-sm fw-bold" @click="$router.go(-1)">
            <i class="fas fa-arrow-left me-2"></i>Volver
          </button>
          
          <div class="d-flex gap-3">
            <button class="btn btn-outline-light rounded-pill fw-bold" @click="imprimirNativo" :disabled="!order">
              <i class="fas fa-print me-2"></i>Imprimir
            </button>
            <button class="btn btn-warning rounded-pill fw-bold shadow-sm text-dark" @click="generarPDF" :disabled="!order">
              <i class="fas fa-file-pdf me-2"></i>Descargar PDF
            </button>
          </div>
        </div>
      </div>

      <div class="preview-area">
        <div v-if="loading" class="text-center text-white mt-5">
            <div class="spinner-border text-light" role="status" style="width: 3rem; height: 3rem;"></div>
            <p class="mt-3 fs-5">Cargando factura...</p>
        </div>

        <div v-else-if="error" class="alert alert-danger m-5 shadow-lg text-center">
            {{ error }}
            <button class="btn btn-outline-danger mt-2 d-block mx-auto" @click="cargarOrden($route.params.id)">Reintentar</button>
        </div>

        <div v-else-if="order" id="element-to-print" class="invoice-paper shadow-lg">
            
            <!-- Header Section -->
            <header class="invoice-header">
                <div class="row align-items-start">
                    <!-- Left: Company Info -->
                    <div class="col-7">
                        <h1 class="invoice-title">FACTURA</h1>
                        <div class="company-info mt-3">
                            <p class="company-name mb-1">Raza Path Paella Inc.</p>
                            <p class="company-address mb-0">Circunvalación Nororte 36</p>
                            <p class="company-address mb-0">37001 Adila, Ávila</p>
                        </div>
                    </div>
                    
                    <!-- Right: Logo -->
                    <div class="col-5 text-end">
                        <div class="logo-placeholder">
                            <span class="logo-text">LOGO</span>
                        </div>
                    </div>
                </div>

                <!-- Invoice and Customer Details -->
                <div class="row mt-4">
                    <!-- Left: Shipping Info -->
                    <div class="col-6">
                        <div class="info-block">
                            <p class="info-label">ENVIAR A</p>
                            <p class="info-value fw-bold">{{ order.customerName }}</p>
                            <p class="info-value">{{ order.shipAddress }}</p>
                            <p class="info-value">{{ order.shipCity }}, {{ order.shipCountry }}</p>
                        </div>
                    </div>

                    <!-- Right: Invoice Details -->
                    <div class="col-6">
                        <div class="info-block text-end">
                            <p class="info-row"><span class="info-label">Nº DE FACTURA</span> <span class="info-value">{{ order.orderId }}</span></p>
                            <p class="info-row"><span class="info-label">FECHA</span> <span class="info-value">{{ formatearFecha(order.orderDate) }}</span></p>
                            <p class="info-row"><span class="info-label">Nº DE PEDIDO</span> <span class="info-value">{{ order.orderId }}</span></p>
                            <p class="info-row"><span class="info-label">FECHA VENCIMIENTO</span> <span class="info-value">{{ formatearFechaVencimiento(order.orderDate) }}</span></p>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Items Table -->
            <section class="items-section mt-4">
                <table class="invoice-table w-100">
                    <thead>
                        <tr>
                            <th class="text-start" style="width: 10%">CANT.</th>
                            <th class="text-start" style="width: 50%">DESCRIPCIÓN</th>
                            <th class="text-end" style="width: 20%">PRECIO UNITARIO</th>
                            <th class="text-end" style="width: 20%">IMPORTE</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="(item, index) in order.orderDetails" :key="index">
                            <td class="text-start">{{ item.quantity }}</td>
                            <td class="text-start">{{ item.productName }}</td>
                            <td class="text-end">${{ item.unitPrice.toFixed(2) }}</td>
                            <td class="text-end fw-bold">${{ item.subtotal.toFixed(2) }}</td>
                        </tr>
                    </tbody>
                </table>
            </section>

            <!-- Totals Section -->
            <section class="totals-section mt-4">
                <div class="row justify-content-end">
                    <div class="col-5">
                        <div class="totals-box">
                            <div class="total-row">
                                <span class="total-label">Subtotal</span>
                                <span class="total-value">${{ order.totalAmount.toFixed(2) }}</span>
                            </div>
                            <div class="total-row">
                                <span class="total-label">IVA 15.0%</span>
                                <span class="total-value">${{ calcularIVA(order.totalAmount).toFixed(2) }}</span>
                            </div>
                            <div class="total-row total-final">
                                <span class="total-label-final">TOTAL</span>
                                <span class="total-value-final">${{ calcularTotal(order.totalAmount).toFixed(2) }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Signature Section -->
            <section class="signature-section mt-5">
                <div class="signature-box">
                    <div class="signature-line"></div>
                    <p class="signature-name">Diana García</p>
                </div>
            </section>

            <!-- Footer Section -->
            <footer class="invoice-footer">
                <div class="footer-box">
                    <h3 class="footer-title">Gracias</h3>
                    <div class="footer-content">
                        <div class="footer-section">
                            <p class="footer-label">CONDICIONES Y FORMA DE PAGO</p>
                            <p class="footer-text">El pago se realizará en un plazo de 15 días</p>
                        </div>
                        <div class="footer-section">
                            <p class="footer-label">Banco: Santander / 334</p>
                            <p class="footer-text">IBAN: ES20 2100 3408 1402</p>
                        </div>
                    </div>
                </div>
            </footer>

        </div>
      </div>

    </div>
  </div>
</template>

<script>
import html2pdf from 'html2pdf.js';

const ApiBaseUrl = 'https://localhost:7176';

export default {
  name: 'PrintInvoice',
  data() {
    return {
      order: null,
      loading: true,
      error: null
    }
  },
  async mounted() {
    const orderId = this.$route.params.id;
    if (orderId) {
        await this.cargarOrden(orderId);
    } else {
        this.error = "No se especificó un número de orden.";
        this.loading = false;
    }
  },
  methods: {
    async cargarOrden(id) {
        this.loading = true;
        this.error = null;
        try {
            const token = localStorage.getItem("token");
            const res = await fetch(`${ApiBaseUrl}/GetOrderById/${id}`, {
                headers: { 'accept': 'application/json', 'Authorization': `Bearer ${token}` }
            });

            if (!res.ok) throw new Error("No se pudo encontrar la orden solicitada.");
            
            this.order = await res.json();

        } catch (e) {
            console.error(e);
            this.error = "Error al cargar la información de la factura.";
        } finally {
            this.loading = false;
        }
    },

    formatearFecha(fechaStr) {
        if(!fechaStr) return '---';
        return new Date(fechaStr).toLocaleDateString('es-ES', { 
            year: 'numeric', month: '2-digit', day: '2-digit'
        });
    },

    formatearFechaVencimiento(fechaStr) {
        if(!fechaStr) return '---';
        const fecha = new Date(fechaStr);
        fecha.setDate(fecha.getDate() + 15); // 15 días después
        return fecha.toLocaleDateString('es-ES', { 
            year: 'numeric', month: '2-digit', day: '2-digit'
        });
    },

    calcularIVA(subtotal) {
        // IVA = Subtotal * 0.15
        return subtotal * 0.15;
    },

    calcularTotal(subtotal) {
        // Total = Subtotal + IVA
        return subtotal + this.calcularIVA(subtotal);
    },

    generarPDF() {
        if (!this.order) return;
        const element = document.getElementById('element-to-print');
        const opt = {
          margin:       10,
          filename:     `Factura_${this.order.orderId}.pdf`,
          image:        { type: 'jpeg', quality: 0.98 },
          html2canvas:  { scale: 2, useCORS: true, scrollY: 0, backgroundColor: '#ffffff' },
          jsPDF:        { unit: 'mm', format: 'a4', orientation: 'portrait' }
        };
        html2pdf().set(opt).from(element).save();
    },

    imprimirNativo() {
        window.print();
    }
  }
}
</script>

<style scoped>
/* === VISTA EN PANTALLA === */
.full-screen-page {
  position: absolute; 
  top: 0; 
  left: 0; 
  width: 100%; 
  min-height: 100vh;
  background-color: #525659; 
  z-index: 2000;
  display: flex;
  flex-direction: column;
}

.overlay { 
  flex: 1;
  display: flex; 
  flex-direction: column; 
  width: 100%;
}

.toolbar-container {
  background: #323639; 
  position: sticky; 
  top: 0; 
  z-index: 3000; 
  box-shadow: 0 2px 10px rgba(0,0,0,0.3);
  padding: 10px 0;
}

.preview-area {
  flex: 1; 
  display: flex; 
  justify-content: center; 
  padding: 40px 20px;
  position: relative; 
  z-index: 1; 
}

/* === HOJA A4 === */
.invoice-paper {
  background: #f8f9fa;
  width: 210mm;
  min-height: 297mm;
  padding: 20mm;
  position: relative;
  font-family: 'Arial', 'Helvetica', sans-serif;
  color: #2c3e50;
  box-shadow: 0 0 25px rgba(0,0,0,0.5);
  margin-bottom: 40px;
}

/* === HEADER SECTION === */
.invoice-header {
  margin-bottom: 30px;
}

.invoice-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #2c3e50;
  letter-spacing: 2px;
  margin-bottom: 0;
}

.company-info {
  font-size: 0.9rem;
  line-height: 1.4;
}

.company-name {
  font-weight: 600;
  color: #2c3e50;
}

.company-address {
  color: #6c757d;
  font-size: 0.85rem;
}

.logo-placeholder {
  width: 80px;
  height: 80px;
  background: #c4c4c4;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-left: auto;
}

.logo-text {
  color: white;
  font-weight: 600;
  font-size: 0.9rem;
}

/* === INFO BLOCKS === */
.info-block {
  font-size: 0.85rem;
}

.info-label {
  color: #6c757d;
  font-size: 0.75rem;
  font-weight: 600;
  margin-bottom: 5px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-value {
  color: #2c3e50;
  margin-bottom: 3px;
  font-size: 0.85rem;
}

.info-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  gap: 20px;
}

.info-row .info-label {
  margin-bottom: 0;
  white-space: nowrap;
}

.info-row .info-value {
  text-align: right;
  margin-bottom: 0;
  font-weight: 600;
}

/* === ITEMS TABLE === */
.invoice-table {
  border-collapse: collapse;
  margin-top: 20px;
  font-size: 0.9rem;
}

.invoice-table thead tr {
  background: #2c3e50;
  color: white;
}

.invoice-table th {
  padding: 12px 10px;
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.5px;
}

.invoice-table tbody tr {
  border-bottom: 1px solid #dee2e6;
}

.invoice-table tbody tr:last-child {
  border-bottom: 2px solid #2c3e50;
}

.invoice-table td {
  padding: 12px 10px;
  color: #2c3e50;
}

/* === TOTALS SECTION === */
.totals-box {
  background: white;
  padding: 15px 20px;
  border-radius: 8px;
}

.total-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  font-size: 0.9rem;
}

.total-label {
  color: #6c757d;
  font-weight: 500;
}

.total-value {
  color: #2c3e50;
  font-weight: 600;
}

.total-final {
  border-top: 2px solid #2c3e50;
  margin-top: 10px;
  padding-top: 15px !important;
}

.total-label-final {
  color: #2c3e50;
  font-weight: 700;
  font-size: 1.1rem;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.total-value-final {
  color: #2c3e50;
  font-weight: 700;
  font-size: 1.3rem;
}

/* === SIGNATURE SECTION === */
.signature-section {
  text-align: center;
  margin-top: 60px;
  margin-bottom: 40px;
}

.signature-box {
  display: inline-block;
  min-width: 250px;
}

.signature-line {
  border-bottom: 2px solid #2c3e50;
  margin-bottom: 10px;
  height: 60px;
}

.signature-name {
  font-family: 'Brush Script MT', cursive, 'Dancing Script', cursive;
  font-size: 1.8rem;
  color: #2c3e50;
  margin: 0;
  font-weight: normal;
}

/* === FOOTER SECTION === */
.invoice-footer {
  margin-top: auto;
  padding-top: 30px;
}

.footer-box {
  border-left: 4px solid #e74c3c;
  padding-left: 20px;
  background: white;
  padding: 20px;
  border-radius: 8px;
}

.footer-title {
  font-family: 'Brush Script MT', cursive, 'Dancing Script', cursive;
  font-size: 2.5rem;
  color: #2c3e50;
  margin-bottom: 15px;
  font-weight: normal;
}

.footer-content {
  display: flex;
  gap: 30px;
  flex-wrap: wrap;
}

.footer-section {
  flex: 1;
  min-width: 200px;
}

.footer-label {
  color: #e74c3c;
  font-size: 0.75rem;
  font-weight: 600;
  margin-bottom: 5px;
  text-transform: uppercase;
}

.footer-text {
  color: #2c3e50;
  font-size: 0.85rem;
  margin-bottom: 2px;
  line-height: 1.4;
}

/* === OPTIMIZACIÓN DE IMPRESIÓN === */
@media print {
  .no-print, .toolbar-container { 
    display: none !important; 
  }
  
  .full-screen-page {
    position: static !important;
    background: none !important;
    width: 100% !important;
    height: auto !important;
    overflow: visible !important;
    z-index: auto !important;
    display: block !important;
  }

  .preview-area {
    padding: 0 !important;
    margin: 0 !important;
    display: block !important;
  }

  .invoice-paper {
    box-shadow: none !important;
    margin: 0 !important;
    width: 100% !important;
    max-width: 100% !important;
    min-height: auto !important; 
    height: auto !important;
    padding: 15mm !important;
    page-break-inside: avoid;
    background: white !important;
  }

  .invoice-header, 
  .items-section, 
  .totals-section, 
  .signature-section,
  .invoice-footer,
  .invoice-table tr {
    page-break-inside: avoid;
  }

  body {
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
  
  @page {
    margin: 10mm;
    size: A4;
  }

  /* Asegurar que los colores se impriman */
  .invoice-table thead tr,
  .total-final,
  .footer-box {
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
}

/* === RESPONSIVE === */
@media screen and (max-width: 768px) {
  .invoice-paper {
    width: 100%;
    padding: 15mm;
    margin-bottom: 20px;
  }

  .invoice-title {
    font-size: 2rem;
  }

  .footer-content {
    flex-direction: column;
  }
}
</style>