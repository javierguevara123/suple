<template>
  <div class="full-screen-page">
    <div class="overlay">
      <div class="container-fluid py-5">
        <div class="row justify-content-center">
          <div class="col-12 col-xl-10">
            <div class="mb-4">
              <router-link
                to="/menuAdmin"
                class="btn btn-light btn-sm modern-btn text-muted"
                style="padding: 0.5rem 1rem; font-size: 0.8rem"
              >
                <i class="fas fa-arrow-left me-2"></i>Volver
              </router-link>
            </div>

            <h2 class="text-center fw-bold mb-5 gradient-title">
              <i class="fas fa-history me-3"></i>Auditoría de Logs
            </h2>

            <div class="card modern-card mb-4">
              <div class="card-body p-4">
                <div class="row g-3 align-items-center">
                  <div class="col-md-12">
                    <div
                      class="d-flex justify-content-between align-items-center"
                    >
                              <div class="text-muted small">
                                <i class="fas fa-info-circle me-1"></i>
                                Mostrando registros de actividad del dominio.
                              </div>
                              <div class="d-flex align-items-center">
                                <div class="me-2">
                                  <input
                                    v-model="filterText"
                                    @input="onFilterChange"
                                    type="search"
                                    class="form-control form-control-sm modern-input"
                                    placeholder="Buscar por información o usuario"
                                    style="width: 260px"
                                  />
                                </div>
                                <div class="me-2">
                                  <input
                                    v-model="filterDate"
                                    @change="onFilterChange"
                                    type="date"
                                    class="form-control form-control-sm modern-input"
                                    title="Filtrar por fecha (fecha del registro)"
                                  />
                                </div>
                                <button
                                  class="btn btn-light btn-sm me-2"
                                  @click="clearFilters"
                                  v-if="isFiltering"
                                  title="Limpiar filtros"
                                >
                                  <i class="fas fa-times me-1"></i> Limpiar
                                </button>
                                <button
                                  class="btn btn-primary modern-btn btn-sm"
                                  @click="cargarLogs"
                                >
                                  <i class="fas fa-sync-alt me-1"></i> Actualizar
                                </button>
                              </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="card modern-card">
              <div
                class="card-header bg-gradient-info d-flex justify-content-between align-items-center"
              >
                <h5 class="card-title text-white mb-0">
                  <i class="fas fa-list-ul me-2"></i>Registros
                  <span class="badge bg-light text-dark ms-2">{{
                    paginacion.totalCount
                  }}</span>
                </h5>
                <div class="d-flex align-items-center">
                  <span class="text-white me-2 small">Mostrar:</span>
                  <select
                    v-model="paginacion.pageSize"
                    @change="cambiarTamanoPagina"
                    class="form-select form-select-sm modern-input py-1"
                    style="
                      width: auto;
                      background-color: rgba(255, 255, 255, 0.9);
                    "
                  >
                    <option :value="10">10</option>
                    <option :value="20">20</option>
                    <option :value="50">50</option>
                  </select>
                </div>
              </div>

              <div class="card-body">
                <div class="table-responsive">
                  <table class="table table-hover modern-table">
                    <thead class="table-dark">
                      <tr>
                        <th>ID</th>
                        <th>Información</th>
                        <th>Usuario</th>
                        <th>Fecha</th>
                        <th class="text-center">Detalle</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="loading">
                        <td colspan="5" class="text-center py-5">
                          <div
                            class="spinner-border text-primary"
                            role="status"
                          ></div>
                          <p class="mt-2 text-muted">Cargando logs...</p>
                        </td>
                      </tr>

                      <tr v-else-if="logs.length === 0">
                        <td colspan="5" class="text-center py-4 text-muted">
                          No se encontraron registros.
                        </td>
                      </tr>

                      <tr
                        v-else
                        v-for="log in displayLogs"
                        :key="log.id"
                        class="table-row"
                      >
                        <td class="fw-bold text-primary">#{{ log.id }}</td>
                        <td>
                          <span class="fw-bold d-block">{{
                            log.information
                          }}</span>
                        </td>
                        <td>
                          <div class="d-flex align-items-center">
                            <div class="avatar-mini me-2">
                              {{ obtenerInicial(log.user) }}
                            </div>
                            <span class="text-muted small">{{ log.user }}</span>
                          </div>
                        </td>
                        <td>{{ formatearFecha(log.dateTime) }}</td>
                        <td class="text-center">
                          <button
                            class="btn-action btn-view"
                            @click="verDetalle(log)"
                            title="Ver detalle completo"
                          >
                            <i class="fas fa-eye"></i>
                          </button>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <div
                  class="d-flex flex-column flex-md-row justify-content-between align-items-center mt-4"
                  v-if="!isFiltering && totalPaginas > 0 && !loading"
                >
                  <div class="text-muted small mb-2 mb-md-0">
                    Página <strong>{{ paginacion.pageNumber }}</strong> de
                    <strong>{{ totalPaginas }}</strong>
                  </div>
                  <nav aria-label="Navegación">
                    <ul class="pagination pagination-modern mb-0">
                      <li
                        class="page-item"
                        :class="{ disabled: paginacion.pageNumber === 1 }"
                      >
                        <button class="page-link" @click="irAPagina(1)">
                          <i class="fas fa-angle-double-left"></i>
                        </button>
                      </li>
                      <li
                        class="page-item"
                        :class="{ disabled: paginacion.pageNumber === 1 }"
                      >
                        <button class="page-link" @click="cambiarPagina(-1)">
                          <i class="fas fa-chevron-left"></i>
                        </button>
                      </li>
                      <li
                        v-for="pagina in paginasVisibles"
                        :key="pagina"
                        class="page-item"
                        :class="{ active: pagina === paginacion.pageNumber }"
                      >
                        <button class="page-link" @click="irAPagina(pagina)">
                          {{ pagina }}
                        </button>
                      </li>
                      <li
                        class="page-item"
                        :class="{
                          disabled: paginacion.pageNumber >= totalPaginas,
                        }"
                      >
                        <button class="page-link" @click="cambiarPagina(1)">
                          <i class="fas fa-chevron-right"></i>
                        </button>
                      </li>
                      <li
                        class="page-item"
                        :class="{
                          disabled: paginacion.pageNumber === totalPaginas,
                        }"
                      >
                        <button
                          class="page-link"
                          @click="irAPagina(totalPaginas)"
                        >
                          <i class="fas fa-angle-double-right"></i>
                        </button>
                      </li>
                    </ul>
                  </nav>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <Teleport to="body">
    <div class="modal fade" ref="detalleModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content modern-modal">
          <div class="modal-header bg-gradient-info text-white">
            <h5 class="modal-title">
              <i class="fas fa-info-circle me-2"></i>Detalle del Log #{{
                logSeleccionado?.id
              }}
            </h5>
            <button
              type="button"
              class="btn-close btn-close-white"
              @click="cerrarModal"
            ></button>
          </div>
          <div class="modal-body p-4" v-if="logSeleccionado">
            <div class="mb-4 text-center">
              <div class="avatar-large mx-auto mb-2">
                {{ obtenerInicial(logSeleccionado.user) }}
              </div>
              <h5 class="mb-0">{{ logSeleccionado.user }}</h5>
              <small class="text-muted">{{
                formatearFecha(logSeleccionado.dateTime)
              }}</small>
            </div>

            <div class="card bg-light border-0">
              <div class="card-body">
                <h6 class="fw-bold text-primary mb-3">
                  Información del Evento
                </h6>
                <p class="lead fs-6">{{ logSeleccionado.information }}</p>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary modern-btn"
              @click="cerrarModal"
            >
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script>
import { Modal } from "bootstrap";

