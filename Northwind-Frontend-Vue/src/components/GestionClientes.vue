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
              <i class="fas fa-briefcase me-3"></i>Gestión de Clientes
            </h2>

            <div class="card modern-card mb-4">
              <div class="card-header bg-gradient-primary">
                <h5 class="card-title text-white mb-0">
                  <i class="fas fa-user-plus me-2"></i>Nuevo Cliente
                </h5>
              </div>
              <div class="card-body">
                <form @submit.prevent="crearCliente">
                  <div class="row g-4">
                    
                    <div class="col-md-6">
                      <div class="form-floating">
                        <input 
  v-model="nuevoCliente.id" 
  type="text" 
  class="form-control modern-input" 
  :class="{ 'is-invalid': serverErrors.Id }"
  id="newId" 
  placeholder="ID" 
  maxlength="10" 
  required 
  @input="filtrarSoloLetrasId($event, nuevoCliente, 'id')"
/>
                        <label for="newId">ID Cliente (Ej: ALFKI)</label>
                        <div class="invalid-feedback" v-if="serverErrors.Id">{{ serverErrors.Id }}</div>
                      </div>
                    </div>
                    
                    <div class="col-md-6">
                      <div class="form-floating">
                        <input 
                          v-model="nuevoCliente.name" 
                          type="text" 
                          class="form-control modern-input" 
                          :class="{ 'is-invalid': serverErrors.Name }"
                          id="newName" 
                          placeholder="Nombre" 
                          required 
                          @input="filtrarSoloLetras($event, nuevoCliente, 'name')" 
                        />
                        <label for="newName">Nombre Compañía (Solo letras)</label>
                        <div class="invalid-feedback" v-if="serverErrors.Name">{{ serverErrors.Name }}</div>
                      </div>
                    </div>

                    <div class="col-md-6">
                      <div class="form-floating">
                        <input 
                          v-model="nuevoCliente.cedula" 
                          type="text" 
                          inputmode="numeric" 
                          class="form-control modern-input" 
                          :class="{ 'is-invalid': serverErrors.Cedula }"
                          id="newCedula" 
                          placeholder="Cédula" 
                          maxlength="10"
                          required 
                          @input="filtrarSoloNumeros($event, nuevoCliente, 'cedula', 10)" 
                        />
                        <label for="newCedula">Cédula (10 dígitos)</label>
                        <div class="invalid-feedback" v-if="serverErrors.Cedula">{{ serverErrors.Cedula }}</div>
                      </div>
                    </div>

                    <div class="col-md-6">
                      <div class="form-floating">
                        <input 
                          v-model="nuevoCliente.email" 
                          type="email" 
                          class="form-control modern-input" 
                          :class="{ 'is-invalid': serverErrors.Email }"
                          id="newEmail" 
                          placeholder="Correo" 
                          required 
                          @input="limpiarError('Email')"
                        />
                        <label for="newEmail">Correo Electrónico</label>
                        <div class="invalid-feedback" v-if="serverErrors.Email">{{ serverErrors.Email }}</div>
                      </div>
                    </div>

                    <div class="col-md-6">
                      <div class="form-floating">
                        <input 
                          v-model="nuevoCliente.address" 
                          type="text" 
                          class="form-control modern-input" 
                          id="newAddress" 
                          placeholder="Dirección" 
                        />
                        <label for="newAddress"><i class="fas fa-map-marker-alt me-2"></i>Dirección</label>
                      </div>
                    </div>

                    <div class="col-md-6">
                      <div class="form-floating">
                        <input 
                          v-model="nuevoCliente.phone" 
                          type="text" 
                          inputmode="numeric"
                          class="form-control modern-input" 
                          :class="{ 'is-invalid': serverErrors.Phone }"
                          id="newPhone" 
                          placeholder="Teléfono" 
                          maxlength="10"
                          @input="filtrarSoloNumeros($event, nuevoCliente, 'phone', 10)" 
                        />
                        <label for="newPhone"><i class="fas fa-phone me-2"></i>Teléfono (10 dígitos)</label>
                        <div class="invalid-feedback" v-if="serverErrors.Phone">{{ serverErrors.Phone }}</div>
                      </div>
                    </div>

                    <div class="col-md-6">
                      <div class="form-floating">
                        <input 
  v-model="nuevoCliente.birthDate" 
  type="date" 
  class="form-control modern-input" 
  id="newBirthDate" 
  required
  :min="fechaNacimientoMin"
  :max="fechaNacimientoMax"
