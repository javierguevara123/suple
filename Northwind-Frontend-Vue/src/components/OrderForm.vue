<template>
  <div class="full-screen-page">
    <div class="overlay">
      <div class="container-fluid py-4">
        
        <div class="row justify-content-center mb-4">
          <div class="col-xl-10">
            <div class="card modern-card mb-3 bg-white border-0 shadow-sm">
                <div class="card-body d-flex justify-content-between align-items-center p-4">
                    <div>
                        <h2 class="fw-bold text-primary mb-1">NorthWind</h2>
                        <p class="text-muted mb-0 small">Circunvalación Noreste 36, 37001 Ávila</p>
                        <p class="text-muted mb-0 small">Tel: (04) 2345-678 | Email: ventas@northwind.com</p>
                    </div>
                    <div class="text-end">
                        <div class="logo-box-header">
                            <span class="logo-text">LOGO</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center">
              <div>
                <router-link to="/menuPrincipal" class="btn btn-outline-light btn-sm rounded-pill mb-2">
                  <i class="fas fa-arrow-left me-2"></i>Volver al Menú
                </router-link>
                <h2 class="text-white fw-bold text-shadow mb-0">Nueva Venta</h2>
              </div>
              
              <div class="card bg-white border-0 shadow-sm px-4 py-2 rounded-3 text-end">
                <div class="text-muted small fw-bold text-uppercase">Fecha</div>
                <div class="fs-4 fw-bold text-primary">{{ fechaActual }}</div>
              </div>
            </div>
          </div>
        </div>

        <div class="row justify-content-center">
          <div class="col-xl-10">
            
            <div class="card modern-card mb-4">
              <div class="card-header bg-gradient-primary d-flex justify-content-between align-items-center">
                <h5 class="card-title text-white mb-0"><i class="fas fa-user me-2"></i>Cliente</h5>
                <button class="btn btn-sm btn-light text-primary fw-bold" @click="abrirModalClientes">
                  <i class="fas fa-search me-1"></i> Buscar / Cambiar
                </button>
              </div>
              <div class="card-body">
                <div v-if="cliente.id" class="row g-3 align-items-center">
                  <div class="col-md-5">
                    <label class="text-muted small fw-bold d-block">Nombre / Razón Social</label>
                    <span class="fs-5 fw-bold text-dark">{{ cliente.name }}</span>
                  </div>
                  <div class="col-md-3">
                    <label class="text-muted small fw-bold d-block">ID Cliente</label>
                    <span class="text-dark">{{ cliente.id }}</span>
                  </div>
                  <div class="col-md-4">
                    <label class="text-muted small fw-bold d-block">Estado de Cuenta</label>
                    <span class="badge bg-success fs-6">Saldo: ${{ cliente.currentBalance.toFixed(2) }}</span>
                  </div>
                </div>
                <div v-else class="text-center py-3 text-muted border border-dashed rounded bg-light">
                  <i class="fas fa-user-plus fs-4 mb-2 d-block text-primary"></i>
                  Seleccione un cliente para iniciar.
                </div>
              </div>
            </div>

            <div class="card modern-card">
              <div class="card-header bg-white border-bottom d-flex justify-content-between align-items-center py-3">
                <h5 class="mb-0 fw-bold text-dark">Detalle de Productos</h5>
                <button class="btn btn-success modern-btn shadow-sm" @click="abrirModalProductos" :disabled="!cliente.id">
                  <i class="fas fa-plus-circle me-2"></i>Agregar Producto
                </button>
              </div>

              <div class="card-body p-0">
                <div class="table-responsive">
                  <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light text-muted small text-uppercase">
                      <tr>
                        <th class="ps-4" style="width: 35%;">Producto</th>
                        <th class="text-center" style="width: 15%;">Precio</th>
                        <th class="text-center" style="width: 25%;">Cantidad</th>
                        <th class="text-end" style="width: 15%;">Subtotal</th>
                        <th class="text-center pe-4" style="width: 10%;">Acción</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="detalleFactura.length === 0">
                        <td colspan="5" class="text-center py-5 text-muted">
                          <div class="py-4">
                            <i class="fas fa-basket-shopping fs-1 mb-3 opacity-25"></i>
                            <p class="mb-0">No hay productos en la orden.</p>
                            <small v-if="!cliente.id">Seleccione un cliente para habilitar el catálogo.</small>
                          </div>
                        </td>
                      </tr>

                      <tr v-for="(item, index) in detalleFactura" :key="index">
                        <td class="ps-4">
                          <div class="fw-bold text-dark">{{ item.descripcion }}</div>
                          <small class="text-muted">ID: {{ item.productId }}</small>
                        </td>
                        <td class="text-center">${{ item.precioUnitario.toFixed(2) }}</td>
                        
                        <td class="text-center align-top pt-3">
                           <div class="d-flex flex-column align-items-center">
                               <div class="input-group input-group-sm" style="width: 140px;">
                                  <button 
                                    class="btn btn-outline-secondary" 
                                    type="button" 
                                    @click="actualizarCantidad(item, -1)"
                                    :disabled="item.cantidad <= 1"
                                  >
                                    <i class="fas fa-minus"></i>
                                  </button>
                                  
                                  <input 
                                    type="number" 
                                    class="form-control text-center fw-bold" 
                                    v-model.number="item.cantidad" 
                                    min="1" 
                                    :max="item.stockMax"
                                    @change="validarCantidadManual(item)"
                                  >
                                  
                                  <button 
                                    class="btn btn-outline-secondary" 
                                    type="button" 
                                    @click="actualizarCantidad(item, 1)"
                                    :disabled="item.cantidad >= item.stockMax"
                                  >
                                    <i class="fas fa-plus"></i>
                                  </button>
                               </div>

                               <div class="d-flex justify-content-between w-100 px-1 mt-1" style="font-size: 0.75rem; width: 140px !important;">
                                   <span class="text-muted">Min: 1</span>
                                   <span :class="item.cantidad >= item.stockMax ? 'text-danger fw-bold' : 'text-success fw-bold'">
                                     Max: {{ item.stockMax }}
                                   </span>
                               </div>
                           </div>
                        </td>

                        <td class="text-end fw-bold text-dark">
                            ${{ (item.cantidad * item.precioUnitario).toFixed(2) }}
                        </td>
                        
                        <td class="text-center pe-4">
                          <button 
                            class="btn btn-sm btn-outline-danger shadow-sm" 
                            @click="eliminarProducto(index)" 
                            title="Quitar producto de la lista"
                            style="border-radius: 8px; padding: 0.4rem 0.8rem;"
                          >
                            <i class="fas fa-trash-alt"></i>
                          </button>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>

              <div class="card-footer bg-light p-4 border-top">
                <div class="row justify-content-end">
                  <div class="col-md-5">
                    <!-- Totals Box Similar to Invoice -->
                    <div class="totals-summary bg-white p-3 rounded shadow-sm">
                      <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted fw-bold">Subtotal:</span>
                        <span class="fw-bold text-dark">${{ subtotal.toFixed(2) }}</span>
                      </div>
                      <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted fw-bold">IVA (15%):</span>
                        <span class="fw-bold text-dark">${{ iva.toFixed(2) }}</span>
                      </div>
                      <div class="d-flex justify-content-between py-3 mt-2">
                        <span class="fs-4 fw-bold text-dark">TOTAL:</span>
                        <span class="fs-3 fw-bold text-success">${{ totalPagar.toFixed(2) }}</span>
                      </div>
                    </div>
                    
                    <button 
                        class="btn btn-primary w-100 py-3 fw-bold shadow-sm modern-btn mt-3" 
                        @click="guardarFactura" 
                        :disabled="saving || detalleFactura.length === 0 || !cliente.id"
                    >
                        <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
                        <i v-else class="fas fa-save me-2"></i>
                        Finalizar y Guardar
                    </button>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>
    </div>
  </div>

  <Teleport to="body">
    
    <div class="modal fade" ref="modalClientes" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
      <div class="modal-dialog modal-lg">
        <div class="modal-content modern-modal">
          <div class="modal-header bg-primary text-white">
            <h5 class="modal-title"><i class="fas fa-users me-2"></i>Seleccionar Cliente</h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalClientes"></button>
          </div>
          <div class="modal-body">
            <div class="input-group mb-3">
                <span class="input-group-text bg-white"><i class="fas fa-search text-muted"></i></span>
                <input type="text" v-model="clienteSearch" @input="buscarClientesAPI(true)" class="form-control modern-input border-start-0" placeholder="Buscar por nombre o ID..." autofocus />
            </div>
            <div v-if="loadingSearch" class="text-center py-3"><div class="spinner-border text-primary spinner-border-sm"></div><span class="ms-2">Buscando...</span></div>
            <div v-else class="list-group">
                <button v-for="c in clientesEncontrados" :key="c.id" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" @click="seleccionarCliente(c)">
                    <div><div class="fw-bold">{{ c.name }}</div><small class="text-muted">ID: {{ c.id }} | Saldo: ${{ c.currentBalance }}</small></div>
                    <i class="fas fa-chevron-right text-muted"></i>
                </button>
                <div v-if="clientesEncontrados.length === 0" class="text-center p-3 text-muted">No se encontraron clientes.</div>
            </div>
          </div>
          <div class="modal-footer bg-light justify-content-between">
             <button class="btn btn-sm btn-outline-secondary" :disabled="paginacionClientes.pageNumber===1" @click="cambiarPaginaClientes(-1)">Anterior</button>
             <span class="small text-muted">Pág. {{ paginacionClientes.pageNumber }} de {{ paginacionClientes.totalPages }}</span>
             <button class="btn btn-sm btn-outline-secondary" :disabled="paginacionClientes.pageNumber>=paginacionClientes.totalPages" @click="cambiarPaginaClientes(1)">Siguiente</button>
          </div>
        </div>
      </div>
    </div>

    <div class="modal fade" ref="modalProductos" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
      <div class="modal-dialog modal-lg">
        <div class="modal-content modern-modal">
          <div class="modal-header bg-success text-white">
            <h5 class="modal-title"><i class="fas fa-box me-2"></i>Seleccionar Producto</h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalProductos"></button>
          </div>
          <div class="modal-body">
            <div class="input-group mb-3">
                <span class="input-group-text bg-white"><i class="fas fa-search text-muted"></i></span>
                <input type="text" v-model="productoSearch" @input="buscarProductosAPI(true)" class="form-control modern-input border-start-0" placeholder="Buscar producto..." autofocus />
            </div>
            <div v-if="loadingSearch" class="text-center py-3"><div class="spinner-border text-success spinner-border-sm"></div><span class="ms-2">Buscando...</span></div>
            <div v-else class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr><th>Producto</th><th class="text-end">Precio</th><th class="text-center">Stock Real</th><th class="text-end">Acción</th></tr>
                    </thead>
                    <tbody>
                        <tr v-for="p in productosEncontrados" :key="p.id" :class="{ 'table-active opacity-50': p.enCarrito || p.stockCalculado === 0 }">
                            <td><div class="fw-bold">{{ p.name }}</div><small class="text-muted">ID: {{ p.id }}</small></td>
                            <td class="text-end">${{ p.unitPrice.toFixed(2) }}</td>
                            <td class="text-center"><span :class="p.stockCalculado < 5 ? 'text-danger fw-bold' : 'text-success'">{{ p.stockCalculado }}</span></td>
                            <td class="text-end">
                                <button v-if="p.enCarrito" class="btn btn-sm btn-secondary" disabled><i class="fas fa-check me-1"></i> En Orden</button>
                                <button v-else-if="p.stockCalculado === 0" class="btn btn-sm btn-light border text-muted" disabled>Agotado</button>
                                <button v-else class="btn btn-sm btn-outline-success fw-bold" @click="agregarDirecto(p)"><i class="fas fa-plus me-1"></i> Agregar</button>
                            </td>
                        </tr>
                        <tr v-if="productosEncontrados.length === 0"><td colspan="4" class="text-center text-muted py-4">No se encontraron productos.</td></tr>
                    </tbody>
                </table>
            </div>
          </div>
          <div class="modal-footer bg-light justify-content-between">
             <button class="btn btn-sm btn-outline-secondary" :disabled="paginacionProductos.pageNumber===1" @click="cambiarPaginaProductos(-1)">Anterior</button>
             <span class="small text-muted">Pág. {{ paginacionProductos.pageNumber }} de {{ paginacionProductos.totalPages }}</span>
             <button class="btn btn-sm btn-outline-secondary" :disabled="paginacionProductos.pageNumber>=paginacionProductos.totalPages" @click="cambiarPaginaProductos(1)">Siguiente</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script>
