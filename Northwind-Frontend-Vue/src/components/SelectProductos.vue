<template>
  <div class="full-screen-page">
    <div class="overlay">
      
      <div class="container-fluid py-5">
        <div class="row justify-content-center">
          <div class="col-12 col-xl-10">
            
            <div class="mb-4">
              <router-link to="/menuPrincipal" class="btn btn-light btn-sm modern-btn text-muted" style="padding: 0.5rem 1rem; font-size: 0.8rem;">
                <i class="fas fa-arrow-left me-2"></i>Volver
              </router-link>
            </div>

            <h2 class="text-center fw-bold mb-5 gradient-title">
              <i class="fas fa-boxes me-3"></i>Consulta de Productos
            </h2>

            <div class="card modern-card mb-4">
              <div class="card-body p-4">
                <div class="row g-3 align-items-center">
                  <div class="col-md-12">
                    <div class="form-floating position-relative">
                      <input
                        v-model="filtroBusqueda"
                        @input="busquedaDinamica"
                        type="text"
                        class="form-control modern-input ps-5"
                        id="buscador"
                        placeholder="Buscar..."
                      />
                      <label for="buscador" class="ps-5">Buscar por nombre...</label>
                      <span class="position-absolute top-50 start-0 translate-middle-y ms-3 text-muted">
                        <i v-if="buscando" class="fas fa-spinner fa-spin text-primary"></i>
                        <i v-else class="fas fa-search"></i>
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="card modern-card">
              <div class="card-header bg-gradient-info d-flex justify-content-between align-items-center">
                <h5 class="card-title text-white mb-0">
                  <i class="fas fa-list-alt me-2"></i>Inventario
                  <span class="badge bg-light text-dark ms-2">{{ paginacion.totalCount }}</span>
                </h5>
                <div class="d-flex align-items-center">
                  <span class="text-white me-2 small">Mostrar:</span>
                  <select 
                    v-model="paginacion.pageSize" 
                    @change="cambiarTamanoPagina" 
                    class="form-select form-select-sm modern-input py-1" 
                    style="width: auto; background-color: rgba(255,255,255,0.9);"
                  >
                    <option :value="5">5</option>
                    <option :value="10">10</option>
                    <option :value="20">20</option>
                  </select>
                </div>
              </div>
              
              <div class="card-body">
                <div class="table-responsive mb-4">
                  <table class="table modern-table">
                    <thead class="table-dark">
                      <tr>
                        <th>Foto</th>
                        <th>ID</th>
                        <th>Nombre</th>
                        <th>Precio</th>
                        <th>Stock</th>
                        <th>Valor Total</th>
                        <th class="text-center">Estado</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="loading">
                        <td colspan="6" class="text-center py-5">
                           <div class="spinner-border text-primary" role="status"></div>
                           <p class="mt-2 text-muted">Buscando productos...</p>
                        </td>
                      </tr>
                      
                      <tr v-else-if="productos.length === 0">
                        <td colspan="6" class="text-center py-4 text-muted">
                          No se encontraron productos.
                        </td>
                      </tr>

                      <tr v-else 
                          v-for="producto in productos" 
                          :key="producto.id" 
                          class="table-row"
                          :class="{
                             'row-out-of-stock': producto.unitsInStock === 0,
                             'row-low-stock': producto.unitsInStock > 0 && producto.isLowStock
                          }">
                         <td class="text-center">
  <img
    v-if="producto.profilePictureBase64"
    :src="`data:image/png;base64,${producto.profilePictureBase64}`"
    class="product-img"
    alt="Producto"
  />
  <i v-else class="fas fa-box text-muted fs-4"></i>