/>
                        <label for="newBirthDate"><i class="fas fa-calendar me-2"></i>Fecha Nacimiento</label>
                      </div>
                    </div>

                    <div class="col-md-6">
                      <div class="form-floating">
                        <input 
                          v-model="nuevoCliente.password" 
                          type="password" 
                          class="form-control modern-input" 
                          :class="{ 'is-invalid': serverErrors.Password }"
                          id="newPassword" 
                          placeholder="Contraseña" 
                          required 
                          @input="limpiarError('Password')"
                        />
                        <label for="newPassword">Contraseña</label>
                        <div class="invalid-feedback" v-if="serverErrors.Password">{{ serverErrors.Password }}</div>
                      </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="form-floating">
                        <input 
                          v-model.number="nuevoCliente.currentBalance" 
                          type="number" 
                          class="form-control modern-input" 
                          :class="{ 'is-invalid': serverErrors.CurrentBalance }"
                          id="newBalance" 
                          placeholder="0.00" 
                          step="0.01" 
                          @input="limpiarError('CurrentBalance')"
                        />
                        <label for="newBalance">Saldo Inicial</label>
                        <div class="invalid-feedback" v-if="serverErrors.CurrentBalance">{{ serverErrors.CurrentBalance }}</div>
                      </div>
                    </div>

                    <div class="col-12">
                      <div class="card bg-light border-0">
                        <div class="card-body">
                          <label class="form-label fw-bold mb-3">
                            <i class="fas fa-image me-2"></i>Foto de Perfil
                          </label>
                          <div class="row align-items-center g-3">
                            <div class="col-md-6">
                              <input 
                                type="file" 
                                accept="image/png, image/jpeg, image/jpg, image/gif" 
                                class="form-control modern-input" 
                                @change="seleccionarImagenCliente"
                                ref="inputImagenCliente"
                              />
                              <small class="text-muted d-block mt-2">JPG, JPEG, PNG, GIF (Máx 5MB)</small>
                            </div>
                            <div class="col-md-6 text-center">
                              <div v-if="previewCliente" class="preview-container">
                                <img :src="previewCliente" alt="Preview" class="preview-image">
                                <button type="button" class="btn btn-sm btn-danger mt-2" @click="limpiarImagenCliente">
                                  <i class="fas fa-trash me-1"></i>Limpiar
                                </button>
                              </div>
                              <div v-else class="text-muted">
                                <i class="fas fa-image fa-2x mb-2"></i>
                                <p>Sin imagen seleccionada</p>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="col-12 text-end">
                      <button type="submit" class="btn btn-success modern-btn" :disabled="loading">
                        <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                        <i class="fas fa-plus me-2"></i>Crear Cliente
                      </button>
                    </div>
                  </div>
                </form>
              </div>
            </div>

            <div class="card modern-card mb-4">
              <div class="card-body p-4">
                <div class="row g-3 align-items-center">
                  <div class="col-md-12">
                    <div class="form-floating">
                      <input
                        v-model="filtroBusqueda"
                        type="text"
                        class="form-control modern-input"
                        id="buscador"
                        placeholder="Buscar..."
                      />
                      <label for="buscador">
                        <i class="fas fa-search me-2"></i>Buscar por nombre, correo o ID...
                        <span v-if="buscando" class="spinner-border spinner-border-sm ms-2 text-primary"></span>
                      </label>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="card modern-card">
              <div class="card-header bg-gradient-info d-flex justify-content-between align-items-center">
                <h5 class="card-title text-white mb-0">
                  <i class="fas fa-list me-2"></i>Lista de Clientes
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
                <div class="table-responsive">
                  <table class="table table-hover modern-table">
                    <thead class="table-dark">
                      <tr>
                        <th><i class="fas fa-image me-2"></i>Foto</th>
                        <th><i class="fas fa-id-badge me-2"></i>ID</th>
                        <th><i class="fas fa-building me-2"></i>Datos</th>
                        <th><i class="fas fa-address-card me-2"></i>Cédula</th>
                        <th><i class="fas fa-wallet me-2"></i>Saldo</th>
                        <th class="text-center"><i class="fas fa-cogs me-2"></i>Acciones</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="buscando">
                        <td colspan="6" class="text-center py-5">
                           <div class="spinner-border text-primary" role="status"></div>
                           <p class="mt-2 text-muted">Buscando clientes...</p>
                        </td>
                      </tr>

                      <tr v-else-if="clientes.length === 0">
                        <td colspan="6" class="text-center py-4 text-muted">
                          No se encontraron clientes.
                        </td>
                      </tr>

                      <tr v-else v-for="cliente in clientes" :key="cliente.id" class="table-row">
                        <td class="text-center">
                          <img 
                            v-if="cliente.profilePictureBase64" 
                            :src="obtenerUrlImagen(cliente.profilePictureBase64)" 
                            alt="Foto" 
                            class="cliente-avatar"
                          >
                          <div v-else class="avatar-placeholder">
                            <i class="fas fa-user"></i>
                          </div>
                        </td>
                        <td class="fw-bold text-primary">{{ cliente.id }}</td>
                        <td>
                            <div class="d-flex flex-column">
                                <span class="user-info fw-bold">{{ cliente.name }}</span>
                                <small class="text-muted" v-if="cliente.email">{{ cliente.email }}</small> 
                            </div>
                        </td>
                        <td>{{ cliente.cedula || 'N/A' }}</td>
                        <td>
                          <span class="badge" :class="cliente.currentBalance > 0 ? 'bg-success' : 'bg-secondary'">
                            ${{ cliente.currentBalance ? cliente.currentBalance.toFixed(2) : '0.00' }}
                          </span>
                        </td>
                        <td class="text-center">
                          <div class="action-buttons">
                            <button class="btn-action btn-edit" @click="prepararEdicion(cliente)" :disabled="loading" title="Editar">
                              <i class="fas fa-edit"></i> Editar
                            </button>
                            <button class="btn-action btn-delete" @click="confirmarEliminacion(cliente.id)" :disabled="loading" title="Eliminar">
                              <i class="fas fa-trash"></i> Eliminar
                            </button>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <div class="d-flex flex-column flex-md-row justify-content-between align-items-center mt-4" v-if="totalPaginas > 0 && !buscando">
                  <div class="text-muted small mb-2 mb-md-0">
                    Página <strong>{{ paginacion.pageNumber }}</strong> de <strong>{{ totalPaginas }}</strong>
                  </div>
                  <nav aria-label="Navegación">
                    <ul class="pagination pagination-modern mb-0">
                      <li class="page-item" :class="{ disabled: paginacion.pageNumber === 1 }">
                        <button class="page-link" @click="irAPagina(1)"><i class="fas fa-angle-double-left"></i></button>
                      </li>
                      <li class="page-item" :class="{ disabled: paginacion.pageNumber === 1 }">
                        <button class="page-link" @click="cambiarPagina(-1)"><i class="fas fa-chevron-left"></i></button>
                      </li>
                      <li v-for="pagina in paginasVisibles" :key="pagina" class="page-item" :class="{ active: pagina === paginacion.pageNumber }">
                        <button class="page-link" @click="irAPagina(pagina)">{{ pagina }}</button>
                      </li>
                      <li class="page-item" :class="{ disabled: paginacion.pageNumber >= totalPaginas }">
                        <button class="page-link" @click="cambiarPagina(1)"><i class="fas fa-chevron-right"></i></button>
                      </li>
                      <li class="page-item" :class="{ disabled: paginacion.pageNumber === totalPaginas }">
                        <button class="page-link" @click="irAPagina(totalPaginas)"><i class="fas fa-angle-double-right"></i></button>
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
    <div class="modal fade" ref="editarModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
      <div class="modal-dialog modal-lg">
        <div class="modal-content modern-modal">
          <div class="modal-header bg-gradient-primary">
            <h5 class="modal-title text-white"><i class="fas fa-edit me-2"></i>Editar Cliente</h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalEditar"></button>
          </div>
          <div class="modal-body">
            
            <div v-if="loadingData" class="text-center py-4">
                <div class="spinner-border text-primary" role="status"></div>
                <p class="mt-2 text-muted">Cargando datos del cliente...</p>
            </div>

            <div v-else>
              <div class="row g-3">
                <div class="col-12">
                  <div class="form-floating">
                    <input v-model="clienteEditando.id" type="text" class="form-control modern-input" id="editId" disabled style="background-color: #f0f0f0;" />
                    <label for="editId">ID (No editable)</label>
                  </div>
                </div>

                <div class="col-12">
                  <div class="form-floating">
                    <input 
                      v-model="clienteEditando.name" 
                      type="text" 
                      class="form-control modern-input" 
                      :class="{ 'is-invalid': serverErrors.Name }"
                      id="editName" 
                      placeholder="Nombre" 
                      required 
                      @input="filtrarSoloLetras($event, clienteEditando, 'name')"
                    />
                    <label for="editName">Nombre Compañía (Solo letras)</label>
                    <div class="invalid-feedback" v-if="serverErrors.Name">{{ serverErrors.Name }}</div>
                  </div>
                </div>
                
                <div class="col-md-6">
                  <div class="form-floating">
                    <input 
                      v-model="clienteEditando.cedula" 
                      type="text" 
                      inputmode="numeric"
                      class="form-control modern-input" 
                      :class="{ 'is-invalid': serverErrors.Cedula }"
                      id="editCedula" 
                      placeholder="Cédula" 
                      maxlength="10"
                      @input="filtrarSoloNumeros($event, clienteEditando, 'cedula', 10)"
                    />
                    <label for="editCedula">Cédula (10 dígitos)</label>
                    <div class="invalid-feedback" v-if="serverErrors.Cedula">{{ serverErrors.Cedula }}</div>
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="form-floating">
                    <input 
                      v-model="clienteEditando.email" 
                      type="email" 
                      class="form-control modern-input" 
                      :class="{ 'is-invalid': serverErrors.Email }"
                      id="editEmail" 
                      placeholder="Correo" 
                      @input="limpiarError('Email')"
                    />
                    <label for="editEmail">Correo</label>
                    <div class="invalid-feedback" v-if="serverErrors.Email">{{ serverErrors.Email }}</div>
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="form-floating">
                    <input 
                      v-model="clienteEditando.phone" 
                      type="text" 
                      inputmode="numeric"
                      class="form-control modern-input" 
                      :class="{ 'is-invalid': serverErrors.Phone }"
                      id="editPhone" 
                      placeholder="Teléfono" 
                      maxlength="10"
                      @input="filtrarSoloNumeros($event, clienteEditando, 'phone', 10)"
                    />
                    <label for="editPhone">Teléfono (10 dígitos)</label>
                    <div class="invalid-feedback" v-if="serverErrors.Phone">{{ serverErrors.Phone }}</div>
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="form-floating">
                    <input 
                      v-model="clienteEditando.address" 
                      type="text" 
                      class="form-control modern-input" 
                      id="editAddress" 
                      placeholder="Dirección" 
                    />
                    <label for="editAddress">Dirección</label>
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="form-floating">
                    <input 
  v-model="clienteEditando.birthDate" 
  type="date" 
  class="form-control modern-input" 
  id="editBirthDate" 
  :min="fechaNacimientoMin"
  :max="fechaNacimientoMax"
