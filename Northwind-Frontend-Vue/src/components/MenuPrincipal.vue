<template>
  <div class="menu-page">
    <header class="header-bar">
      <div class="header-content">
        <div class="logo-section">
          <div class="logo-icon">
            <i class="bi bi-briefcase-fill"></i>
          </div>
          <div class="logo-text">
            <div class="brand-name">NorthWind</div>
            <div class="brand-subtitle">Sales Portal</div>
          </div>
        </div>
        
        <div class="user-section">
          <div class="profile-access" @click="goTo('/perfil')" title="Ir a mi perfil">
            <div class="user-info-header">
              <div class="user-name">{{ fullName || 'Usuario' }}</div>
              <div class="user-role">{{ userRole }}</div>
            </div>
            <div class="avatar-wrapper">
              <img
                :src="`https://i.pravatar.cc/48?u=${userEmail}`"
                alt="Avatar"
                class="avatar"
              />
              <span class="status-indicator"></span>
            </div>
          </div>

          <div class="vertical-divider"></div>

          <button class="btn-logout" @click="logout">
            <i class="bi bi-box-arrow-right"></i>
            <span>Salir</span>
          </button>
        </div>
      </div>
    </header>

    <main class="main-content">
      <div class="content-wrapper">
        <div class="welcome-section">
          <h1 class="welcome-title">
            Bienvenido, <span class="highlight">{{ firstName }}</span>
          </h1>
          <p class="welcome-subtitle">
            Panel de control para gestión de productos, clientes y ventas
          </p>
        </div>

        <div class="cards-grid">
          
          <router-link to="/selectProductos" class="nav-card">
            <div class="card-icon-wrapper bg-primary-soft">
              <i class="bi bi-box-seam card-icon text-primary"></i>
            </div>
            <h3 class="card-title">Productos</h3>
            <p class="card-description">
              Explora y gestiona el catálogo completo de productos disponibles
            </p>
            <div class="card-footer-action">
              <span class="action-text">Ver productos</span>
              <i class="bi bi-arrow-right action-arrow"></i>
            </div>
          </router-link>

          <router-link to="/selectClientes" class="nav-card">
            <div class="card-icon-wrapper bg-warning-soft">
              <i class="bi bi-people-fill card-icon text-warning"></i>
            </div>
            <h3 class="card-title">Clientes</h3>
            <p class="card-description">
              Administra la cartera de clientes, saldos y datos de contacto
            </p>
            <div class="card-footer-action">
              <span class="action-text">Gestionar clientes</span>
              <i class="bi bi-arrow-right action-arrow"></i>
            </div>
          </router-link>

          <router-link to="/facturas" class="nav-card">
            <div class="card-icon-wrapper bg-info-soft">
              <i class="bi bi-receipt card-icon text-info"></i>
            </div>
            <h3 class="card-title">Facturas</h3>
            <p class="card-description">
              Consulta el historial completo de facturas y transacciones
            </p>
            <div class="card-footer-action">
              <span class="action-text">Ver facturas</span>
              <i class="bi bi-arrow-right action-arrow"></i>
            </div>
          </router-link>

          <router-link to="/order" class="nav-card">
            <div class="card-icon-wrapper bg-success-soft">
              <i class="bi bi-cart-plus card-icon text-success"></i>
            </div>
            <h3 class="card-title">Nueva Venta</h3>
            <p class="card-description">
              Crea y procesa nuevas órdenes de venta y facturación
            </p>
            <div class="card-footer-action">
              <span class="action-text">Iniciar venta</span>
              <i class="bi bi-arrow-right action-arrow"></i>
            </div>
          </router-link>

        </div>

        <div class="stats-section">
          <div class="stat-card">
            <div class="stat-icon bg-primary-soft">
              <i class="bi bi-graph-up text-primary"></i>
            </div>
            <div class="stat-content">
              <div class="stat-label">Estado</div>
              <div class="stat-value">Conectado</div>
            </div>
          </div>
          
          <div class="stat-card">
            <div class="stat-icon bg-warning-soft">
              <i class="bi bi-clock-history text-warning"></i>
            </div>
            <div class="stat-content">
              <div class="stat-label">Última sesión</div>
              <div class="stat-value">{{ currentDate }}</div>
            </div>
          </div>
          
          <div class="stat-card">
             <div class="stat-icon bg-info-soft">
               <i class="bi bi-shield-check text-info"></i>
             </div>
             <div class="stat-content">
               <div class="stat-label">Sistema</div>
               <div class="stat-value">Operativo</div>
             </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
export default {
  name: "MenuPrincipal",
  data() {
    return {
      userEmail: localStorage.getItem("email") || "",
      fullName: localStorage.getItem("fullName") || "",
      userRole: localStorage.getItem("role") || "Employee",
      currentDate: new Date().toLocaleDateString('es-ES', { 
        day: '2-digit', 
        month: 'long', 
        year: 'numeric' 
      })
    };
  },
  computed: {
    firstName() {
      return this.fullName.split(' ')[0] || 'Usuario';
    }
  },
  mounted() {
    const token = localStorage.getItem("token");
    
    // Validación básica de rol
    if (!token) {
      this.$router.push("/login");
    }
  },
  methods: {
    logout() {
      localStorage.clear();
      this.$router.push("/login");
    },
    // Método nuevo para la navegación
    goTo(route) {
      this.$router.push(route);
    }
  },
};
</script>

