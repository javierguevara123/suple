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
              <i class="fas fa-address-book me-3"></i>Consulta de Clientes
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
                      <label for="buscador" class="ps-5">Buscar por nombre o ID...</label>
                      
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
                  <i class="fas fa-users me-2"></i>Cartera de Clientes
                  <span class="badge bg-light text-dark ms-2">{{ paginacion.totalRecords }}</span>
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
                        <th class="text-center">Foto</th>
                        <th>ID</th>
                        <th>Nombre / Compañía</th>
                        <th>Saldo Actual</th>
                        <th class="text-center">Estado</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="loading">
                        <td colspan="4" class="text-center py-5">
                           <div class="spinner-border text-primary" role="status"></div>
                           <p class="mt-2 text-muted">Buscando clientes...</p>
                        </td>
                      </tr>
                      
                      <tr v-else-if="clientes.length === 0">
                        <td colspan="4" class="text-center py-4 text-muted">
                          No se encontraron clientes con ese criterio.
                        </td>
                      </tr>
                      <tr v-else 
                          v-for="cliente in clientes" 
                          :key="cliente.id" 
                          class="table-row"
                      >
                      <td class="text-center">
  <img
    v-if="cliente.profilePictureBase64"
    :src="`data:image/png;base64,${cliente.profilePictureBase64}`"
    class="cliente-avatar"
  />
  <div v-else class="avatar-placeholder">
    <i class="fas fa-user"></i>
  </div>
</td>

                        <td class="fw-bold text-secondary">{{ cliente.id }}</td>
                        
                        <td>
                            <div class="d-flex flex-column">
                                <span class="user-info">{{ cliente.name }}</span>
                                </div>
                        </td>

                        <td class="fw-bold text-dark">
                            ${{ cliente.currentBalance ? cliente.currentBalance.toFixed(2) : '0.00' }}
                        </td>
                        
                        <td class="text-center">
                          <span class="badge" 
                                :class="cliente.currentBalance > 0 ? 'bg-success' : 'bg-secondary'">
                            {{ cliente.currentBalance > 0 ? 'Con Saldo' : 'Sin Deuda' }}
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
  name: "SelectClientes",
  data() {
    return {
      clientes: [],
      filtroBusqueda: "",
      paginacion: {
        pageNumber: 1,
        pageSize: 10,
        totalRecords: 0
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
      return Math.ceil(this.paginacion.totalRecords / this.paginacion.pageSize) || 1;
    }
  },
  mounted() {
    this.cargarClientes();
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
        this.cargarClientes();
      }, 500);
    },

    // --- API: LISTAR CLIENTES ---
    async cargarClientes() {
      this.loading = true;
      try {
        const token = localStorage.getItem("token");
        
        const params = new URLSearchParams({
            PageNumber: this.paginacion.pageNumber,
            PageSize: this.paginacion.pageSize,
            OrderDescending: false
        });

        if (this.filtroBusqueda) {
            params.append("SearchTerm", this.filtroBusqueda);
        }

        const url = `https://localhost:7176/api/customers?${params.toString()}`;
        
        const res = await fetch(url, {
          headers: { 
            'accept': 'application/json',
            'Authorization': `Bearer ${token}` 
          },
        });

        if (!res.ok) throw new Error("Error al obtener datos");

        const data = await res.json();
        
        // Mapeo según JSON de customers
        this.clientes = data.customers;
        this.paginacion.totalRecords = data.totalRecords;

      } catch (error) {
        console.error(error);
        this.mostrarError("No se pudo cargar la lista de clientes.");
      } finally {
        this.loading = false;
        this.buscando = false;
      }
    },
    
    cambiarPagina(delta) {
        const nuevaPagina = this.paginacion.pageNumber + delta;
        if (nuevaPagina > 0 && nuevaPagina <= this.totalPaginas) {
            this.paginacion.pageNumber = nuevaPagina;
            this.cargarClientes();
        }
    },

    cambiarTamanoPagina() {
        this.paginacion.pageNumber = 1;
        this.cargarClientes();
    },
  }
};
</script>

<style scoped>
/* =========================================
   ESTILOS MODERNOS (Consistentes)
========================================= */
.cliente-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  background: linear-gradient(135deg, #6b73ff, #8e9eff);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 18px;
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

/* Títulos y Cards */
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

/* Inputs */
.modern-input {
  border-radius: 15px; border: 2px solid #e9ecef; transition: all 0.3s ease;
  padding: 0.75rem 1rem; background-color: #fff;
}
.modern-input:focus { border-color: #667eea; box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25); transform: translateY(-2px); }

/* Tabla */
.modern-table { border-radius: 15px; overflow: hidden; border: none; background-color: white; }
.modern-table .table-dark { background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%); }
.table-row { transition: all 0.2s ease; }
.table-row:hover { background-color: rgba(102, 126, 234, 0.1); }
.user-info { font-weight: 600; color: #2c3e50; }

/* Paginación (Botones Grandes) */
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
.modern-btn { border-radius: 50px; padding: 0.5rem 1.5rem; }

.badge { font-size: 0.75rem; padding: 0.5rem 1rem; border-radius: 50px; font-weight: 600; }
.overlay::-webkit-scrollbar { width: 8px; }
.overlay::-webkit-scrollbar-track { background: rgba(0,0,0,0.05); }
.overlay::-webkit-scrollbar-thumb { background: rgba(102, 126, 234, 0.5); border-radius: 10px; }
.overlay::-webkit-scrollbar-thumb:hover { background: rgba(102, 126, 234, 0.8); }
</style>