</td>

                        <td class="fw-bold">{{ producto.id }}</td>
                        <td><span class="user-info">{{ producto.name }}</span></td>
                        <td class="fw-bold text-primary">${{ producto.unitPrice ? producto.unitPrice.toFixed(2) : '0.00' }}</td>
                        <td class="fw-bold">{{ producto.unitsInStock }}</td>
                        <td class="text-muted">${{ producto.totalValue ? producto.totalValue.toFixed(2) : '0.00' }}</td>
                        <td class="text-center">
                          <span class="badge" 
                                :class="producto.unitsInStock === 0 ? 'bg-danger' : (producto.isLowStock ? 'bg-warning text-dark' : 'bg-success')">
                            {{ producto.unitsInStock === 0 ? 'Agotado' : (producto.isLowStock ? 'Bajo Stock' : 'Disponible') }}
                          </span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <div class="pagination-container" v-if="!loading && totalPaginas > 0">
                  
                  <button 
                    class="btn-nav" 
                    :disabled="paginacion.pageNumber === 1" 
                    @click="cambiarPagina(-1)"
                  >
                    <i class="fas fa-chevron-left me-2"></i> Anterior
                  </button>

                  <div class="page-info">
                    <span class="fw-bold text-dark">Página {{ paginacion.pageNumber }}</span>
                    <span class="text-muted small ms-1">de {{ totalPaginas }}</span>
                  </div>

                  <button 
                    class="btn-nav" 
                    :disabled="paginacion.pageNumber >= totalPaginas" 
                    @click="cambiarPagina(1)"
                  >
                    Siguiente <i class="fas fa-chevron-right ms-2"></i>
                  </button>

                </div>

              </div>
            </div>

          </div>
        </div>
      </div> 
    </div> 
  </div>

  <Teleport to="body">
    <div class="modal fade" ref="notifModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content modern-modal">
          <div class="modal-header bg-gradient-danger">
            <h5 class="modal-title text-white"><i class="fas fa-exclamation-triangle me-2"></i>Error</h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalNotif"></button>
          </div>
          <div class="modal-body text-center">
            <p class="fs-5">{{ modal.mensaje }}</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary modern-btn" @click="cerrarModalNotif">Cerrar</button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script>
import { Modal } from 'bootstrap';

export default {
  name: "SelectProductos",
  data() {
    return {
      productos: [],
      filtroBusqueda: "",
      paginacion: {
        pageNumber: 1,
        pageSize: 10,
        totalCount: 0,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false
      },
      loading: false,
      buscando: false,
      debounceTimeout: null,
      
      modal: {
        mensaje: "",
      },
      notifModalInstance: null,
    };
  },
  computed: {
    totalPaginas() {
      return this.paginacion.totalPages || Math.ceil(this.paginacion.totalCount / this.paginacion.pageSize) || 1;
    }
  },
  mounted() {
    this.cargarProductos();
    this.inicializarModales();
  },
  methods: {
    inicializarModales() {
      if (this.$refs.notifModal) this.notifModalInstance = new Modal(this.$refs.notifModal);
    },

    mostrarError(mensaje) {
      this.modal.mensaje = mensaje;
      this.notifModalInstance?.show();
    },
    cerrarModalNotif() {
      this.notifModalInstance?.hide();
    },
    // --- BÚSQUEDA DINÁMICA ---
    busquedaDinamica() {
      this.buscando = true;
      if (this.debounceTimeout) clearTimeout(this.debounceTimeout);
      this.debounceTimeout = setTimeout(() => {
        this.paginacion.pageNumber = 1;
        this.cargarProductos();
      }, 500);
    },

    // --- LISTAR ---
    async cargarProductos() {
      this.loading = true;
      try {
        const token = localStorage.getItem("token");
        const params = new URLSearchParams({
            PageNumber: this.paginacion.pageNumber,
            PageSize: this.paginacion.pageSize,
            OrderDescending: false
        });

        if (this.filtroBusqueda) params.append("SearchTerm", this.filtroBusqueda);

        const url = `https://localhost:7176/api/products?${params.toString()}`;
        const res = await fetch(url, {
          headers: { 'accept': 'application/json', 'Authorization': `Bearer ${token}` },
        });

        if (!res.ok) throw new Error("Error al obtener datos");

        const data = await res.json();
        
        this.productos = data.items; 
        this.paginacion.totalCount = data.totalCount;
        this.paginacion.totalPages = data.totalPages;
        this.paginacion.hasPreviousPage = data.hasPreviousPage;
        this.paginacion.hasNextPage = data.hasNextPage;

      } catch (error) {
        console.error(error);
        this.mostrarError("No se pudo cargar el inventario de productos.");
      } finally {
        this.loading = false;
        this.buscando = false;
      }
    },
    
    cambiarPagina(delta) {
        const nuevaPagina = this.paginacion.pageNumber + delta;
        if (nuevaPagina > 0 && nuevaPagina <= this.totalPaginas) {
            this.paginacion.pageNumber = nuevaPagina;
            this.cargarProductos();
        }
    },

    cambiarTamanoPagina() {
        this.paginacion.pageNumber = 1;
        this.cargarProductos();
    },
  }
};
</script>

