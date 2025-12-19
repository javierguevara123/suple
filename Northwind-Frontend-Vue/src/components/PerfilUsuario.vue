<template>
  <div class="profile-container">
    <div class="profile-header">
      <div class="header-content">
        <h1 class="profile-title">Mi Perfil</h1>
        <p class="profile-subtitle">Gestiona tu información personal</p>
      </div>
    </div>

    <div class="profile-content">
      
      <div v-if="loadingInitial" class="text-center py-5">
        <div class="spinner-border text-primary" role="status"></div>
        <p class="mt-2 text-muted">Cargando información del usuario...</p>
      </div>

      <div v-else>
        <transition name="fade">
          <div v-if="successMessage" class="alert alert-success">
            <div class="alert-icon">✓</div>
            <div class="alert-content">
              <strong>Éxito</strong>
              <p>{{ successMessage }}</p>
            </div>
            <button class="alert-close" @click="successMessage = ''">&times;</button>
          </div>
        </transition>

        <transition name="fade">
          <div v-if="errorMessage" class="alert alert-danger">
            <div class="alert-icon">!</div>
            <div class="alert-content">
              <strong>Error</strong>
              <p>{{ errorMessage }}</p>
            </div>
            <button class="alert-close" @click="errorMessage = ''">&times;</button>
          </div>
        </transition>

        <div v-if="!editMode" class="profile-card">
          <div class="card-header">
            <h2 class="card-title">Información Personal</h2>
          </div>
          <div class="card-body">
            <div class="info-grid">
              <div class="info-item">
                <label class="info-label">Email</label>
                <p class="info-value">{{ userData.email }}</p>
              </div>
              <div class="info-item">
                <label class="info-label">Nombre</label>
                <p class="info-value">{{ userData.firstName }}</p>
              </div>
              <div class="info-item">
                <label class="info-label">Apellido</label>
                <p class="info-value">{{ userData.lastName }}</p>
              </div>
              <div class="info-item">
                <label class="info-label">Cédula</label>
                <p class="info-value">{{ userData.cedula }}</p>
              </div>
              <div class="info-item">
                <label class="info-label">Rol</label>
                <p class="info-value">
                  <span class="role-badge">{{ userData.role }}</span>
                </p>
              </div>
            </div>
            <div class="card-actions">
              <button class="btn btn-primary" @click="activarEdicion">
                Editar Perfil
              </button>
            </div>
          </div>
        </div>

        <div v-else class="profile-card">
          <div class="card-header">
            <h2 class="card-title">Editar Información</h2>
          </div>
          <div class="card-body">
            <form @submit.prevent="actualizarPerfil">
              <div class="form-grid">
                <div class="form-group">
                  <label for="email" class="form-label">Email *</label>
                  <input type="email" class="form-input" id="email" v-model="formData.email" required />
                </div>
                <div class="form-group">
                  <label for="firstName" class="form-label">Nombre *</label>
                  <input type="text" class="form-input" id="firstName" v-model="formData.firstName" required />
                </div>
                <div class="form-group">
                  <label for="lastName" class="form-label">Apellido *</label>
                  <input type="text" class="form-input" id="lastName" v-model="formData.lastName" required />
                </div>
                <div class="form-group">
                  <label for="cedula" class="form-label">Cédula *</label>
                  <input type="text" class="form-input" id="cedula" v-model="formData.cedula" required />
                </div>
              </div>

              <div class="form-divider"></div>

              <div class="form-section">
                <h3 class="section-title">Cambio de Contraseña</h3>
                <p class="section-description">Deja este campo vacío si no deseas cambiar tu contraseña.</p>
                <div class="form-group">
                  <label for="newPassword" class="form-label">Nueva Contraseña</label>
                  <input type="password" class="form-input" id="newPassword" v-model="formData.newPassword" placeholder="••••••••" />
                </div>
              </div>

              <div class="form-actions">
                <button type="button" class="btn btn-secondary" @click="cancelarEdicion" :disabled="loadingSave">Cancelar</button>
                <button type="submit" class="btn btn-success" :disabled="loadingSave">
                  <span v-if="loadingSave" class="spinner-border spinner-border-sm me-2"></span>
                  {{ loadingSave ? "Guardando..." : "Guardar Cambios" }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: "PerfilUsuario",
  data() {
    return {
      // Datos visuales del usuario (Read Only)
      userData: {
        id: "",
        email: "",
        firstName: "",
        lastName: "",
        cedula: "",
        role: ""
      },
      
      // Datos del formulario (Editable)
      formData: {
        email: "",
        firstName: "",
        lastName: "",
        cedula: "",
        newPassword: "",
      },

      editMode: false,
      loadingInitial: true, 
      loadingSave: false,   
      successMessage: "",
      errorMessage: "",
    };
  },
  
  async mounted() {
    await this.obtenerDatosUsuario();
  },

  methods: {
    // 1. Obtener ID del Token y llamar a la API
    async obtenerDatosUsuario() {
      this.loadingInitial = true;
      try {
        const token = localStorage.getItem("token");
        if (!token) throw new Error("No hay sesión activa.");

        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(window.atob(base64).split('').map(c => 
            '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)
        ).join(''));
        
        const claims = JSON.parse(jsonPayload);
        
        // Buscar el ID del usuario en los claims
        const userId = claims["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"] 
                    || claims["nameid"] 
                    || claims["sub"];

        if (!userId) throw new Error("No se pudo identificar el usuario.");

        // Llamada al endpoint GET
        const response = await fetch(`https://localhost:7176/api/users/${userId}`, {
            headers: { 
                'accept': '*/*', 
                'Authorization': `Bearer ${token}` 
            }
        });

        if (!response.ok) throw new Error("Error al obtener datos del servidor.");

        const data = await response.json();

        if (data.success && data.user) {
            this.userData = {
                id: data.user.id,
                email: data.user.email,
                firstName: data.user.firstName,
                lastName: data.user.lastName,
                cedula: data.user.cedula,
                role: data.user.role
            };
            
            // Actualizar localStorage para mantener consistencia en el menú
            localStorage.setItem("firstName", data.user.firstName);
            localStorage.setItem("lastName", data.user.lastName);
            localStorage.setItem("email", data.user.email);
        }

      } catch (error) {
        console.error(error);
        this.errorMessage = "No se pudo cargar la información del perfil.";
      } finally {
        this.loadingInitial = false;
      }
    },

    activarEdicion() {
      this.editMode = true;
      // Copiar datos actuales al formulario
      this.formData = {
        email: this.userData.email,
        firstName: this.userData.firstName,
        lastName: this.userData.lastName,
        cedula: this.userData.cedula,
        newPassword: "",
      };
    },

    cancelarEdicion() {
      this.editMode = false;
      this.errorMessage = "";
      this.formData.newPassword = "";
    },

    // ✅ SOLUCIÓN AL ERROR 415 + ERROR 400 (Usuario no encontrado al cambiar email)
    async actualizarPerfil() {
      this.loadingSave = true;
      this.errorMessage = "";
      this.successMessage = "";

      try {
        const token = localStorage.getItem("token");
        
        // 1. Crear objeto FormData (Compatible con [FromForm] de .NET)
        const formData = new FormData();
        
        // 2. Agregar campos
        // IMPORTANTE: Enviamos el CORREO ORIGINAL como 'currentEmail' para que el backend sepa a quien buscar
        formData.append('currentEmail', this.userData.email); 
        
        // Enviamos el NUEVO CORREO como 'email' para que se actualice
        formData.append('email', this.formData.email);
        
        formData.append('firstName', this.formData.firstName);
        formData.append('lastName', this.formData.lastName);
        formData.append('cedula', this.formData.cedula);
        
        // La contraseña solo se envía si el usuario escribió algo
        if (this.formData.newPassword && this.formData.newPassword.trim() !== "") {
          formData.append('newPassword', this.formData.newPassword);
        }

        // 3. Petición Fetch
        const response = await fetch("https://localhost:7176/user/UpdateUser", {
          method: "PUT",
          headers: {
            // ¡IMPORTANTE! NO PONER 'Content-Type'. 
            // El navegador lo pone automáticamente como 'multipart/form-data' con el boundary.
            Authorization: `Bearer ${token}`,
          },
          body: formData, // Enviamos el objeto FormData directamente
        });

        if (response.ok) {
          this.successMessage = "Perfil actualizado correctamente.";
          
          // Actualizar datos locales visuales sin recargar
          this.userData.email = this.formData.email;
          this.userData.firstName = this.formData.firstName;
          this.userData.lastName = this.formData.lastName;
          this.userData.cedula = this.formData.cedula;
          
          // Actualizar localStorage
          localStorage.setItem("firstName", this.formData.firstName);
          localStorage.setItem("lastName", this.formData.lastName);
          localStorage.setItem("email", this.formData.email);
          localStorage.setItem("cedula", this.formData.cedula);

          this.editMode = false;
          window.scrollTo({ top: 0, behavior: "smooth" });
        } else {
          const text = await response.text();
          // Intentar parsear si es JSON para mostrar un mensaje bonito
          try {
              const errData = JSON.parse(text);
              this.errorMessage = errData.message || errData.detail || "Error al actualizar.";
          } catch {
              this.errorMessage = `Error del servidor: ${text}`;
          }
          window.scrollTo({ top: 0, behavior: "smooth" });
        }
      } catch (error) {
        this.errorMessage = `Error de conexión: ${error.message}`;
        window.scrollTo({ top: 0, behavior: "smooth" });
      } finally {
        this.loadingSave = false;
      }
    },
  },
};
</script>

