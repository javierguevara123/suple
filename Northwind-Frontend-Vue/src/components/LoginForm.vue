<template>
  <div class="login-page">
    <div
      class="overlay d-flex justify-content-center align-items-center min-vh-100"
    >
      <div
        class="card shadow-lg border-0"
        style="width: 100%; max-width: 420px"
      >
        <div class="card-body p-5">
          <div class="text-center mb-4">
            <div class="icon-circle mx-auto mb-3">
              <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="white" viewBox="0 0 16 16">
                <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4zm-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10c-2.29 0-3.516.68-4.168 1.332-.678.678-.83 1.418-.832 1.664h10z"/>
              </svg>
            </div>
            <h2 class="mb-2 fw-bold" style="color: #1a1a1a">Bienvenido de nuevo</h2>
          </div>

          <form @submit.prevent="login" autocomplete="off">
            <div class="mb-3">
              <label for="email" class="form-label small fw-semibold">Username *</label>
              <input
                v-model="email"
                type="email"
                class="form-control form-control-modern"
                :class="{ 'is-invalid': emailError }"
                id="email"
                placeholder="Enter your Username"
              />
              <div v-if="emailError" class="invalid-feedback">
                {{ emailError }}
              </div>
            </div>

            <div class="mb-3">
              <label for="password" class="form-label small fw-semibold">Password *</label>
              <input
                v-model="password"
                type="password"
                class="form-control form-control-modern"
                :class="{ 'is-invalid': passwordError }"
                id="password"
                placeholder="Enter your Password"
              />
              <div v-if="passwordError" class="invalid-feedback">
                {{ passwordError }}
              </div>
            </div>

            <div class="mb-3 form-check">
              <input type="checkbox" class="form-check-input" id="rememberMe" />
              <label class="form-check-label small text-muted" for="rememberMe">
                Remember me
              </label>
            </div>

            <div
              v-if="loginError"
              class="alert alert-danger small text-center p-2 mb-3"
              role="alert"
            >
              <i class="fas fa-exclamation-triangle me-2"></i>{{ loginError }}
            </div>

            <button
              type="submit"
              class="btn btn-primary-modern w-100 fw-semibold py-2 mb-3"
              :disabled="loading"
            >
              <span
                v-if="loading"
                class="spinner-border spinner-border-sm me-2"
              ></span>
              Acceso
            </button>

            <div class="text-center">
              <a href="#" class="small text-muted text-decoration-none">
                ¿Se te olvidó tu contraseña?
              </a>
            </div>
            <div class="text-center mt-2">
              <router-link
                to="/register"
                class="small text-muted text-decoration-none"
              >
                ¿No tienes una cuenta?
              </router-link>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { jwtDecode } from "jwt-decode";