export default {
  name: "ReporteErrores",
  data() {
    return {
      logs: [],
      loading: false,

      paginacion: {
        pageNumber: 1,
        pageSize: 10,
        totalCount: 0,
      },

      // filtros de búsqueda
      filterText: "",
      filterDate: "",

      logSeleccionado: null,
      detalleModalInstance: null,
    };
  },

  computed: {
    // devuelve true si hay algún filtro activo
    isFiltering() {
      return (
        (this.filterText && this.filterText.toString().trim().length > 0) ||
        (this.filterDate && this.filterDate.toString().trim().length > 0)
      );
    },

    // logs filtrados localmente (busca en information y user y filtra por fecha)
    filteredLogs() {
      if (!this.logs || this.logs.length === 0) return [];
      const text = this.filterText ? this.filterText.toLowerCase().trim() : "";
      const dateFilter = this.filterDate ? this.filterDate : "";

      return this.logs.filter((l) => {
        let matchesText = true;
        let matchesDate = true;

        if (text) {
          const info = (l.information || "").toString().toLowerCase();
          const user = (l.user || "").toString().toLowerCase();
          matchesText = info.includes(text) || user.includes(text);
        }

        if (dateFilter) {
          // comparar solo la parte de fecha (YYYY-MM-DD)
          const dt = l.dateTime ? new Date(l.dateTime) : null;
          if (!dt || isNaN(dt.getTime())) matchesDate = false;
          else {
            const y = dt.getFullYear();
            const m = String(dt.getMonth() + 1).padStart(2, "0");
            const d = String(dt.getDate()).padStart(2, "0");
            const isoDate = `${y}-${m}-${d}`;
            matchesDate = isoDate === dateFilter;
          }
        }

        return matchesText && matchesDate;
      });
    },

    // logs a mostrar en la tabla (usa filtrado si aplica)
    displayLogs() {
      return this.isFiltering ? this.filteredLogs : this.logs;
    },

    totalPaginas() {
      if (this.paginacion.totalCount && this.paginacion.pageSize) {
        return Math.ceil(this.paginacion.totalCount / this.paginacion.pageSize);
      }
      return 1;
    },
    paginasVisibles() {
      const range = 2;
      const current = this.paginacion.pageNumber;
      const total = this.totalPaginas;
      let start = Math.max(1, current - range);
      let end = Math.min(total, current + range);
      if (end - start + 1 < 5 && total >= 5) {
        if (start === 1) end = 5;
        else if (end === total) start = total - 4;
      }
      const pages = [];
      for (let i = start; i <= end; i++) pages.push(i);
      return pages;
    },
  },

  mounted() {
    this.cargarLogs();
    this.inicializarModal();
  },

  methods: {
    inicializarModal() {
      if (this.$refs.detalleModal) {
        this.detalleModalInstance = new Modal(this.$refs.detalleModal);
      }
    },

    formatearFecha(fechaStr) {
      if (!fechaStr) return "-";
      const date = new Date(fechaStr);
      return date.toLocaleString("es-ES", {
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
      });
    },

    obtenerInicial(email) {
      return email ? email.charAt(0).toUpperCase() : "?";
    },

    // --- CONSUMO DE API ---
    async cargarLogs() {
      this.loading = true;
      try {
        const token = localStorage.getItem("token");
        // Parámetros según tu endpoint (page, take)
        const params = new URLSearchParams({
          page: this.paginacion.pageNumber,
          take: this.paginacion.pageSize,
        });

        const url = `https://localhost:7176/api/Logs/domain?${params.toString()}`;

        const res = await fetch(url, {
          headers: {
            accept: "text/plain", // Tu curl dice text/plain, aunque responde JSON
            Authorization: `Bearer ${token}`,
          },
        });

        if (!res.ok) throw new Error("Error al obtener logs");

        const data = await res.json();

        // Mapeo de respuesta según tu ejemplo
        this.logs = data.items;
        this.paginacion.totalCount = data.totalCount;
        // Si el backend devuelve pageNumber/pageSize, sincronizamos (opcional)
        // this.paginacion.pageNumber = data.pageNumber;
      } catch (error) {
        console.error("Error cargando logs:", error);
      } finally {
        this.loading = false;
      }
    },

    // --- PAGINACIÓN ---
    irAPagina(n) {
      if (n === this.paginacion.pageNumber) return;
      this.paginacion.pageNumber = n;
      this.cargarLogs();
    },
    cambiarPagina(delta) {
      const nuevaPagina = this.paginacion.pageNumber + delta;
      if (nuevaPagina > 0 && nuevaPagina <= this.totalPaginas) {
        this.paginacion.pageNumber = nuevaPagina;
        this.cargarLogs();
      }
    },
    cambiarTamanoPagina() {
      this.paginacion.pageNumber = 1;
      this.cargarLogs();
    },

    // --- DETALLE ---
    verDetalle(log) {
      this.logSeleccionado = log;
      this.detalleModalInstance?.show();
    },
    cerrarModal() {
      this.detalleModalInstance?.hide();
    },
    // --- FILTRADO ---
    onFilterChange() {
      // Actualmente aplicamos el filtrado en el cliente sobre los logs cargados.
      // Si se desea filtrado en servidor, aquí habría que llamar al endpoint con parámetros.
      // Reiniciamos la paginación visible (si se quiere mostrar desde página 1)
      // pero no hacemos re-fetch para no perder contexto del backend paginado.
      // Para pequeña cantidad de datos esto funciona bien.
      // (Dejar vacío o throttle si necesario.)
    },
    clearFilters() {
      this.filterText = "";
      this.filterDate = "";
    },
  },
};
</script>