<style scoped>
/* Estilos para Pantalla Completa y Diseño */
.profile-container {
  position: fixed; 
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  z-index: 2000;
  background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
  overflow-y: auto; 
  padding: 0; 
}

.profile-header {
  background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
  color: white;
  padding: 4rem 2rem 6rem 2rem;
  border-radius: 0 0 50% 50% / 40px;
  margin-bottom: -4rem;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  text-align: center;
  position: relative;
}

.header-content {
  max-width: 800px;
  margin: 0 auto;
}

/* SE ELIMINÓ LA CLASE .btn-back QUE ESTABA AQUÍ
*/

.profile-title { font-size: 2.5rem; font-weight: 800; margin: 0 0 0.5rem 0; }
.profile-subtitle { font-size: 1.1rem; opacity: 0.9; }

.profile-content {
  max-width: 900px;
  margin: 0 auto;
  padding: 0 1.5rem 3rem 1.5rem;
  position: relative;
  z-index: 2;
}

.profile-card {
  background: white;
  border-radius: 20px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
  overflow: hidden;
  border: 1px solid rgba(0,0,0,0.03);
}

.card-header { padding: 1.5rem 2rem; border-bottom: 1px solid #f3f4f6; background: white; }
.card-title { font-size: 1.25rem; font-weight: 700; color: #111827; }
.card-body { padding: 2.5rem; }

/* Grids y Form */
.info-grid, .form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.info-label, .form-label {
  font-size: 0.85rem;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  margin-bottom: 0.5rem;
  display: block;
}

.info-value {
  font-size: 1.1rem;
  color: #1f2937;
  font-weight: 500;
  border-bottom: 1px solid #f3f4f6;
  padding-bottom: 0.5rem;
}

.form-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid #e5e7eb;
  border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s;
  background: #f9fafb;
}
.form-input:focus {
  outline: none;
  background: white;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.role-badge {
  padding: 0.4rem 1rem;
  background: #eff6ff;
  color: #1d4ed8;
  border-radius: 9999px;
  font-size: 0.875rem;
  font-weight: 600;
}

.form-divider { height: 1px; background: #e5e7eb; margin: 2.5rem 0; }
.form-actions, .card-actions { display: flex; justify-content: flex-end; gap: 1rem; margin-top: 2rem; }

.btn { padding: 0.75rem 1.5rem; border-radius: 10px; font-weight: 600; cursor: pointer; transition: all 0.2s; border: none; }
.btn-primary { background: #2563eb; color: white; }
.btn-primary:hover { background: #1d4ed8; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2); }
.btn-success { background: #10b981; color: white; }
.btn-success:hover { background: #059669; }
.btn-secondary { background: white; border: 1px solid #d1d5db; color: #374151; }
.btn-secondary:hover { background: #f3f4f6; }

.alert { display: flex; align-items: center; gap: 1rem; padding: 1rem; border-radius: 12px; margin-bottom: 1.5rem; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
.alert-success { background: #d1fae5; color: #065f46; }
.alert-danger { background: #fee2e2; color: #991b1b; }
.alert-icon { font-weight: bold; font-size: 1.2rem; }
.alert-close { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: inherit; }

/* Scrollbar */
.profile-container::-webkit-scrollbar { width: 10px; }
.profile-container::-webkit-scrollbar-track { background: #f1f1f1; }
.profile-container::-webkit-scrollbar-thumb { background: #c1c1c1; border-radius: 5px; }
.profile-container::-webkit-scrollbar-thumb:hover { background: #a8a8a8; }

@media (max-width: 768px) {
  .info-grid, .form-grid { grid-template-columns: 1fr; }
  .profile-header { padding-top: 3rem; }
  .card-body { padding: 1.5rem; }
}
</style>