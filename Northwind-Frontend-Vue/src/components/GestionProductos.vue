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
              <i class="fas fa-box-open me-3"></i>Gestión de Productos
            </h2>

            <div class="card modern-card mb-5">
              <div class="card-header bg-gradient-primary">
                <h5 class="card-title text-white mb-0">
                  <i class="fas fa-plus-circle me-2"></i>Nuevo Producto
                </h5>
              </div>
              <div class="card-body">
                <form @submit.prevent="crearProducto">
                  <div class="row g-4">
                    <div class="col-md-6">
                      <div class="form-floating">
                        <input 
  v-model="nuevoProducto.name" 
  type="text" 
  class="form-control modern-input" 
  :class="{ 'is-invalid': errorNombre }" 
  id="newName" 
  placeholder="Nombre" 
  required 
  autocomplete="off"
  @input="filtrarLetrasNumeros($event, nuevoProducto, 'name')" 
/>
                        <label for="newName">Nombre del Producto</label>
                        
                        <div v-if="errorNombre" class="invalid-feedback d-block text-start ps-1">
                          <i class="fas fa-exclamation-circle me-1"></i>{{ errorNombre }}
                        </div>
                      </div>
                    </div>
                    
                    <div class="col-md-3">
                      <div class="form-floating">
                        <input 
                          v-model.number="nuevoProducto.unitPrice" 
                          type="number" 
                          step="0.01" 
                          class="form-control modern-input" 
                          id="newPrice" 
                          placeholder="Precio" 
                          required 
                          min="0"
                          autocomplete="off"
                          @input="validarLongitud($event, nuevoProducto, 'unitPrice', 4)"
                        />
                        <label for="newPrice">Precio Unitario</label>
                      </div>
                    </div>

                    <div class="col-md-3">
                      <div class="form-floating">
                        <input 
                          v-model.number="nuevoProducto.unitsInStock" 
                          type="number" 
                          class="form-control modern-input" 
                          id="newStock" 
                          placeholder="Stock" 
                          required 
                          min="0"
                          autocomplete="off"
                          @input="validarLongitud($event, nuevoProducto, 'unitsInStock', 4)"
                        />
                        <label for="newStock">Stock Inicial</label>
                      </div>
                    </div>

                    <div class="col-12">
                      <div class="card bg-light border-0">
                        <div class="card-body">
                          <label class="form-label fw-bold mb-3">
                            <i class="fas fa-image me-2"></i>Imagen del Producto
                          </label>
                          <div class="row align-items-center g-3">
                            <div class="col-md-6">
                              <input 
                                type="file" 
                                accept="image/png, image/jpeg, image/jpg, image/gif, image/webp, .jpg, .jpeg, .png, .webp" 
                                class="form-control modern-input" 
                                @change="seleccionarImagenProducto"
                                ref="inputImagenProducto"
                              />
                              <small class="text-muted d-block mt-2">Formatos: JPG, JPEG, PNG, GIF, WebP (Máx 5MB)</small>
                            </div>
                            <div class="col-md-6 text-center">
                              <div v-if="previewProducto" class="preview-container">
                                <img :src="previewProducto" alt="Preview" class="preview-image">
                                <button type="button" class="btn btn-sm btn-danger mt-2" @click="limpiarImagenProducto">
                                  <i class="fas fa-trash me-1"></i>Limpiar
                                </button>
                              </div>
                              <div v-else class="text-muted">
                                <i class="fas fa-box fa-2x mb-2"></i>
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
                        <i class="fas fa-save me-2"></i>Crear Producto
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
                        autocomplete="off"
                      />
                      <label for="buscador">
                        <i class="fas fa-search me-2"></i>Escribe para buscar...
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
                  <i class="fas fa-list me-2"></i>Lista de Productos
                  <span class="badge bg-light text-dark ms-2">{{ paginacion.totalCount }}</span>
                </h5>
                <div class="d-flex align-items-center">
                  <span class="text-white me-2 small">Mostrar:</span>
                  <select v-model="paginacion.pageSize" @change="cambiarTamanoPagina" class="form-select form-select-sm modern-input py-1" style="width: auto; background-color: rgba(255,255,255,0.9);">
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
                        <th>ID</th>
                        <th>Nombre</th>
                        <th>Precio</th>
                        <th>Stock</th>
                        <th>Valor Total</th>
                        <th class="text-center">Estado</th>
                        <th class="text-center">Acciones</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="buscando">
                        <td colspan="8" class="text-center py-5">
                           <div class="spinner-border text-primary" role="status"></div>
                           <p class="mt-2 text-muted">Buscando...</p>
                        </td>
                      </tr>
                      
                      <tr v-else-if="productos.length === 0">
                        <td colspan="8" class="text-center py-4 text-muted">
                          No se encontraron productos.
                        </td>
                      </tr>

                      <tr v-else v-for="producto in productos" :key="producto.id" class="table-row">
                        <td class="text-center">
                          <img v-if="producto.profilePictureBase64" :src="obtenerUrlImagen(producto.profilePictureBase64)" alt="Foto" class="producto-avatar">
                          <div v-else class="avatar-placeholder"><i class="fas fa-box"></i></div>
                        </td>
                        <td class="fw-bold">{{ producto.id }}</td>
                        <td><span class="user-info">{{ producto.name }}</span></td>
                        <td>${{ producto.unitPrice ? producto.unitPrice.toFixed(2) : '0.00' }}</td>
                        <td>{{ producto.unitsInStock }}</td>
                        <td class="text-muted">${{ producto.totalValue ? producto.totalValue.toFixed(2) : '0.00' }}</td>
                        <td class="text-center">
                          <span class="badge" :class="producto.isLowStock ? 'bg-danger' : 'bg-success'">
                            {{ producto.isLowStock ? 'Bajo Stock' : 'Normal' }}
                          </span>
                        </td>
                        <td class="text-center">
                          <div class="action-buttons">
                            <button class="btn-action btn-edit" @click="prepararEdicion(producto)" :disabled="loading" title="Editar"><i class="fas fa-edit"></i> Editar</button>
                            <button class="btn-action btn-delete" @click="confirmarEliminacion(producto.id)" :disabled="loading" title="Eliminar"><i class="fas fa-trash"></i> Eliminar</button>
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
                      <li class="page-item" :class="{ disabled: !paginacion.hasPreviousPage }">
                        <button class="page-link" @click="cambiarPagina(-1)"><i class="fas fa-chevron-left"></i></button>
                      </li>
                      <li v-for="pagina in paginasVisibles" :key="pagina" class="page-item" :class="{ active: pagina === paginacion.pageNumber }">
                        <button class="page-link" @click="irAPagina(pagina)">{{ pagina }}</button>
                      </li>
                      <li class="page-item" :class="{ disabled: !paginacion.hasNextPage }">
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
      <div class="modal-dialog">
        <div class="modal-content modern-modal">
          <div class="modal-header bg-gradient-primary">
            <h5 class="modal-title text-white"><i class="fas fa-edit me-2"></i>Editar Producto</h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalEditar"></button>
          </div>
          <div class="modal-body">
            <div v-if="loadingData" class="text-center py-4">
                <div class="spinner-border text-primary" role="status"></div>
                <p class="mt-2 text-muted">Cargando datos...</p>
            </div>
            <div v-else class="row g-3">
              <div class="col-12">
                <div class="form-floating">
                  <input v-model="productoEditado.id" type="text" class="form-control modern-input" id="editId" disabled style="background-color: #f0f0f0;" />
                  <label for="editId">ID (No editable)</label>
                </div>
              </div>
              <div class="col-12">
                <div class="form-floating">
                  <input 
  v-model="productoEditado.name" 
  type="text" 
  class="form-control modern-input" 
  id="editName" 
  placeholder="Nombre" 
  required 
  @input="filtrarLetrasNumeros($event, productoEditado, 'name')" 
