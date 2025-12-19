<template>
  <div class="performance-page">
    <div class="background-overlay"></div>

    <header class="header-bar">
      <div class="header-content">
        <div class="logo-section">
          <router-link to="/menuPrincipal" class="btn-back">
            <i class="bi bi-arrow-left"></i>
          </router-link>
          <div class="logo-text">
            <div class="brand-name">Rendimiento</div>
            <div class="brand-subtitle">Benchmark System</div>
          </div>
        </div>
        
        <div class="user-badge d-none d-md-flex">
          <i class="bi bi-speedometer2 me-2"></i>
          <span>Modo Pruebas</span>
        </div>
      </div>
    </header>

    <main class="main-content">
      <div class="content-wrapper">
        
        <div class="d-flex justify-content-center align-items-center h-100 mt-4">
          <div class="card glass-card fade-in-up">
            <div class="card-body p-5">
              
              <div class="text-center mb-4">
                <div class="icon-circle mb-3 mx-auto">
                  <i class="bi bi-cpu-fill text-white" style="font-size: 1.8rem;"></i>
                </div>
                <h3 class="fw-bold text-dark">Prueba de Carga</h3>
                <p class="text-muted small">Mide la latencia de tu Backend en tiempo real</p>
              </div>
              
              <form @submit.prevent="runTest">
                <div class="mb-4">
                  <label class="form-label fw-bold small text-uppercase text-secondary tracking-wide">Operación</label>
                  <div class="operation-selector">
                    <div 
                      class="op-option" 
                      :class="{ active: form.type === 'insert' }"
                      @click="form.type = 'insert'"
                    >
                      <i class="bi bi-database-add mb-1"></i>
                      <span>INSERT</span>
                    </div>
                    <div 
                      class="op-option" 
                      :class="{ active: form.type === 'select' }"
                      @click="form.type = 'select'"
                    >
                      <i class="bi bi-search mb-1"></i>
                      <span>SELECT</span>
                    </div>
                  </div>
                </div>

                <div class="mb-4">
                  <label class="form-label fw-bold small text-uppercase text-secondary tracking-wide">
                    Cantidad <span class="fw-normal text-muted">({{ form.quantity }} regs)</span>
                  </label>
                  <input 
                    type="range" 
                    class="form-range custom-range" 
                    min="10" 
                    max="1000" 
                    step="10" 
                    v-model.number="form.quantity"
                  >
                  <div class="d-flex justify-content-between small text-muted mt-1">
                    <span>10</span>
                    <span>500</span>
                    <span>1000</span>
                  </div>
                  <div class="form-text text-center mt-2" v-if="form.type === 'select'">
                    <i class="bi bi-info-circle me-1"></i> Limitado a 100/página por backend
                  </div>
                </div>

                <button 
                  type="submit" 
                  class="btn btn-action w-100 py-3" 
                  :disabled="loading"
                >
                  <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                  {{ loading ? 'Ejecutando...' : 'Iniciar Diagnóstico' }}
                </button>
              </form>

              <div v-if="result" class="result-box mt-4 animate-pop-in">
                <div class="row text-center">
                  <div class="col-6 border-end">
                    <div class="label">Tiempo</div>
                    <div class="value text-primary">{{ result.elapsedMilliseconds }}<small>ms</small></div>
                  </div>
                  <div class="col-6">
                    <div class="label">Registros</div>
                    <div class="value text-dark">{{ result.quantity }}</div>
                  </div>
                </div>
                <div class="result-message mt-3">
                  <i class="bi bi-check-circle-fill me-2"></i>
                  {{ result.message }}
                </div>
              </div>

              <div v-if="error" class="alert alert-danger mt-4 small text-center shadow-sm border-0">
                <i class="bi bi-exclamation-octagon-fill me-2"></i>{{ error }}
              </div>

            </div>
          </div>
        </div>

      </div>
    </main>
  </div>
</template>

