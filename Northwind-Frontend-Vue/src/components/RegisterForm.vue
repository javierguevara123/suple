<template>
  <!-- TODO EL TEMPLATE QUEDA EXACTAMENTE IGUAL -->
  <div class="register-page">
    <div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header bg-success text-white">
            <h5 class="modal-title" id="successModalLabel">¡Registro exitoso!</h5>
          </div>
          <div class="modal-body">
            Tu cuenta ha sido creada correctamente. Serás redirigido al login.
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-success w-100" @click="redirectToLogin">
              Ir al Login
            </button>
          </div>
        </div>
      </div>
    </div>
    <div class="overlay d-flex justify-content-center align-items-center min-vh-100">
      <div class="card shadow-lg border-0" style="width: 100%; max-width: 500px;">
        <div class="card-body p-5">
          <div class="text-center mb-4">
            <div class="icon-circle mx-auto mb-3">
              <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="white" viewBox="0 0 16 16">
                <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4zm-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10c-2.29 0-3.516.68-4.168 1.332-.678.678-.83 1.418-.832 1.664h10z"/>
              </svg>
            </div>
            <h2 class="mb-2 fw-bold" style="color: #1a1a1a">Crear Cuenta</h2>
          </div>
          <form @submit.prevent="register" autocomplete="off" novalidate>
            <div class="mb-3">
              <label for="firstName" class="form-label small fw-semibold">Nombre *</label>
              <input
                v-model="firstName"
                type="text"
                class="form-control form-control-modern"
                :class="{ 'is-invalid': firstNameError }"
                id="firstName"
                placeholder="Ingresa tu nombre"
                @input="validateName"
              />
              <div v-if="firstNameError" class="invalid-feedback">
                {{ firstNameError }}
              </div>
            </div>
            <div class="mb-3">
              <label for="lastName" class="form-label small fw-semibold">Apellido *</label>
              <input
                v-model="lastName"
                type="text"
                class="form-control form-control-modern"
                :class="{ 'is-invalid': lastNameError }"
                id="lastName"
                placeholder="Ingresa tu apellido"
                @input="validateLastName"
              />
              <div v-if="lastNameError" class="invalid-feedback">
                {{ lastNameError }}
              </div>
            </div>
            <div class="mb-3">
              <label for="email" class="form-label small fw-semibold">Correo electrónico *</label>
              <input
                v-model="email"
                type="email"
                class="form-control form-control-modern"
                :class="{ 'is-invalid': emailError }"
                id="email"
                placeholder="correo@ejemplo.com"
                @blur="validateEmailField"
              />
              <div v-if="emailError" class="invalid-feedback">
                {{ emailError }}
              </div>
            </div>
            <div class="mb-3">
              <label for="cedula" class="form-label small fw-semibold">Cédula *</label>
              <input
                v-model="cedula"
                type="text"
                class="form-control form-control-modern"
                :class="{ 'is-invalid': cedulaError }"
                id="cedula"
                placeholder="1234567890"
                maxlength="10"
                @input="formatCedula"
                @blur="validateCedula"
              />
              <div v-if="cedulaError" class="invalid-feedback">
                {{ cedulaError }}
              </div>
            </div>
            <div class="mb-3">
              <label for="password" class="form-label small fw-semibold">Contraseña *</label>
              <input
                v-model="password"
                type="password"
                class="form-control form-control-modern"
                :class="{ 'is-invalid': passwordError }"
                id="password"
                placeholder="Crea una contraseña segura"
                @input="validatePassword"
              />
              <div v-if="passwordError" class="invalid-feedback">
                {{ passwordError }}
              </div>
              <div class="form-text small text-muted mt-1" v-if="!passwordError">
                Mín. 8 caracteres: mayúscula, minúscula, número o símbolo (!@#$% etc.)
              </div>
            </div>
            <div class="mb-3">
              <label for="confirmPassword" class="form-label small fw-semibold">Confirmar contraseña *</label>
              <input
                v-model="confirmPassword"
                type="password"
                class="form-control form-control-modern"
                :class="{ 'is-invalid': confirmPasswordError }"
                id="confirmPassword"
                placeholder="Repite tu contraseña"
                @input="validateConfirmPassword"
              />
              <div v-if="confirmPasswordError" class="invalid-feedback">
                {{ confirmPasswordError }}
              </div>
            </div>
            <div v-if="registerError" class="alert alert-danger small text-center p-2 mb-3">
              <i class="fas fa-exclamation-circle me-2"></i>{{ registerError }}
            </div>
            <button
              type="submit"
              class="btn btn-primary-modern w-100 fw-semibold py-2 mb-3"
              :disabled="loading"
            >
              <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
              Registrarse
            </button>
            <div class="text-center">
              <router-link to="/login" class="small text-muted text-decoration-none">
                ¿Ya tienes cuenta? Inicia sesión
              </router-link>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RegisterForm',
  data() {
    return {
      firstName: '',
      lastName: '',
      email: '',
      password: '',
      confirmPassword: '',
      cedula: '',
      // Variables para los mensajes de error
      firstNameError: '',
      lastNameError: '',
      emailError: '',
      passwordError: '',
      confirmPasswordError: '',
      cedulaError: '',
      registerError: '',
      loading: false
    };
  },
  methods: {
    // ========= VALIDACIONES EN TIEMPO REAL =========

    validateName() {
      this.firstName = this.firstName.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
      if (!this.firstName.trim()) {
        this.firstNameError = 'El nombre es obligatorio.';
      } else if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(this.firstName.trim())) {
        this.firstNameError = 'El nombre solo debe contener letras.';
      } else {
        this.firstNameError = '';
      }
    },

    validateLastName() {
      this.lastName = this.lastName.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
      if (!this.lastName.trim()) {
        this.lastNameError = 'El apellido es obligatorio.';
      } else if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(this.lastName.trim())) {
        this.lastNameError = 'El apellido solo debe contener letras.';
      } else {
        this.lastNameError = '';
      }
    },

    validateEmailField() {
      if (!this.email.trim()) {
        this.emailError = 'El correo es obligatorio.';
      } else if (!this.validateEmail(this.email)) {
        this.emailError = 'Ingresa un correo electrónico válido.';
      } else {
        this.emailError = '';
      }
    },

    validateEmail(email) {
      const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      return re.test(email);
    },

    formatCedula() {
      this.cedula = this.cedula.replace(/[^0-9]/g, '').slice(0, 10);
      // Limpiamos error mientras escribe
      if (this.cedula.length <= 10) this.cedulaError = '';
    },

    validateCedula() {
      if (!this.cedula) {
        this.cedulaError = 'La cédula es obligatoria.';
        return false;
      }
      if (this.cedula.length !== 10) {
        this.cedulaError = 'La cédula debe tener exactamente 10 dígitos.';
        return false;
      }

      // Algoritmo de validación de cédula ecuatoriana
      const digitos = this.cedula.split('').map(Number);
      const verificador = digitos.pop();
      let suma = 0;

      for (let i = 0; i < digitos.length; i++) {
        let valor = digitos[i];
        if (i % 2 === 0) { // posiciones impares (0,2,4,6,8)
          valor *= 2;
          if (valor > 9) valor -= 9;
        }
        suma += valor;
      }

      const calculado = (10 - (suma % 10)) % 10;
      if (calculado !== verificador) {
        this.cedulaError = 'Cédula inválida debe ser ecuatoria.';
        return false;
      }

      this.cedulaError = '';
      return true;
    },

    validatePassword() {
  const pass = this.password;
  const hasUpperCase = /[A-Z]/.test(pass);        // ← NUEVO: al menos una mayúscula
  const hasLowerCase = /[a-z]/.test(pass);
  const hasNumber    = /\d/.test(pass);
  const hasSpecial   = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(pass);
  const minLength    = pass.length >= 8;

  if (!pass) {
    this.passwordError = 'La contraseña es obligatoria.';
  } else if (!(hasUpperCase && hasLowerCase && hasNumber && hasSpecial && minLength)) {
    this.passwordError = 'Debe tener al menos 8 caracteres, una mayúscula, minúscula, número y símbolo.';
  } else {
    this.passwordError = '';
  }

  // Revalidamos confirmación si ya hay texto
  if (this.confirmPassword) this.validateConfirmPassword();
},

    validateConfirmPassword() {
      if (!this.confirmPassword) {
        this.confirmPasswordError = 'Debes confirmar la contraseña.';
      } else if (this.password !== this.confirmPassword) {
        this.confirmPasswordError = 'Las contraseñas no coinciden.';
      } else {
        this.confirmPasswordError = '';
      }
    },

    showSuccessModal() {
      const modalEl = document.getElementById('successModal');
      if (modalEl && window.bootstrap) {
        const modal = new window.bootstrap.Modal(modalEl);
        modal.show();
      }
    },

    redirectToLogin() {
      const modalEl = document.getElementById('successModal');
      if (modalEl && window.bootstrap) {
        const modal = window.bootstrap.Modal.getInstance(modalEl);
        if (modal) modal.hide();
      }
      setTimeout(() => {
        this.$router.push('/login');
      }, 300);
    },

    limpiarErrores() {
      this.firstNameError = '';
      this.lastNameError = '';
      this.emailError = '';
      this.passwordError = '';
      this.confirmPasswordError = '';
      this.cedulaError = '';
      this.registerError = '';
    },

    async register() {
      this.limpiarErrores();

      // Forzamos todas las validaciones antes de enviar
      this.validateName();
      this.validateLastName();
      this.validateEmailField();
      this.validateCedula();
      this.validatePassword();
      this.validateConfirmPassword();

      // Si hay cualquier error, no enviamos
      if (this.firstNameError || this.lastNameError || this.emailError ||
          this.cedulaError || this.passwordError || this.confirmPasswordError) {
        return;
      }

      this.loading = true;

      try {
        const response = await fetch('https://localhost:7176/user/Register', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'accept': '*/*'
          },
          body: JSON.stringify({
            email: this.email.toLowerCase().trim(),
            password: this.password,
            firstName: this.firstName.trim(),
            lastName: this.lastName.trim(),
            cedula: this.cedula
          })
        });

        if (response.ok) {
          this.firstName = ''; this.lastName = ''; this.email = '';
          this.password = ''; this.confirmPassword = ''; this.cedula = '';
          this.showSuccessModal();
        } else {
          const data = await response.json();

          if (data.errors && Array.isArray(data.errors)) {
            let erroresMapeados = false;
            data.errors.forEach(err => {
              const propiedad = err.propertyName ? err.propertyName.toLowerCase() : '';
              const mensaje = err.errorMessage;
              if (propiedad.includes('cedula')) this.cedulaError = mensaje, erroresMapeados = true;
              else if (propiedad.includes('firstname') || propiedad.includes('nombre')) this.firstNameError = mensaje, erroresMapeados = true;
              else if (propiedad.includes('lastname') || propiedad.includes('apellido')) this.lastNameError = mensaje, erroresMapeados = true;
              else if (propiedad.includes('email')) this.emailError = mensaje, erroresMapeados = true;
              else if (propiedad.includes('password')) this.passwordError = mensaje, erroresMapeados = true;
            });
            if (!erroresMapeados && data.errors.length > 0) {
              this.registerError = data.errors[0].errorMessage || "Error en la validación de datos.";
            }
          } else {
            this.registerError = data.detail || data.message || "Ocurrió un error al registrar.";
          }
        }
      } catch (error) {
        console.error('Error de registro:', error);
        this.registerError = 'No se pudo conectar con el servidor.';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
/* TUS ESTILOS QUEDAN 100% IGUALES */
.register-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-image: url('https://img.freepik.com/vector-gratis/fondo-minimalista-gradiente_23-2149976755.jpg');
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
.form-control-modern.is-invalid {
  border-color: #dc3545;
}
.invalid-feedback {
  display: block;
  width: 100%;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  color: #dc3545;
  text-align: left;
  font-weight: 500;
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
</style>