<style scoped>
/* Estilos Base (Full Screen) */
.full-screen-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-image: url("https://img.freepik.com/vector-gratis/fondo-minimalista-gradiente_23-2149976755.jpg");
  background-size: cover;
  background-position: center;
  z-index: 1000;
}
.overlay {
  width: 100%;
  height: 100%;
  overflow-y: auto;
  background: rgba(245, 247, 250, 0.85);
  padding-bottom: 50px;
}
.container-fluid {
  background: transparent;
  min-height: auto;
}

.gradient-title {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.bg-gradient-info {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.modern-card {
  border: none;
  border-radius: 20px;
  background: #ffffff;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}
.modern-card .card-header {
  border: none;
  padding: 1.5rem;
}
.modern-card .card-body {
  padding: 2rem;
}

.modern-btn {
  border-radius: 50px;
  padding: 0.5rem 1.5rem;
}
.modern-table {
  border-radius: 15px;
  overflow: hidden;
  border: none;
  background-color: white;
}
.modern-table .table-dark {
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
}
.table-row:hover {
  background-color: rgba(102, 126, 234, 0.1);
}

.btn-action {
  border: none;
  border-radius: 6px;
  padding: 6px 12px;
  font-weight: 600;
  transition: all 0.2s ease;
}
.btn-view {
  background-color: #3b82f6;
  color: white;
}
.btn-view:hover {
  background-color: #2563eb;
  transform: translateY(-1px);
}

/* Avatar Mini para la tabla */
.avatar-mini {
  width: 30px;
  height: 30px;
  background-color: #667eea;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 0.8rem;
}

/* Avatar Large para el modal */
.avatar-large {
  width: 60px;
  height: 60px;
  background-color: #764ba2;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 1.5rem;
}

.pagination-modern .page-item .page-link {
  border: none;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 4px;
  color: #2c3e50;
  font-weight: 600;
  background-color: transparent;
}
.pagination-modern .page-item .page-link:hover {
  background-color: rgba(102, 126, 234, 0.1);
  color: #667eea;
}
.pagination-modern .page-item.active .page-link {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 10px rgba(102, 126, 234, 0.3);
}
.modern-modal {
  border-radius: 20px;
  border: none;
  overflow: hidden;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  background: white;
}

/* Scrollbar */
.overlay::-webkit-scrollbar {
  width: 8px;
}
.overlay::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.05);
}
.overlay::-webkit-scrollbar-thumb {
  background: rgba(102, 126, 234, 0.5);
  border-radius: 10px;
}
</style>