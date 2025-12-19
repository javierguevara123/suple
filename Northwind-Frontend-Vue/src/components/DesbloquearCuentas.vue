<template>
  <div class="full-screen-page">
    <div class="overlay">
      
      <div class="container-fluid py-5">
        <div class="row justify-content-center">
          <div class="col-12 col-xl-10">
            
            <div class="mb-4">
              <router-link to="/menuAdmin" class="btn btn-light btn-sm modern-btn text-muted" style="padding: 0.5rem 1rem; font-size: 0.8rem;">
                <i class="fas fa-arrow-left me-2"></i>Volver
              </router-link>
            </div>

            <h2 class="text-center fw-bold mb-5 gradient-title">
              <i class="fas fa-user-lock me-3"></i>Desbloqueo de Cuentas
            </h2>

            <div class="card modern-card">
              <div class="card-header bg-gradient-danger d-flex justify-content-between align-items-center">
                <h5 class="card-title text-white mb-0">
                  <i class="fas fa-users-slash me-2"></i>Usuarios Bloqueados
                  <span class="badge bg-light text-dark ms-2">{{ paginacion.totalCount }}</span>
                </h5>
                <div class="d-flex align-items-center">
                  <button class="btn btn-sm btn-outline-light" @click="obtenerUsuariosBloqueados">
                    <i class="fas fa-sync-alt"></i> Refrescar
                  </button>
                </div>
              </div>
              
              <div class="card-body">
                <div class="table-responsive">
                  <table class="table table-hover modern-table">
                    <thead class="table-dark">
                      <tr>
                        <th>Cédula</th>
                        <th>Nombre</th>
                        <th>Correo</th>
                        <th>Fin del Bloqueo</th>
                        <th class="text-center">Acción</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="usuarios.length === 0">
                        <td colspan="5" class="text-center py-4 text-muted">
                          <i class="fas fa-check-circle text-success me-2"></i> No hay usuarios bloqueados en este momento.
                        </td>
                      </tr>
                      <tr v-for="user in usuarios" :key="user.email" class="table-row">
                        <td class="fw-bold">{{ user.cedula }}</td>
                        <td>{{ user.firstName }} {{ user.lastName }}</td>
                        <td class="text-primary">{{ user.email }}</td>
                        <td>
                          <span class="badge bg-warning text-dark">
                            <i class="fas fa-clock me-1"></i>
                            {{ formatearFecha(user.lockoutEnd) }}
                          </span>
                        </td>
                        <td class="text-center">
                          <button
                            class="btn-action btn-unlock"
                            @click="confirmarDesbloqueo(user)"
                            :disabled="loading"
                            title="Desbloquear cuenta"
                          >
                            <i class="fas fa-unlock-alt"></i> Desbloquear
                          </button>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <div class="d-flex justify-content-between align-items-center mt-4" v-if="paginacion.totalPages > 0">
                  <div class="text-muted small">
                    Mostrando página {{ paginacion.pageNumber }} de {{ paginacion.totalPages }}
                  </div>
                  <nav aria-label="Navegación">
                    <ul class="pagination pagination-modern mb-0">
                      <li class="page-item" :class="{ disabled: !paginacion.hasPreviousPage }">
                        <button class="page-link" @click="cambiarPagina(-1)">
                          <i class="fas fa-chevron-left"></i>
                        </button>
                      </li>
                      <li class="page-item active">
                        <button class="page-link">{{ paginacion.pageNumber }}</button>
                      </li>
                      <li class="page-item" :class="{ disabled: !paginacion.hasNextPage }">
                        <button class="page-link" @click="cambiarPagina(1)">
                          <i class="fas fa-chevron-right"></i>
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
    <div class="modal fade" ref="notifModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content modern-modal">
          <div :class="['modal-header', modal.tipo === 'error' || modal.tipo === 'confirmacion' ? 'bg-gradient-danger' : 'bg-gradient-success']">
            <h5 class="modal-title text-white">
              <i :class="['fas', modal.tipo === 'exito' ? 'fa-check-circle' : modal.tipo === 'confirmacion' ? 'fa-question-circle' : 'fa-exclamation-triangle', 'me-2']"></i>
              {{ modal.tipo === 'exito' ? '¡Éxito!' : modal.tipo === 'confirmacion' ? 'Confirmar' : 'Error' }}
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModal"></button>
          </div>
          <div class="modal-body text-center">
            <p class="fs-5">{{ modal.mensaje }}</p>
            <p v-if="modal.subMensaje" class="text-muted small">{{ modal.subMensaje }}</p>
          </div>
          <div class="modal-footer">
            <template v-if="modal.tipo === 'confirmacion'">
              <button type="button" class="btn btn-success modern-btn" :disabled="loading" @click="ejecutarDesbloqueo">Sí, Desbloquear</button>
              <button type="button" class="btn btn-secondary modern-btn" @click="cerrarModal">Cancelar</button>
            </template>
            <template v-else>
              <button type="button" class="btn btn-secondary modern-btn" @click="cerrarModal">Cerrar</button>
            </template>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script>
import { Modal } from 'bootstrap';