/>
                  <label for="editName">Nombre del Producto</label>
                </div>
              </div>
              
              <div class="col-6">
                <div class="form-floating">
                  <input 
                    v-model.number="productoEditado.unitPrice" 
                    type="number" 
                    step="0.01" 
                    class="form-control modern-input" 
                    id="editPrice" 
                    placeholder="Precio" 
                    required 
                    autocomplete="off"
                    @input="validarLongitud($event, productoEditado, 'unitPrice', 4)"
                  />
                  <label for="editPrice">Precio</label>
                </div>
              </div>

              <div class="col-6">
                <div class="form-floating">
                  <input 
                    v-model.number="productoEditado.unitsInStock" 
                    type="number" 
                    class="form-control modern-input" 
                    id="editStock" 
                    placeholder="Stock" 
                    required 
                    autocomplete="off"
                    @input="validarLongitud($event, productoEditado, 'unitsInStock', 4)"
                  />
                  <label for="editStock">Stock</label>
                </div>
              </div>

              <div class="col-12">
                <div class="card bg-light border-0">
                  <div class="card-body">
                    <label class="form-label fw-bold mb-3">
                      <i class="fas fa-image me-2"></i>Actualizar Imagen
                    </label>
                    <div class="row align-items-center g-3">
                      <div class="col-md-6">
                        <input 
                          type="file" 
                          accept="image/png, image/jpeg, image/jpg, image/gif, image/webp, .jpg, .jpeg, .png, .webp" 
                          class="form-control modern-input" 
                          @change="seleccionarImagenProductoEdicion"
                          ref="inputImagenProductoEdicion"
                        />
                        <small class="text-muted d-block mt-2">Dejar vacío para mantener actual</small>
                      </div>
                      <div class="col-md-6 text-center">
                        <div v-if="previewProductoEdicion" class="preview-container">
                          <img :src="previewProductoEdicion" alt="Preview" class="preview-image">
                          <button type="button" class="btn btn-sm btn-danger mt-2" @click="limpiarImagenProductoEdicion">
                            <i class="fas fa-trash me-1"></i>Limpiar
                          </button>
                        </div>
                        <div v-else-if="productoEditado.profilePictureBase64" class="preview-container">
                          <img :src="obtenerUrlImagen(productoEditado.profilePictureBase64)" alt="Actual" class="preview-image">
                          <small class="text-muted d-block mt-2">Imagen Actual</small>
                        </div>
                        <div v-else class="text-muted">
                          <i class="fas fa-box fa-2x mb-2"></i>
                          <p>Sin imagen</p>
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
  name: "GestionProductos",
  data() {
    return {
      productos: [],
      filtroBusqueda: "",
      searchTimeout: null, 
      buscando: false,
      
      errorNombre: "",

      paginacion: {
        pageNumber: 1,
        pageSize: 10,
        totalCount: 0,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false
      },
      
      nuevoProducto: { 
        name: "", 
        unitPrice: 0, 
        unitsInStock: 0,
        profilePictureBase64: null 
      },
      
      productoEditado: { id: 0, name: "", unitPrice: 0, unitsInStock: 0, profilePictureBase64: null },
      previewProducto: null,
      previewProductoEdicion: null,
      
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
            this.cargarProductos();
        }, 500); 
    }
  },
  computed: {
    totalPaginas() {
      if (this.paginacion.totalPages) return this.paginacion.totalPages;
      if (this.paginacion.totalCount && this.paginacion.pageSize) return Math.ceil(this.paginacion.totalCount / this.paginacion.pageSize);
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
    }
  },

  mounted() {
    this.cargarProductos();
    this.inicializarModales();
  },
  
  methods: {
    inicializarModales() {
      if (this.$refs.editarModal) this.editarModalInstance = new Modal(this.$refs.editarModal);
      if (this.$refs.notifModal) this.notifModalInstance = new Modal(this.$refs.notifModal);
    },

    // --- NUEVO MÉTODO PARA CONTROLAR LA LONGITUD DE INPUTS NUMÉRICOS ---
    validarLongitud(event, objeto, propiedad, max) {
      let valor = event.target.value;
      if (valor.length > max) {
        // Cortar el valor visualmente
        valor = valor.slice(0, max);
        event.target.value = valor;
      }
      // Actualizar el modelo de Vue manualmente para asegurar sincronización
      // parseFloat para que siga siendo número (si está vacío, poner 0 o null)
      objeto[propiedad] = valor === '' ? 0 : parseFloat(valor);
    },

  filtrarLetrasNumeros(event, objeto, campo) {
    let valor = event.target.value;
    valor = valor.replace(/[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]/g, '');
    objeto[campo] = valor;
    event.target.value = valor;
},
    
    // HELPERS IMÁGENES
    obtenerUrlImagen(base64) {
      if (!base64) return null;
      if (base64.startsWith('data:image')) return base64;
      let mime = 'image/jpeg';
      if (base64.startsWith('iVBORw')) mime = 'image/png';
      else if (base64.startsWith('R0lGOD')) mime = 'image/gif';
      else if (base64.startsWith('UklGR')) mime = 'image/webp';
      return `data:${mime};base64,${base64}`;
    },
    seleccionarImagenProducto(event) {
      const file = event.target.files[0];
      if (!file) return;
      if (file.size > 5 * 1024 * 1024) return this.mostrarNotificacion("error", "Máximo 5MB");
      const reader = new FileReader();
      reader.onload = (e) => {
        this.previewProducto = e.target.result;
        this.nuevoProducto.profilePictureBase64 = e.target.result.split(',')[1];
      };
      reader.readAsDataURL(file);
    },
    limpiarImagenProducto() {
      this.previewProducto = null;
      this.nuevoProducto.profilePictureBase64 = null;
      this.$refs.inputImagenProducto.value = '';
    },
    
    // EDICIÓN IMAGEN
    seleccionarImagenProductoEdicion(event) {
      const file = event.target.files[0];
      if (!file) return;
      if (file.size > 5 * 1024 * 1024) return this.mostrarNotificacion("error", "Máximo 5MB");
      const reader = new FileReader();
      reader.onload = (e) => {
        this.previewProductoEdicion = e.target.result;
        this.productoEditado.profilePictureBase64 = e.target.result.split(',')[1];
      };
      reader.readAsDataURL(file);
    },
    limpiarImagenProductoEdicion() {
      this.previewProductoEdicion = null;
      this.$refs.inputImagenProductoEdicion.value = '';
    },

    // PAGINACIÓN
    irAPagina(n) { if (n === this.paginacion.pageNumber) return; this.paginacion.pageNumber = n; this.cargarProductos(); },
    cambiarPagina(d) { const n = this.paginacion.pageNumber + d; if (n > 0 && n <= this.totalPaginas) { this.paginacion.pageNumber = n; this.cargarProductos(); } },
    cambiarTamanoPagina() { this.paginacion.pageNumber = 1; this.cargarProductos(); },
    
    // MODALES
    mostrarNotificacion(tipo, mensaje, accion = null) { this.modal = { tipo, mensaje, accion }; this.notifModalInstance?.show(); },
    cerrarModalNotif() { this.notifModalInstance?.hide(); this.modal.accion = null; },
    ejecutarAccionConfirmada() { if (this.modal.accion) this.modal.accion(); },
    cerrarModalEditar() { 
        this.editarModalInstance?.hide(); 
        this.productoEditado = { id: 0, name: "", unitPrice: 0, unitsInStock: 0, profilePictureBase64: null }; 
        this.previewProductoEdicion = null; 
    },

    // API: CARGAR
    async cargarProductos() {
      if(!this.buscando) this.loading = true; 
      try {
        const token = localStorage.getItem("token");
        const params = new URLSearchParams({ PageNumber: this.paginacion.pageNumber, PageSize: this.paginacion.pageSize, OrderDescending: false, OrderBy: 'id' });
        if (this.filtroBusqueda) params.append("SearchTerm", this.filtroBusqueda);
        const url = `https://localhost:7176/api/products?${params.toString()}`;
        const res = await fetch(url, { headers: { 'accept': 'application/json', 'Authorization': `Bearer ${token}` } });
        if (!res.ok) throw new Error("Error al obtener datos");
        const data = await res.json();
        this.productos = data.items; 
        this.paginacion.totalCount = data.totalCount;
        this.paginacion.totalPages = data.totalPages;
        this.paginacion.hasPreviousPage = data.hasPreviousPage;
        this.paginacion.hasNextPage = data.hasNextPage;
      } catch (error) { console.error(error); this.mostrarNotificacion("error", "No se pudieron cargar los productos."); } 
      finally { this.loading = false; this.buscando = false; }
    },
    
    // API: CREAR
    async crearProducto() {
      if(!this.nuevoProducto.name || this.nuevoProducto.unitPrice < 0) {
          return this.mostrarNotificacion("error", "Nombre y precio válidos son requeridos");
      }
      this.loading = true;
      this.errorNombre = ""; 

      try {
          const token = localStorage.getItem("token");
          const payload = {
              name: this.nuevoProducto.name,
              unitsInStock: this.nuevoProducto.unitsInStock,
              unitPrice: this.nuevoProducto.unitPrice,
              profilePictureBase64: this.nuevoProducto.profilePictureBase64
          };
          
          const res = await fetch(`https://localhost:7176/CreateProduct`, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
              body: JSON.stringify(payload)
          });
          
          if(res.ok || res.status === 201) {
              this.mostrarNotificacion("exito", "Producto creado exitosamente");
              this.nuevoProducto = { name: "", unitPrice: 0, unitsInStock: 0, profilePictureBase64: null };
              this.limpiarImagenProducto();
              this.cargarProductos();
          } else {
              const errorText = await res.text();
              try {
                  const errorJson = JSON.parse(errorText);
                  if (errorJson.errors && Array.isArray(errorJson.errors)) {
                      const nameError = errorJson.errors.find(e => e.propertyName === 'Name');
                      if (nameError) {
                          this.errorNombre = nameError.errorMessage;
                          return;
                      }
                  }
                  this.mostrarNotificacion("error", errorJson.detail || "Error al crear producto");
              } catch {
                  this.mostrarNotificacion("error", "Error desconocido: " + errorText);
              }
          }
      } catch (error) {
          this.mostrarNotificacion("error", error.message || "Error de conexión");
      } finally {
          this.loading = false;
      }
    },
    
    // API: PREPARAR EDICIÓN
    async prepararEdicion(producto) {
        this.loadingData = true;
        this.editarModalInstance?.show();
        
        this.productoEditado = { 
            id: producto.id, 
            name: producto.name, 
            unitsInStock: producto.unitsInStock, 
            unitPrice: producto.unitPrice, 
            profilePictureBase64: producto.profilePictureBase64 
        };
        this.previewProductoEdicion = null;

        try {
            const token = localStorage.getItem("token");
            const res = await fetch(`https://localhost:7176/GetProductById/${producto.id}`, { 
                headers: { 'Authorization': `Bearer ${token}` } 
            });
            
            if(res.ok) {
                const data = await res.json();
                this.productoEditado = { 
                    id: data.id, 
                    name: data.name, 
                    unitsInStock: data.unitsInStock, 
                    unitPrice: data.unitPrice, 
                    profilePictureBase64: data.profilePicture || data.profilePictureBase64 || producto.profilePictureBase64
                };
            } else { 
                this.mostrarNotificacion("error", "Error al sincronizar datos, se usan locales."); 
            }
        } catch { 
            this.mostrarNotificacion("error", "Error de conexión, editando datos locales."); 
        } finally { 
            this.loadingData = false; 
        }
    },

    // API: GUARDAR EDICIÓN
    async guardarEdicion() {
        this.loading = true;
        try {
            const token = localStorage.getItem("token");
            const payload = { productId: this.productoEditado.id, name: this.productoEditado.name, unitsInStock: this.productoEditado.unitsInStock, unitPrice: this.productoEditado.unitPrice, profilePictureBase64: this.previewProductoEdicion ? this.productoEditado.profilePictureBase64 : null };
            const res = await fetch(`https://localhost:7176/UpdateProduct/${this.productoEditado.id}`, { method: 'PUT', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }, body: JSON.stringify(payload) });
            if(res.ok) { this.cerrarModalEditar(); this.mostrarNotificacion("exito", "Actualizado correctamente"); this.cargarProductos(); }
            else { this.mostrarNotificacion("error", "Error al actualizar."); }
        } catch { this.mostrarNotificacion("error", "Error de conexión."); }
        finally { this.loading = false; }
    },

    // API: ELIMINAR
    confirmarEliminacion(id) { this.mostrarNotificacion("confirmacion", `¿Eliminar ID: ${id}?`, () => this.eliminarProducto(id)); },
    async eliminarProducto(id) {
        this.cerrarModalNotif(); 
        try {
            const token = localStorage.getItem("token");
            const res = await fetch(`https://localhost:7176/DeleteProduct/${id}`, { method: 'DELETE', headers: { 'Authorization': `Bearer ${token}` } });
            if(res.ok) { this.mostrarNotificacion("exito", "Eliminado correctamente"); this.cargarProductos(); }
            else { this.mostrarNotificacion("error", "Error al eliminar."); }
        } catch { this.mostrarNotificacion("error", "Error de conexión."); }
    },
  }
};
</script>