import { Modal } from 'bootstrap';
const ApiBaseUrl = 'https://localhost:7176';

export default {
  name: 'OrderFormComponent',
  data() {
    return {
      numeroFactura: '',
      fechaFactura: '',
      cliente: { id: null, name: '', currentBalance: 0 },
      clienteSearch: '',
      clientesEncontrados: [],
      paginacionClientes: { pageNumber: 1, pageSize: 5, totalPages: 1 },
      productoSearch: '',
      productosEncontrados: [],
      paginacionProductos: { pageNumber: 1, pageSize: 5, totalPages: 1 },
      detalleFactura: [],
      loading: false,
      loadingSearch: false, 
      saving: false,
      debounceTimeout: null,
      modalClientesInstance: null,
      modalProductosInstance: null,
    }
  },
  computed: {
    subtotal() { 
      return this.detalleFactura.reduce((sum, item) => sum + (item.cantidad * item.precioUnitario), 0); 
    },
    iva() {
      // IVA del 15% sobre el subtotal
      return this.subtotal * 0.15;
    },
    totalPagar() { 
      // Total = Subtotal + IVA
      return this.subtotal + this.iva; 
    },
    fechaActual() { 
      return this.fechaFactura || new Date().toLocaleDateString('es-ES'); 
    }
  },
  mounted() {
    if (this.$refs.modalClientes) this.modalClientesInstance = new Modal(this.$refs.modalClientes);
    if (this.$refs.modalProductos) this.modalProductosInstance = new Modal(this.$refs.modalProductos);
  },
  methods: {
    // --- CLIENTES ---
    abrirModalClientes() { this.clienteSearch = ''; this.buscarClientesAPI(true); this.modalClientesInstance?.show(); },
    buscarClientesAPI(resetPage = false) {
        if (resetPage) this.paginacionClientes.pageNumber = 1;
        this.loadingSearch = true;
        if (this.debounceTimeout) clearTimeout(this.debounceTimeout);
        this.debounceTimeout = setTimeout(async () => {
            try {
                const token = localStorage.getItem("token");
                const params = new URLSearchParams({ PageNumber: this.paginacionClientes.pageNumber, PageSize: this.paginacionClientes.pageSize, OrderDescending: false });
                if(this.clienteSearch) params.append("SearchTerm", this.clienteSearch);
                const res = await fetch(`${ApiBaseUrl}/api/customers?${params}`, { headers: { 'Authorization': `Bearer ${token}` } });
                const data = await res.json();
                this.clientesEncontrados = data.customers || [];
                this.paginacionClientes.totalPages = Math.ceil(data.totalRecords / this.paginacionClientes.pageSize) || 1;
            } catch (e) { console.error(e); } finally { this.loadingSearch = false; }
        }, 300);
    },
    cambiarPaginaClientes(delta) {
        const nueva = this.paginacionClientes.pageNumber + delta;
        if(nueva > 0 && nueva <= this.paginacionClientes.totalPages) { this.paginacionClientes.pageNumber = nueva; this.buscarClientesAPI(false); }
    },
    seleccionarCliente(c) {
        this.cliente = { id: c.id, name: c.name, cedula: c.id, currentBalance: c.currentBalance };
        this.modalClientesInstance?.hide();
    },
    cerrarModalClientes() { this.modalClientesInstance?.hide(); },

    // --- PRODUCTOS ---
    abrirModalProductos() { this.productoSearch = ''; this.buscarProductosAPI(true); this.modalProductosInstance?.show(); },
    buscarProductosAPI(resetPage = false) {
        if (resetPage) this.paginacionProductos.pageNumber = 1;
        this.loadingSearch = true;
        if (this.debounceTimeout) clearTimeout(this.debounceTimeout);
        this.debounceTimeout = setTimeout(async () => {
            try {
                const token = localStorage.getItem("token");
                const params = new URLSearchParams({ PageNumber: this.paginacionProductos.pageNumber, PageSize: this.paginacionProductos.pageSize, OrderDescending: false });
                if(this.productoSearch) params.append("SearchTerm", this.productoSearch);
                const res = await fetch(`${ApiBaseUrl}/api/products?${params}`, { headers: { 'Authorization': `Bearer ${token}` } });
                const data = await res.json();
                this.paginacionProductos.totalPages = data.totalPages || 1;
                this.productosEncontrados = (data.items || []).map(p => {
                    const enCarrito = this.detalleFactura.find(d => d.productId === p.id);
                    const cantidadEnCarrito = enCarrito ? enCarrito.cantidad : 0;
                    return { ...p, stockCalculado: p.unitsInStock - cantidadEnCarrito, enCarrito: !!enCarrito };
                });
            } catch (e) { console.error(e); } finally { this.loadingSearch = false; }
        }, 300);
    },
    cambiarPaginaProductos(delta) {
        const nueva = this.paginacionProductos.pageNumber + delta;
        if(nueva > 0 && nueva <= this.paginacionProductos.totalPages) { this.paginacionProductos.pageNumber = nueva; this.buscarProductosAPI(false); }
    },
    cerrarModalProductos() { this.modalProductosInstance?.hide(); },

    // --- CARRITO ---
    agregarDirecto(p) {
        if (p.stockCalculado <= 0) return;
        this.detalleFactura.push({
            productId: p.id, descripcion: p.name, precioUnitario: p.unitPrice,
            cantidad: 1, stockMax: p.unitsInStock 
        });
        p.enCarrito = true; p.stockCalculado--; 
    },
    actualizarCantidad(item, delta) {
        const nuevaCantidad = item.cantidad + delta;
        if (nuevaCantidad < 1) return;
        if (nuevaCantidad > item.stockMax) return;
        item.cantidad = nuevaCantidad;
    },
    
    validarCantidadManual(item) {
        let val = parseInt(item.cantidad);
        if (isNaN(val) || val < 1) {
            item.cantidad = 1;
        } else if (val > item.stockMax) {
            item.cantidad = item.stockMax;
        } else {
            item.cantidad = val;
        }
    },
    
    // Método para eliminar el producto del carrito
    eliminarProducto(index) { 
        this.detalleFactura.splice(index, 1); 
    },

    // --- GUARDAR ---
    async guardarFactura() {
        if (!this.cliente.id || this.detalleFactura.length === 0) return;
        this.saving = true;
        try {
            const token = localStorage.getItem("token");
            const payload = {
                customerId: this.cliente.id,
                shipAddress: "Dirección Principal", shipCity: "Quito", shipCountry: "Ecuador", shipPostalCode: "170101",
                orderDetails: this.detalleFactura.map(d => ({ productId: d.productId, unitPrice: d.precioUnitario, quantity: d.cantidad }))
            };
            const res = await fetch(`${ApiBaseUrl}/CreateOrder`, {
                method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
                body: JSON.stringify(payload)
            });
            if (!res.ok) {
                const err = await res.json();
                let msg = err.message || err.detail || "Error al crear la orden";
                if(err.errors) { if(Array.isArray(err.errors)) msg = err.errors.map(e => e.errorMessage).join('\n'); }
                throw new Error(msg);
            }
            const data = await res.json();
            
            this.$router.push({ name: 'PrintInvoice', params: { id: data.id } });

        } catch (e) { alert("Error: " + e.message); } finally { this.saving = false; }
    }
  }
}
</script>