export default {
  name: "LoginForm",
  data() {
    return {
      email: "",
      password: "",
      emailError: "",
      passwordError: "",
      loginError: "",
      loading: false,
    };
  },
  methods: {
    validateEmail(email) {
      const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      return re.test(email);
    },
    async login() {
      // 1. Limpiar errores previos
      this.emailError = "";
      this.passwordError = "";
      this.loginError = "";
      this.loading = true;

      // 2. Validaciones locales simples
      if (!this.email) {
        this.emailError = "El correo es obligatorio.";
      } else if (!this.validateEmail(this.email)) {
        this.emailError = "El correo no tiene un formato válido.";
      }

      if (!this.password) {
        this.passwordError = "La contraseña es obligatoria.";
      }

      if (this.emailError || this.passwordError) {
        this.loading = false;
        return;
      }

      // 3. Petición al Backend
      try {
        const response = await fetch("https://localhost:7176/user/Login", {
          method: "POST",
          headers: { 
            "Content-Type": "application/json",
            "accept": "*/*"
          },
          body: JSON.stringify({ email: this.email, password: this.password }),
        });

        // 4. Manejo de Respuesta Exitosa (200 OK)
        if (response.ok) {
          const data = await response.json();
          
          if (data.accessToken) {
            localStorage.setItem("token", data.accessToken);
            
            const decoded = jwtDecode(data.accessToken);
            const role = decoded["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"];
            const fullName = decoded["FullName"];
            const userName = decoded["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"];
            
            localStorage.setItem("role", role);
            localStorage.setItem("email", userName);
            localStorage.setItem("fullName", fullName || "");
            
            if (role === "SuperUser" || role === "Administrator") {
              this.$router.push("/menuAdmin");
            } else if (role === "Employee") {
              this.$router.push("/menuPrincipal");
            } else {
              this.loginError = "Rol no permitido.";
            }
          } else {
            this.loginError = "Respuesta del servidor inválida.";
          }
        } else {
          // 5. MANEJO DE ERRORES (400 Bad Request, Bloqueos, Credenciales)
          try {
            const errorData = await response.json();
            
            // Verificamos si viene el array "errors" (formato ProblemDetails de tu API)
            if (errorData.errors && Array.isArray(errorData.errors) && errorData.errors.length > 0) {
                // Tomamos el primer error de la lista.
                // Aquí vendrá: "Su cuenta ha sido bloqueada..." o "Las credenciales... son incorrectas"
                this.loginError = errorData.errors[0].errorMessage;
            } 
            // Si no hay array errors, buscamos 'detail'
            else if (errorData.detail) {
                this.loginError = errorData.detail;
            } 
            // Si no hay detail, buscamos 'title'
            else if (errorData.title) {
                this.loginError = errorData.title;
            } 
            // Fallback genérico
            else {
                this.loginError = "Error al iniciar sesión.";
            }

          } catch (e) {
            // Si el backend no devuelve JSON
            this.loginError = "Error de conexión o respuesta no válida.";
          }
        }
      } catch (error) {
        console.error(error);
        this.loginError = "Error de conexión con el servidor.";
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style scoped>
.login-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-image: url("https://img.freepik.com/vector-gratis/fondo-minimalista-gradiente_23-2149976755.jpg");
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  overflow: auto;
}

.overlay {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.4) 0%, rgba(240, 242, 245, 0.5) 100%);
  padding: 20px;
}

.card {
  border-radius: 1.5rem;
  backdrop-filter: blur(10px);
  background: rgba(255, 255, 255, 0.98);
}

.icon-circle {
  width: 70px;
  height: 70px;
  background: linear-gradient(135deg, #4c6ef5 0%, #3b5bdb 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(76, 110, 245, 0.3);
}

.form-control-modern {
  border: 1px solid #e0e0e0;
  border-radius: 0.5rem;
  padding: 0.75rem 1rem;
  font-size: 0.95rem;
  transition: all 0.3s ease;
  background-color: #f8f9fa;
}

.form-control-modern:focus {
  border-color: #4c6ef5;
  box-shadow: 0 0 0 0.2rem rgba(76, 110, 245, 0.15);
  background-color: #fff;
}

.form-control-modern::placeholder {
  color: #adb5bd;
}

/* Estilo para el input inválido (borde rojo) */
.is-invalid {
  border-color: #dc3545 !important;
}

.invalid-feedback {
  display: block;
  font-size: 0.85rem;
  color: #dc3545;
  margin-top: 0.25rem;
}

.btn-primary-modern {
  background: linear-gradient(135deg, #4c6ef5 0%, #3b5bdb 100%);
  border: none;
  border-radius: 0.5rem;
  color: white;
  font-size: 1rem;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(76, 110, 245, 0.25);
}

.btn-primary-modern:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(76, 110, 245, 0.35);
  background: linear-gradient(135deg, #5c7cfa 0%, #4c6ef5 100%);
}

.btn-primary-modern:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.form-label {
  color: #495057;
  margin-bottom: 0.5rem;
}

a.text-muted:hover {
  color: #4c6ef5 !important;
  text-decoration: underline !important;
}

.form-check-input:checked {
  background-color: #4c6ef5;
  border-color: #4c6ef5;
}
</style>