<style scoped>
/* Estilos idénticos a los anteriores */
.full-screen-page { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background-image: url("https://img.freepik.com/vector-gratis/fondo-minimalista-gradiente_23-2149976755.jpg"); background-size: cover; background-position: center; z-index: 1000; }
.overlay { width: 100%; height: 100%; overflow-y: auto; background: rgba(245, 247, 250, 0.85); padding-bottom: 50px; }
.container-fluid { background: transparent; min-height: auto; }
.gradient-title { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
.bg-gradient-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
.bg-gradient-info { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
.bg-gradient-danger { background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%); }
.modern-card { border: none; border-radius: 20px; background: #ffffff; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); overflow: hidden; }
.modern-card .card-header { border: none; padding: 1.5rem; }
.modern-card .card-body { padding: 2rem; }
.modern-input { border-radius: 15px; border: 2px solid #e9ecef; padding: 0.75rem 1rem; background-color: #fff; }
.modern-input:focus { border-color: #667eea; box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25); }
.modern-input.is-invalid { border-color: #dc3545; background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12' width='12' height='12' fill='none' stroke='%23dc3545'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linejoin='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e"); background-repeat: no-repeat; background-position: right calc(0.375em + 0.1875rem) center; background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem); }
.invalid-feedback { display: block; width: 100%; margin-top: 0.25rem; font-size: 0.875em; color: #dc3545; }
.modern-btn { border-radius: 50px; padding: 0.75rem 2rem; }
.modern-table { border-radius: 15px; overflow: hidden; border: none; background-color: white; }
.modern-table .table-dark { background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%); }
.table-row:hover { background-color: rgba(102, 126, 234, 0.1); }
.producto-avatar { width: 50px; height: 50px; border-radius: 10px; object-fit: cover; border: 2px solid #667eea; }
.avatar-placeholder { width: 50px; height: 50px; border-radius: 10px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); display: flex; align-items: center; justify-content: center; color: white; font-size: 24px; }
.preview-container { display: flex; flex-direction: column; align-items: center; gap: 10px; }
.preview-image { width: 100%; max-width: 150px; height: 150px; object-fit: cover; border-radius: 10px; border: 2px solid #667eea; }
.action-buttons { display: flex; gap: 8px; justify-content: center; align-items: center; }
.btn-action { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border: none; border-radius: 6px; font-size: 12px; font-weight: 500; cursor: pointer; transition: all 0.2s ease; min-width: 70px; justify-content: center; }
.btn-edit { background-color: #ff9500; color: white; }
.btn-delete { background-color: #dc3545; color: white; }
.pagination-modern .page-item .page-link { border: none; border-radius: 50%; width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; margin: 0 4px; color: #2c3e50; font-weight: 600; background-color: transparent; }
.pagination-modern .page-item .page-link:hover { background-color: rgba(102, 126, 234, 0.1); color: #667eea; }
.pagination-modern .page-item.active .page-link { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; box-shadow: 0 4px 10px rgba(102, 126, 234, 0.3); }
.modern-modal { border-radius: 20px; border: none; overflow: hidden; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3); background: white; }
.overlay::-webkit-scrollbar { width: 8px; }
.overlay::-webkit-scrollbar-track { background: rgba(0,0,0,0.05); }
.overlay::-webkit-scrollbar-thumb { background: rgba(102, 126, 234, 0.5); border-radius: 10px; }
</style>