<style scoped>
/* ESTILOS MODERNOS */
.full-screen-page { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background-image: url("https://img.freepik.com/vector-gratis/fondo-minimalista-gradiente_23-2149976755.jpg"); background-size: cover; z-index: 1000; }
.overlay { width: 100%; height: 100%; overflow-y: auto; background: rgba(245, 247, 250, 0.85); padding-bottom: 50px; }
.text-shadow { text-shadow: 0 2px 4px rgba(0,0,0,0.1); }
.modern-card { border: none; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); overflow: hidden; background: white; }
.bg-gradient-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
.modern-input { border-radius: 10px; border: 2px solid #eee; }
.modern-input:focus { border-color: #667eea; box-shadow: none; }
.modern-modal { border-radius: 20px; overflow: hidden; }
.overlay::-webkit-scrollbar { width: 8px; }
.overlay::-webkit-scrollbar-track { background: rgba(0,0,0,0.05); }
.overlay::-webkit-scrollbar-thumb { background: rgba(102, 126, 234, 0.5); border-radius: 10px; }

/* Logo Box in Header */
.logo-box-header {
  width: 80px;
  height: 80px;
  background: #c4c4c4;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-text {
  color: white;
  font-weight: 600;
  font-size: 0.9rem;
}

/* Totals Summary Box */
.totals-summary {
  border: 2px solid #e9ecef;
}

.totals-summary .border-bottom {
  border-color: #e9ecef !important;
}
</style>