<style scoped>
/* Estilos Base */
.menu-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow-y: auto;
  text-align: left;
}

.menu-page::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="grid" width="100" height="100" patternUnits="userSpaceOnUse"><path d="M 100 0 L 0 0 0 100" fill="none" stroke="rgba(255,255,255,0.05)" stroke-width="1"/></pattern></defs><rect width="100" height="100" fill="url(%23grid)"/></svg>');
  opacity: 0.3;
}

/* Header */
.header-bar {
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(10px);
  padding: 0.8rem 2rem; /* Ajustado padding */
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 1000;
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
  gap: 0.75rem;
}

.logo-icon {
  width: 45px;
  height: 45px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.3rem;
  color: white;
  box-shadow: 0 3px 10px rgba(102, 126, 234, 0.3);
}

.logo-text {
  display: flex;
  flex-direction: column;
}

.brand-name {
  font-size: 1.2rem;
  font-weight: 700;
  color: #2d3748;
  line-height: 1.2;
}

.brand-subtitle {
  font-size: 0.75rem;
  color: #718096;
  font-weight: 500;
}

.user-section {
  display: flex;
  align-items: center;
  gap: 1rem;
}

/* NUEVO: Estilos para el perfil clickeable */
.profile-access {
  display: flex;
  align-items: center;
  gap: 1rem;
  cursor: pointer;
  padding: 0.5rem 1rem;
  border-radius: 12px;
  transition: background-color 0.2s ease;
}

.profile-access:hover {
  background-color: #f7fafc;
}

/* NUEVO: Divisor vertical */
.vertical-divider {
  width: 1px;
  height: 30px;
  background-color: #e2e8f0;
  margin: 0 0.5rem;
}

.user-info-header {
  text-align: right;
}

.user-name {
  font-weight: 600;
  color: #2d3748;
  font-size: 0.9rem;
}

.user-role {
  font-size: 0.75rem;
  color: #718096;
  font-weight: 500;
}

.avatar-wrapper {
  position: relative;
}

.avatar {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #667eea;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease;
}

.profile-access:hover .avatar {
  transform: scale(1.05);
  border-color: #764ba2;
}

.status-indicator {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 12px;
  height: 12px;
  background: #48bb78;
  border: 2px solid white;
  border-radius: 50%;
}

.btn-logout {
  background: linear-gradient(135deg, #f56565 0%, #c53030 100%);
  color: white;
  border: none;
  padding: 0.5rem 1.2rem;
  border-radius: 10px;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(245, 101, 101, 0.3);
}

.btn-logout:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(245, 101, 101, 0.4);
}

/* Main Content */
.main-content {
  position: relative;
  z-index: 1;
  padding: 3rem 2rem;
}

.content-wrapper {
  max-width: 1200px;
  margin: 0 auto;
}

.welcome-section {
  text-align: center;
  margin-bottom: 3rem;
}

.welcome-title {
  font-size: 2.2rem;
  font-weight: 800;
  color: white;
  margin-bottom: 0.75rem;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}

.highlight {
  background: linear-gradient(120deg, #ffd89b 0%, #19547b 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.welcome-subtitle {
  font-size: 1rem;
  color: rgba(255, 255, 255, 0.95);
  font-weight: 400;
}

/* Cards Grid */
.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.nav-card {
  background: white;
  border-radius: 18px;
  padding: 1.75rem;
  display: block;
  text-decoration: none;
  color: inherit;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
}

.nav-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

.nav-card:hover::before {
  transform: scaleX(1);
}

.nav-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
}

.card-icon-wrapper {
  width: 65px;
  height: 65px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.25rem;
}

.bg-primary-soft { background: rgba(102, 126, 234, 0.12); }
.bg-info-soft { background: rgba(56, 189, 248, 0.12); }
.bg-success-soft { background: rgba(34, 197, 94, 0.12); }
.bg-warning-soft { background: rgba(251, 191, 36, 0.12); }

.card-icon { font-size: 1.8rem; }

.text-primary { color: #667eea !important; }
.text-info { color: #38bdf8 !important; }
.text-success { color: #22c55e !important; }
.text-warning { color: #fbbf24 !important; }

.card-title {
  font-size: 1.35rem;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 0.75rem;
}

.card-description {
  color: #718096;
  font-size: 0.9rem;
  line-height: 1.6;
  margin-bottom: 1.25rem;
}

.card-footer-action {
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: #667eea;
  font-weight: 600;
  font-size: 0.9rem;
}

.action-arrow {
  transition: transform 0.3s ease;
}

.nav-card:hover .action-arrow {
  transform: translateX(5px);
}

/* Stats Section */
.stats-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  background: rgba(255, 255, 255, 0.97);
  border-radius: 14px;
  padding: 1.25rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.12);
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
  flex-shrink: 0;
}

.stat-content {
  flex: 1;
  text-align: left;
}

.stat-label {
  font-size: 0.8rem;
  color: #718096;
  margin-bottom: 0.25rem;
  font-weight: 500;
}

.stat-value {
  font-size: 0.95rem;
  color: #2d3748;
  font-weight: 700;
}
</style>