export default {
  name: "DesbloquearCuentas",
  data() {
    return {
      usuarios: [],
      paginacion: {
        pageNumber: 1,
        pageSize: 10,
        totalCount: 0,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false
      },
      loading: false,
      
      // Estado para la acción actual
      usuarioADesbloquear: null,

      // Modal
      modal: {
        tipo: "", 
        mensaje: "",
        subMensaje: "",
        accion: null,
      },
      notifModalInstance: null,
    };
  },
  mounted() {
    this.inicializarModales();
    this.obtenerUsuariosBloqueados();
  },
  methods: {
    inicializarModales() {
      if (this.$refs.notifModal) this.notifModalInstance = new Modal(this.$refs.notifModal);
    },

    // --- UTILS ---
    formatearFecha(fecha) {
        if (!fecha) return 'Indefinido';
        return new Date(fecha).toLocaleString();
    },

    mostrarNotificacion(tipo, mensaje, subMensaje = "") {
      this.modal = { tipo, mensaje, subMensaje };
      this.notifModalInstance?.show();
    },
    
    cerrarModal() {
      this.notifModalInstance?.hide();
      this.usuarioADesbloquear = null;
    },

    // --- API: OBTENER USUARIOS ---
    async obtenerUsuariosBloqueados() {
      try {
        this.loading = true;
        const token = localStorage.getItem("token");
        
        const params = new URLSearchParams({
            pageNumber: this.paginacion.pageNumber,
            pageSize: this.paginacion.pageSize
        });

        const url = `https://localhost:7176/user/GetLockedOutUsers?${params.toString()}`;

        const res = await fetch(url, {
          headers: { 
            'accept': '*/*',
            'Authorization': `Bearer ${token}` 
          },
        });

        if (!res.ok) throw new Error("Error al obtener usuarios bloqueados");

        const data = await res.json();

        this.usuarios = data.items;
        this.paginacion.totalCount = data.totalCount;
        this.paginacion.totalPages = data.totalPages;
        this.paginacion.hasPreviousPage = data.hasPreviousPage;
        this.paginacion.hasNextPage = data.hasNextPage;

      } catch (error) {
        console.error("Error:", error);
        this.mostrarNotificacion("error", "No se pudieron cargar los usuarios bloqueados.");
      } finally {
        this.loading = false;
      }
    },

    cambiarPagina(delta) {
        const nuevaPagina = this.paginacion.pageNumber + delta;
        if (nuevaPagina > 0 && nuevaPagina <= this.paginacion.totalPages) {
            this.paginacion.pageNumber = nuevaPagina;
            this.obtenerUsuariosBloqueados();
        }
    },

    // --- API: DESBLOQUEAR ---
    confirmarDesbloqueo(user) {
        this.usuarioADesbloquear = user;
        this.modal = {
            tipo: "confirmacion",
            mensaje: `¿Estás seguro de desbloquear la cuenta de ${user.firstName}?`,
            subMensaje: `Correo: ${user.email}`
        };
        this.notifModalInstance?.show();
    },

    async ejecutarDesbloqueo() {
        if (!this.usuarioADesbloquear) return;

        this.loading = true;
        // Cerramos modal de confirmación
        this.notifModalInstance?.hide();

        try {
            const token = localStorage.getItem("token");
            
            // Endpoint POST /user/UnlockUser
            // Body: { "email": "..." }
            const res = await fetch("https://localhost:7176/user/UnlockUser", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "accept": "*/*",
                    "Authorization": `Bearer ${token}`,
                },
                body: JSON.stringify({
                    email: this.usuarioADesbloquear.email
                })
            });

            if (!res.ok) throw new Error("Error al desbloquear usuario");

            // Éxito
            this.mostrarNotificacion("exito", "Cuenta desbloqueada exitosamente.");
            this.obtenerUsuariosBloqueados(); // Refrescar lista

        } catch (error) {
            console.error("Error:", error);
            this.mostrarNotificacion("error", "No se pudo desbloquear la cuenta.");
        } finally {
            this.loading = false;
            this.usuarioADesbloquear = null;
        }
    }
  },
};
</script>

<style scoped>
/* =========================================
   ESTILOS MODERNOS (Consistent)
========================================= */
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
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
.bg-gradient-danger { background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%); }
.bg-gradient-success { background: linear-gradient(135deg, #2ecc71 0%, #27ae60 100%); }

.modern-card {
  border: none; border-radius: 20px; background: #ffffff;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); overflow: hidden; transition: all 0.3s ease;
}
.modern-card:hover { transform: translateY(-5px); box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15); }
.modern-card .card-header { border: none; padding: 1.5rem; }
.modern-card .card-body { padding: 2rem; }

/* Botones */
.modern-btn {
  border-radius: 50px; padding: 0.75rem 2rem; font-weight: 600; text-transform: uppercase;
  letter-spacing: 0.5px; transition: all 0.3s ease; border: none; position: relative; overflow: hidden;
}
.modern-btn:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2); }

/* Tabla */
.modern-table { border-radius: 15px; overflow: hidden; border: none; background-color: white; }
.modern-table .table-dark { background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%); }
.table-row:hover { background-color: rgba(102, 126, 234, 0.1); }

.btn-action {
  display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px;
  border: none; border-radius: 6px; font-size: 12px; font-weight: 500; cursor: pointer;
  transition: all 0.2s ease; min-width: 100px; justify-content: center;
}
.btn-unlock { background-color: #27ae60; color: white; }
.btn-unlock:hover:not(:disabled) { background-color: #219150; transform: translateY(-1px); box-shadow: 0 2px 4px rgba(46, 204, 113, 0.3); }
.btn-unlock:disabled { opacity: 0.6; cursor: not-allowed; }

/* Paginación */
.pagination-modern .page-item .page-link {
  border: none; border-radius: 50%; width: 36px; height: 36px;
  display: flex; align-items: center; justify-content: center; margin: 0 4px;
  color: #2c3e50; font-weight: 600; background-color: transparent; transition: all 0.3s ease;
}
.pagination-modern .page-item .page-link:hover { background-color: rgba(102, 126, 234, 0.1); color: #ee5a24; }
.pagination-modern .page-item.active .page-link { background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%); color: white; box-shadow: 0 4px 10px rgba(238, 90, 36, 0.3); }

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