<style scoped>
/* =========================================
   ESTILOS GENERALES
========================================= */

/* =========================================
   IMAGEN PRODUCTO
========================================= */
.product-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.product-img {
  width: 48px;
  height: 48px;
  object-fit: cover;
  border-radius: 10px;
  border: 1px solid #ddd;
  background-color: #f8f9fa;
}

.full-screen-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-image: url("https://img.freepik.com/vector-gratis/fondo-minimalista-gradiente_23-2149976755.jpg");
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  z-index: 1000;
}
.overlay {
  width: 100%;
  height: 100%;
  overflow-y: auto;
  background: rgba(245, 247, 250, 0.85);
  padding-bottom: 50px;
}
.container-fluid { background: transparent; min-height: auto; }

.gradient-title {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
.bg-gradient-info { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
.bg-gradient-danger { background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%); }

.modern-card {
  border: none; border-radius: 20px; background: #ffffff;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); overflow: hidden; transition: all 0.3s ease;
}
.modern-card .card-header { border: none; padding: 1.5rem; }
.modern-card .card-body { padding: 2rem; }

.modern-input {
  border-radius: 15px; border: 2px solid #e9ecef; transition: all 0.3s ease;
  padding: 0.75rem 1rem; background-color: #fff;
}
.modern-input:focus { border-color: #667eea; box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25); transform: translateY(-2px); }

/* =========================================
   ESTILOS DE TABLA
========================================= */
.modern-table { border-radius: 15px; overflow: hidden; border: none; background-color: white; }
.modern-table .table-dark { background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%); }
.user-info { font-weight: 600; color: #2c3e50; }

.table-row { transition: all 0.2s ease; }
.table-row:hover { background-color: rgba(102, 126, 234, 0.1); }

.row-out-of-stock {
    background-color: rgba(220, 53, 69, 0.15) !important;
    box-shadow: inset 0 0 0 1px rgba(220, 53, 69, 0.3);
}
.row-out-of-stock:hover { background-color: rgba(220, 53, 69, 0.25) !important; }

.row-low-stock { background-color: rgba(255, 193, 7, 0.15) !important; }
.row-low-stock:hover { background-color: rgba(255, 193, 7, 0.25) !important; }

/* =========================================
   NUEVA PAGINACIÓN (BOTONES GRANDES)
========================================= */
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  padding: 1rem;
  background-color: #f8f9fa;
  border-radius: 15px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}

.btn-nav {
  border: none;
  background: white;
  color: #555;
  font-weight: 600;
  padding: 0.6rem 1.2rem;
  border-radius: 50px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
}

.btn-nav:hover:not(:disabled) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.btn-nav:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background: #e9ecef;
}

.page-info {
  background: white;
  padding: 0.5rem 1.5rem;
  border-radius: 50px;
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.05);
  border: 1px solid #e9ecef;
}

/* Modales */
.modern-modal { border-radius: 20px; border: none; overflow: hidden; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3); background: white; }
.modern-modal .modal-header { border: none; padding: 1.5rem 2rem; }
.modern-modal .modal-body { padding: 2rem; }
.modern-modal .modal-footer { border: none; padding: 1.5rem 2rem; background-color: #f8f9fa; }
.badge { font-size: 0.75rem; padding: 0.5rem 1rem; border-radius: 50px; font-weight: 600; }
.overlay::-webkit-scrollbar { width: 8px; }
.overlay::-webkit-scrollbar-track { background: rgba(0,0,0,0.05); }
.overlay::-webkit-scrollbar-thumb { background: rgba(102, 126, 234, 0.5); border-radius: 10px; }
.overlay::-webkit-scrollbar-thumb:hover { background: rgba(102, 126, 234, 0.8); }
</style>