/>
                    <label for="editBirthDate">Fecha Nacimiento</label>
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="form-floating">
                    <input 
                      v-model="clienteEditando.password" 
                      type="password" 
                      class="form-control modern-input" 
                      :class="{ 'is-invalid': serverErrors.Password }"
                      id="editPassword" 
                      placeholder="Nueva Contraseña" 
                      @input="limpiarError('Password')"
                    />
                    <label for="editPassword">Nueva Contraseña (Opcional)</label>
                    <div class="invalid-feedback" v-if="serverErrors.Password">{{ serverErrors.Password }}</div>
                  </div>
                </div>

                <div class="col-12">
                  <div class="form-floating">
                    <input v-model="clienteEditando.currentBalance" type="number" class="form-control modern-input" id="editBalance" placeholder="Saldo" step="0.01" />
                    <label for="editBalance">Saldo Actual</label>
                  </div>
                </div>

                <div class="col-12">
                  <div class="card bg-light border-0">
                    <div class="card-body">
                      <label class="form-label fw-bold mb-3">
                        <i class="fas fa-image me-2"></i>Actualizar Foto de Perfil
                      </label>
                      <div class="row align-items-center g-3">
                        <div class="col-md-6">
                          <input 
                            type="file" 
                            accept="image/png, image/jpeg, image/jpg, image/gif" 
                            class="form-control modern-input" 
                            @change="seleccionarImagenClienteEdicion"
                            ref="inputImagenClienteEdicion"
                          />
                          <small class="text-muted d-block mt-2">JPG, JPEG, PNG, GIF</small>
                        </div>
                        <div class="col-md-6 text-center">
                          <div v-if="previewClienteEdicion" class="preview-container">
                            <img :src="previewClienteEdicion" alt="Preview" class="preview-image">
                            <button type="button" class="btn btn-sm btn-danger mt-2" @click="limpiarImagenClienteEdicion">
                              <i class="fas fa-trash me-1"></i>Limpiar
                            </button>
                          </div>
                          <div v-else-if="clienteEditando.profilePictureBase64" class="preview-container">
                            <img :src="obtenerUrlImagen(clienteEditando.profilePictureBase64)" alt="Foto actual" class="preview-image">
                            <small class="text-muted d-block mt-2">Foto actual</small>
                          </div>
                          <div v-else class="text-muted">
                            <i class="fas fa-image fa-2x mb-2"></i>
                            <p>Sin imagen</p>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-primary modern-btn" :disabled="loading || loadingData" @click="guardarEdicion">Guardar Cambios</button>
            <button type="button" class="btn btn-secondary modern-btn" @click="cerrarModalEditar">Cancelar</button>
          </div>
        </div>
      </div>
    </div>

    <div class="modal fade" ref="notifModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content modern-modal">
          <div :class="['modal-header', modal.tipo === 'error' || modal.tipo === 'confirmacion' ? 'bg-gradient-danger' : 'bg-gradient-primary']">
            <h5 class="modal-title text-white">
              <i :class="['fas', modal.tipo === 'exito' ? 'fa-check-circle' : modal.tipo === 'confirmacion' ? 'fa-question-circle' : 'fa-exclamation-triangle', 'me-2']"></i>
              {{ modal.tipo === 'exito' ? '¡Éxito!' : modal.tipo === 'confirmacion' ? 'Confirmar' : 'Atención' }}
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalNotif"></button>
          </div>
          <div class="modal-body text-center">
            <p class="fs-5">{{ modal.mensaje }}</p>
          </div>
          <div class="modal-footer">
            <template v-if="modal.tipo === 'confirmacion'">
              <button type="button" class="btn btn-danger modern-btn" :disabled="loading" @click="ejecutarAccionConfirmada">Sí, Confirmar</button>
              <button type="button" class="btn btn-secondary modern-btn" @click="cerrarModalNotif">Cancelar</button>
            </template>
            <template v-else>
              <button type="button" class="btn btn-primary modern-btn" @click="cerrarModalNotif">Entendido</button>
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
  name: "GestionClientes",
  data() {
    return {
      clientes: [],
      filtroBusqueda: "",
      searchTimeout: null,
      buscando: false,
      serverErrors: {},
      paginacion: {
        pageNumber: 1,
        pageSize: 10,
        totalRecords: 0
      },
      nuevoCliente: {
        id: "",
        name: "",
        currentBalance: 0,
        email: "",
        cedula: "",
        password: "",
        address: "",     
        phone: "",       
        birthDate: "",   
        profilePictureBase64: null
      },
      clienteEditando: {
        id: "",
        name: "",
        currentBalance: 0,
        email: "",
        cedula: "",
        password: "",
        address: "",    
        phone: "",      
        birthDate: "",  
        profilePictureBase64: null
      },
      
      previewCliente: null,
      previewClienteEdicion: null,
      
      loading: false,
      loadingData: false,
      
      modal: { tipo: "", mensaje: "", accion: null },
      
      editarModalInstance: null,
      notifModalInstance: null,
    };
  },
  
  watch: {
    filtroBusqueda() {
        if (this.searchTimeout) clearTimeout(this.searchTimeout);
        this.buscando = true;
        this.searchTimeout = setTimeout(() => {
            this.paginacion.pageNumber = 1;
            this.cargarClientes();
        }, 500);
    }
  },

  computed: {
    totalPaginas() {
      if (this.paginacion.totalRecords && this.paginacion.pageSize) {
         return Math.ceil(this.paginacion.totalRecords / this.paginacion.pageSize);
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
fechaNacimientoMin() {
      // Máximo 120 años atrás (opcional, puedes ajustar)
      const hoy = new Date();
      hoy.setFullYear(hoy.getFullYear() - 120);
      return hoy.toISOString().split('T')[0];
    },
    fechaNacimientoMax() {
      // Hoy menos 5 años
      const hoy = new Date();
      hoy.setFullYear(hoy.getFullYear() - 5);
      return hoy.toISOString().split('T')[0];
    },

  },
  
  mounted() {
    this.cargarClientes();
    this.inicializarModales();
  },
  
  methods: {
    inicializarModales() {
      if (this.$refs.editarModal) this.editarModalInstance = new Modal(this.$refs.editarModal);
      if (this.$refs.notifModal) this.notifModalInstance = new Modal(this.$refs.notifModal);
    },

    obtenerUrlImagen(base64) {
      if (!base64) return null;
      if (base64.startsWith('data:image')) return base64;
      let mime = 'image/jpeg';
      if (base64.startsWith('iVBORw')) mime = 'image/png';
      else if (base64.startsWith('R0lGOD')) mime = 'image/gif';
      return `data:${mime};base64,${base64}`;
    },

    limpiarError(campo) {
      if (this.serverErrors[campo]) delete this.serverErrors[campo];
    },

    // 1. FILTRO: Solo permite números (se llama en @input)
    filtrarSoloNumeros(event, objeto, campo, max) {
        let valor = event.target.value;
        
        // Reemplaza todo lo que NO sea un número
        valor = valor.replace(/\D/g, ''); 
        
        // Corta si excede el máximo
        if (valor.length > max) valor = valor.slice(0, max);
        
        // Actualiza el modelo y el input visualmente
        objeto[campo] = valor;
        event.target.value = valor;
        
        // Limpia el error si existía
        const key = campo.charAt(0).toUpperCase() + campo.slice(1);
        this.limpiarError(key);
    },

    // 2. FILTRO: Solo permite letras y espacios (se llama en @input)
    filtrarSoloLetras(event, objeto, campo) {
        let valor = event.target.value;
        
        // Reemplaza lo que NO sea letra o espacio
        // Incluye tildes y ñ
        valor = valor.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
        
        objeto[campo] = valor;
        event.target.value = valor;
        
        const key = campo.charAt(0).toUpperCase() + campo.slice(1);
        this.limpiarError(key);
    },

    filtrarSoloLetrasId(event, objeto, campo) {
    let valor = event.target.value;
    // Solo letras (mayúsculas, minúsculas, tildes y ñ)
    valor = valor.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ]/g, '');
    objeto[campo] = valor;
    event.target.value = valor;
    this.limpiarError('Id');
},

    validarFormatoEmail(email) {
      const re = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
      return re.test(String(email).toLowerCase());
    },

    // Validación Final al hacer Submit
    validarCamposCliente(cliente) {
        const errors = {};
        
        // Si por alguna razón el filtro de entrada falló, revisamos aquí también
        if (!cliente.name || cliente.name.trim().length === 0) {
            errors.Name = "El nombre es requerido.";
        }

        // Cédula exacta
        if (!cliente.cedula || cliente.cedula.length !== 10) {
            errors.Cedula = "La cédula debe tener exactamente 10 números.";
        }

        // Teléfono exacto (si lo puso)
        if (cliente.phone && cliente.phone.length !== 10) {
            errors.Phone = "El teléfono debe tener exactamente 10 números.";
        }

        // Email
        if (!this.validarFormatoEmail(cliente.email)) {
            errors.Email = "El formato del correo no es válido.";
        }

        return errors;
    },

    seleccionarImagenCliente(event) {
      const file = event.target.files[0];
      if (!file) return;
      if (file.size > 5 * 1024 * 1024) {
        this.mostrarNotificacion("error", "La imagen no debe superar 5MB");
        return;
      }
      const reader = new FileReader();
      reader.onload = (e) => {
        this.previewCliente = e.target.result;
        this.nuevoCliente.profilePictureBase64 = e.target.result.split(',')[1];
      };
      reader.readAsDataURL(file);
    },

    limpiarImagenCliente() {
      this.previewCliente = null;
      this.nuevoCliente.profilePictureBase64 = null;
      this.$refs.inputImagenCliente.value = '';
    },

    seleccionarImagenClienteEdicion(event) {
      const file = event.target.files[0];
      if (!file) return;
      if (file.size > 5 * 1024 * 1024) {
        this.mostrarNotificacion("error", "La imagen no debe superar 5MB");
        return;
      }
      const reader = new FileReader();
      reader.onload = (e) => {
        this.previewClienteEdicion = e.target.result;
        this.clienteEditando.profilePictureBase64 = e.target.result.split(',')[1];
      };
      reader.readAsDataURL(file);
    },

    limpiarImagenClienteEdicion() {
      this.previewClienteEdicion = null;
      this.$refs.inputImagenClienteEdicion.value = '';
    },

    irAPagina(numero) {
        if (numero === this.paginacion.pageNumber) return;
        this.paginacion.pageNumber = numero;
        this.cargarClientes();
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

    mostrarNotificacion(tipo, mensaje, accion = null) {
      this.modal = { tipo, mensaje, accion };
      this.notifModalInstance?.show();
    },
    
    cerrarModalNotif() {
      this.notifModalInstance?.hide();
      this.modal.accion = null;
    },
    
    ejecutarAccionConfirmada() {
      if (this.modal.accion) this.modal.accion();
    },
    
    cerrarModalEditar() {
      this.editarModalInstance?.hide();
      this.serverErrors = {}; 
      // Resetear objeto
      this.clienteEditando = { id: "", name: "", currentBalance: 0, email: "", cedula: "", password: "", address:"", phone:"", birthDate:"", profilePictureBase64: null };
      this.previewClienteEdicion = null;
    },

    async cargarClientes() {
      if(!this.buscando) this.loading = true;

      try {
        const token = localStorage.getItem("token");
        const params = new URLSearchParams({
            PageNumber: this.paginacion.pageNumber,
            PageSize: this.paginacion.pageSize,
            OrderDescending: false
        });

        if (this.filtroBusqueda) params.append("SearchTerm", this.filtroBusqueda);

        const url = `https://localhost:7176/api/customers?${params.toString()}`;
        const res = await fetch(url, {
          headers: { 'accept': 'application/json', 'Authorization': `Bearer ${token}` },
        });

        if (!res.ok) throw new Error("Error al obtener datos");

        const data = await res.json();
        this.clientes = data.customers;
        this.paginacion.totalRecords = data.totalRecords;

      } catch (error) {
        console.error(error);
        this.mostrarNotificacion("error", "No se pudieron cargar los clientes.");
      } finally {
        this.loading = false;
        this.buscando = false;
      }
    },
    
    async crearCliente() {
      if(!this.nuevoCliente.id || !this.nuevoCliente.name || !this.nuevoCliente.password) {
          return this.mostrarNotificacion("error", "ID, Nombre y Contraseña son obligatorios");
      }

      this.loading = true;
      this.serverErrors = {}; 

      // 3. Validación final
      const erroresFormato = this.validarCamposCliente(this.nuevoCliente);
      if (Object.keys(erroresFormato).length > 0) {
          this.serverErrors = erroresFormato;
          this.loading = false;
          this.mostrarNotificacion("error", "Corrige los errores en el formulario.");
          return;
      }

      try {
          const token = localStorage.getItem("token");
          const fechaEnvio = this.nuevoCliente.birthDate ? new Date(this.nuevoCliente.birthDate).toISOString() : null;

          const payload = {
              id: this.nuevoCliente.id.toUpperCase(),
              name: this.nuevoCliente.name,
              currentBalance: this.nuevoCliente.currentBalance || 0,
              email: this.nuevoCliente.email,
              cedula: this.nuevoCliente.cedula,
              password: this.nuevoCliente.password,
              address: this.nuevoCliente.address,
              phone: this.nuevoCliente.phone,
              birthDate: fechaEnvio,
              profilePictureBase64: this.nuevoCliente.profilePictureBase64
          };

          const res = await fetch(`https://localhost:7176/CreateCustomer`, {
              method: 'POST',
              headers: { 
                  'Content-Type': 'application/json', 
                  'Authorization': `Bearer ${token}` 
              },
              body: JSON.stringify(payload)
          });

          if(res.ok) {
              this.mostrarNotificacion("exito", "Cliente creado exitosamente");
              this.nuevoCliente = { id: "", name: "", currentBalance: 0, email: "", cedula: "", password: "", address:"", phone:"", birthDate:"", profilePictureBase64: null };
              this.limpiarImagenCliente();
              this.cargarClientes();
          } else {
              const errorData = await res.json();
              if (errorData.errors && Array.isArray(errorData.errors)) {
                  errorData.errors.forEach(err => {
                      this.serverErrors[err.propertyName] = err.errorMessage;
                  });
              } else if (errorData.detail) {
                  this.mostrarNotificacion("error", errorData.detail);
              } else {
                  this.mostrarNotificacion("error", "Error al crear cliente.");
              }
          }
      } catch (error) {
          this.mostrarNotificacion("error", "Error de conexión");
      } finally {
          this.loading = false;
      }
    },
    
    async prepararEdicion(cliente) {
      this.loadingData = true;
      this.serverErrors = {}; 
      this.editarModalInstance?.show();
      
      try {
          const token = localStorage.getItem("token");
          const res = await fetch(`https://localhost:7176/GetCustomerById/${cliente.id}`, {
              headers: { 'Authorization': `Bearer ${token}` }
          });

          if(res.ok) {
              const data = await res.json();
              let formattedDate = "";
              if (data.birthDate) {
                  formattedDate = data.birthDate.split('T')[0];
              }

              this.clienteEditando = {
                  id: data.id,
                  name: data.name,
                  currentBalance: data.currentBalance,
                  email: data.email, 
                  cedula: data.cedula,
                  password: "", 
                  address: data.address || "",    
                  phone: data.phone || "",        
                  birthDate: formattedDate,       
                  profilePictureBase64: data.profilePictureBase64
              };
              this.previewClienteEdicion = null;
          } else {
              this.cerrarModalEditar();
              this.mostrarNotificacion("error", "No se pudo obtener la información del cliente.");
          }
      } catch(error) {
          this.cerrarModalEditar();
          this.mostrarNotificacion("error", "Error de conexión.");
      } finally {
          this.loadingData = false;
      }
    },

    async guardarEdicion() {
        this.loading = true;
        this.serverErrors = {}; 

        // 3. Validación final edición
        const erroresFormato = this.validarCamposCliente(this.clienteEditando);
        if (Object.keys(erroresFormato).length > 0) {
            this.serverErrors = erroresFormato;
            this.loading = false;
            this.mostrarNotificacion("error", "Corrige los errores en el formulario.");
            return;
        }

        try {
            const token = localStorage.getItem("token");
            const fechaEnvio = this.clienteEditando.birthDate ? new Date(this.clienteEditando.birthDate).toISOString() : null;

            const payload = {
                id: this.clienteEditando.id, 
                name: this.clienteEditando.name,
                currentBalance: this.clienteEditando.currentBalance,
                email: this.clienteEditando.email,
                cedula: this.clienteEditando.cedula,
                address: this.clienteEditando.address, 
                phone: this.clienteEditando.phone,     
                birthDate: fechaEnvio,                 
                profilePictureBase64: this.previewClienteEdicion ? this.clienteEditando.profilePictureBase64 : null,
                password: this.clienteEditando.password && this.clienteEditando.password.length > 0 
                          ? this.clienteEditando.password 
                          : null
            };

            const res = await fetch(`https://localhost:7176/UpdateCustomer/${this.clienteEditando.id}`, {
                method: 'PUT',
                headers: { 
                    'Content-Type': 'application/json', 
                    'Authorization': `Bearer ${token}` 
                },
                body: JSON.stringify(payload)
            });

            if(res.ok) {
                this.cerrarModalEditar();
                this.mostrarNotificacion("exito", "Cliente actualizado correctamente");
                this.cargarClientes();
            } else {
                const errorData = await res.json();
                if (errorData.errors && Array.isArray(errorData.errors)) {
                    errorData.errors.forEach(err => {
                        this.serverErrors[err.propertyName] = err.errorMessage;
                    });
                } else if (errorData.detail) {
                    this.mostrarNotificacion("error", errorData.detail);
                } else {
                    this.mostrarNotificacion("error", "Error al actualizar cliente.");
                }
            }
        } catch(error) {
            this.mostrarNotificacion("error", "Error de conexión.");
        } finally {
            this.loading = false;
        }
    },

    confirmarEliminacion(id) {
        this.mostrarNotificacion("confirmacion", `¿Estás seguro de eliminar el cliente ${id}?`, () => {
            this.eliminarCliente(id);
        });
    },

    async eliminarCliente(id) {
        this.cerrarModalNotif(); 
        try {
            const token = localStorage.getItem("token");
            const res = await fetch(`https://localhost:7176/DeleteCustomer/${id}`, {
                method: 'DELETE',
                headers: { 'Authorization': `Bearer ${token}` }
            });

            if(res.ok) {
                this.mostrarNotificacion("exito", "Cliente eliminado correctamente");
                this.cargarClientes();
            } else {
                this.mostrarNotificacion("error", "Error al eliminar cliente.");
            }
        } catch(error) {
            this.mostrarNotificacion("error", "Error de conexión.");
        }
    },
  }
};
</script>