<script>
export default {
  name: "PerformanceTest",
  data() {
    return {
      form: { type: 'select', quantity: 50 },
      loading: false,
      result: null,
      error: null
    };
  },
  methods: {
    async runTest() {
      this.loading = true;
      this.result = null;
      this.error = null;
      
      const endpoint = this.form.type === 'insert' 
        ? '/api/performance/products/insert' 
        : '/api/performance/products/select';

      try {
        const token = localStorage.getItem('token');
        const response = await fetch(`https://localhost:7176${endpoint}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({ quantity: this.form.quantity })
        });

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          throw new Error(errorData.title || "Error en la solicitud al servidor");
        }
        this.result = await response.json();
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
/* =========================================
   ESTRUCTURA GENERAL (Full Screen)
   ========================================= */
.performance-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); /* Mismo gradiente que MenuAdmin */
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow-y: auto;
}

.background-overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: url('data:image/svg+xml,<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="grid" width="100" height="100" patternUnits="userSpaceOnUse"><path d="M 100 0 L 0 0 0 100" fill="none" stroke="rgba(255,255,255,0.05)" stroke-width="1"/></pattern></defs><rect width="100" height="100" fill="url(%23grid)"/></svg>');
  opacity: 0.3;
  pointer-events: none;
}

/* Header */
.header-bar {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(12px);
  padding: 1rem 2rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.btn-back {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #4c6ef5 0%, #3b5bdb 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  text-decoration: none;
  font-size: 1.2rem;
  box-shadow: 0 4px 10px rgba(76, 110, 245, 0.3);
  transition: transform 0.2s;
}

.btn-back:hover {
  transform: translateX(-3px);
}

.logo-text {
  line-height: 1.2;
}

.brand-name {
  font-size: 1.1rem;
  font-weight: 800;
  color: #2d3748;
}

.brand-subtitle {
  font-size: 0.75rem;
  color: #718096;
  font-weight: 500;
}

.user-badge {
  background: rgba(76, 110, 245, 0.1);
  color: #4c6ef5;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.85rem;
  align-items: center;
}

/* Main Layout */
.main-content {
  position: relative;
  z-index: 1;
  padding: 2rem;
  min-height: calc(100vh - 80px);
}

.content-wrapper {
  max-width: 1200px;
  margin: 0 auto;
  height: 100%;
}

/* =========================================
   TARJETA Y COMPONENTES
   ========================================= */
.glass-card {
  width: 100%;
  max-width: 480px;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 24px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  backdrop-filter: blur(10px);
}

.icon-circle {
  width: 70px;
  height: 70px;
  background: linear-gradient(135deg, #ec4899 0%, #be185d 100%); /* Rosa fuerte para Performance */
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 6px 15px rgba(236, 72, 153, 0.3);
}

/* Selector de Operación */
.operation-selector {
  display: flex;
  gap: 1rem;
  background: #f1f5f9;
  padding: 0.5rem;
  border-radius: 16px;
}

.op-option {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #64748b;
  font-weight: 600;
  font-size: 0.9rem;
}

.op-option i {
  font-size: 1.4rem;
  margin-bottom: 0.25rem;
}

.op-option:hover {
  background: rgba(255, 255, 255, 0.5);
}

.op-option.active {
  background: white;
  color: #ec4899; /* Rosa activo */
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

/* Botón de Acción */
.btn-action {
  background: linear-gradient(135deg, #ec4899 0%, #be185d 100%);
  border: none;
  border-radius: 12px;
  color: white;
  font-weight: 700;
  font-size: 1rem;
  letter-spacing: 0.5px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(236, 72, 153, 0.3);
}

.btn-action:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(236, 72, 153, 0.4);
}

.btn-action:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

/* Resultados */
.result-box {
  background: #f8fafc;
  border-radius: 16px;
  padding: 1.5rem;
  border: 1px solid #e2e8f0;
}

.result-box .label {
  font-size: 0.75rem;
  text-transform: uppercase;
  color: #64748b;
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.result-box .value {
  font-size: 1.8rem;
  font-weight: 800;
  line-height: 1;
}

.result-message {
  font-size: 0.9rem;
  color: #10b981;
  font-weight: 600;
  text-align: center;
  padding-top: 0.5rem;
  border-top: 1px solid #e2e8f0;
}

/* Animaciones */
.fade-in-up {
  animation: fadeInUp 0.6s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-pop-in {
  animation: popIn 0.4s ease-out;
}

@keyframes popIn {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}

.tracking-wide {
  letter-spacing: 0.5px;
}
</style>