<style scoped>
/* Sin cambios en los estilos */
.full-screen-page {
  position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
  background-image: url("https://img.freepik.com/vector-gratis/fondo-minimalista-gradiente_23-2149976755.jpg");
  background-size: cover; background-position: center; background-repeat: no-repeat; z-index: 1000;
}
.overlay { width: 100%; height: 100%; overflow-y: auto; background: rgba(245, 247, 250, 0.85); padding-bottom: 50px; }
.container-fluid { background: transparent; min-height: auto; }
.gradient-title { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); }
.bg-gradient-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
.bg-gradient-info { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
.bg-gradient-danger { background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%); }
.modern-card { border: none; border-radius: 20px; background: #ffffff; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); overflow: hidden; transition: all 0.3s ease; }
.modern-card:hover { transform: translateY(-5px); box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15); }
.modern-card .card-header { border: none; padding: 1.5rem; }
.modern-card .card-body { padding: 2rem; }
.modern-input { border-radius: 15px; border: 2px solid #e9ecef; transition: all 0.3s ease; padding: 0.75rem 1rem; background-color: #fff; }
.modern-input:focus { border-color: #667eea; box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25); transform: translateY(-2px); }
.form-floating > .modern-input:focus ~ label, .form-floating > .modern-input:not(:placeholder-shown) ~ label { color: #667eea; }
.modern-input.is-invalid { border-color: #dc3545; background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12' width='12' height='12' fill='none' stroke='%23dc3545'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linejoin='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e"); background-repeat: no-repeat; background-position: right calc(0.375em + 0.1875rem) center; background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem); }
.invalid-feedback { display: block; width: 100%; margin-top: 0.25rem; font-size: 0.875em; color: #dc3545; }
.modern-btn { border-radius: 50px; padding: 0.75rem 2rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; transition: all 0.3s ease; border: none; position: relative; overflow: hidden; }
.modern-btn:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2); }
.modern-table { border-radius: 15px; overflow: hidden; border: none; background-color: white; }
.modern-table .table-dark { background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%); }
.table-row:hover { background-color: rgba(102, 126, 234, 0.1); }
.user-info { font-weight: 600; color: #2c3e50; }
.cliente-avatar { width: 50px; height: 50px; border-radius: 50%; object-fit: cover; border: 2px solid #667eea; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
.avatar-placeholder { width: 50px; height: 50px; border-radius: 50%; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); display: flex; align-items: center; justify-content: center; color: white; font-size: 24px; }
.preview-container { display: flex; flex-direction: column; align-items: center; gap: 10px; }
.preview-image { width: 100%; max-width: 150px; height: 150px; object-fit: cover; border-radius: 10px; border: 2px solid #667eea; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
.action-buttons { display: flex; gap: 8px; justify-content: center; align-items: center; }
.btn-action { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border: none; border-radius: 6px; font-size: 12px; font-weight: 500; cursor: pointer; transition: all 0.2s ease; min-width: 70px; justify-content: center; }
.btn-edit { background-color: #ff9500; color: white; }
.btn-edit:hover { background-color: #e8890b; transform: translateY(-1px); box-shadow: 0 2px 4px rgba(255, 149, 0, 0.3); }
.btn-delete { background-color: #dc3545; color: white; }
.btn-delete:hover { background-color: #c82333; transform: translateY(-1px); box-shadow: 0 2px 4px rgba(220, 53, 69, 0.3); }
.pagination-modern .page-item .page-link { border: none; border-radius: 50%; width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; margin: 0 4px; color: #2c3e50; font-weight: 600; background-color: transparent; transition: all 0.3s ease; }
.pagination-modern .page-item .page-link:hover { background-color: rgba(102, 126, 234, 0.1); color: #667eea; }
.pagination-modern .page-item.active .page-link { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; box-shadow: 0 4px 10px rgba(102, 126, 234, 0.3); }
.pagination-modern .page-item.disabled .page-link { color: #ccc; cursor: not-allowed; }
.modern-modal { border-radius: 20px; border: none; overflow: hidden; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3); background: white; }
.modern-modal .modal-header { border: none; padding: 1.5rem 2rem; }
.modern-modal .modal-body { padding: 2rem; }
.modern-modal .modal-footer { border: none; padding: 1.5rem 2rem; background-color: #f8f9fa; }
</style>