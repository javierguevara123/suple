<template>
  <div class="admin-page">
    <header class="header-bar">
      <div class="header-content">
        <div class="logo-section">
          <div class="logo-icon">
            <i class="bi bi-shield-fill-check"></i>
          </div>
          <div class="logo-text">
            <div class="brand-name">NorthWind</div>
            <div class="brand-subtitle">Admin Panel</div>
          </div>
        </div>
        
        <div class="user-section">
          <div class="profile-access" @click="goTo('/perfil')" title="Ir a mi perfil">
            <div class="user-info-header">
              <div class="user-name">{{ fullName || 'Administrador' }}</div>
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
            Panel de <span class="highlight">Administración</span>
          </h1>
          <p class="welcome-subtitle">
            Gestión completa del sistema, usuarios y recursos
          </p>
        </div>

        <div class="cards-grid">
          <div
            v-for="card in adminCards"
            :key="card.title"
            class="admin-card"
            :class="card.colorClass"
            @click="goTo(card.route)"
          >
            <div class="card-header-section">
              <div class="card-icon-wrapper">
                <i :class="card.icon" class="card-icon"></i>
              </div>
              <div class="card-badge">{{ card.badge }}</div>
            </div>
            <h3 class="card-title">{{ card.title }}</h3>
            <p class="card-description">{{ card.description }}</p>
            <div class="card-footer-action">
              <span class="action-text">Gestionar</span>
              <i class="bi bi-arrow-right action-arrow"></i>
            </div>
          </div>
        </div>

        <div class="quick-access-section">
          <h2 class="section-title">Información del Sistema</h2>
          <div class="quick-access-grid">
            
            <div class="quick-card">
              <div class="quick-icon bg-blue-soft">
                <i class="bi bi-clock-history text-blue"></i>
              </div>
              <div class="quick-content">
                <div class="quick-label">Última sesión</div>
                <div class="quick-value">{{ currentDate }}</div>
              </div>
            </div>

            <div class="quick-card">
              <div class="quick-icon bg-green-soft">
                <i class="bi bi-shield-check text-green"></i>
              </div>
              <div class="quick-content">
                <div class="quick-label">Estado del sistema</div>
                <div class="quick-value">Operativo</div>
              </div>
            </div>

            <div class="quick-card">
              <div class="quick-icon bg-purple-soft">
                <i class="bi bi-server text-purple"></i>
              </div>
              <div class="quick-content">
                <div class="quick-label">Servidor</div>
                <div class="quick-value">Online</div>
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
  name: "MenuAdmin",
  data() {
    return {
      userEmail: localStorage.getItem("email") || "",
      fullName: localStorage.getItem("fullName") || "",
      userRole: localStorage.getItem("role") || "Administrator",
      currentDate: new Date().toLocaleDateString('es-ES', { 
        day: '2-digit', 
        month: 'long', 
        year: 'numeric' 
      }),
      adminCards: [
        {
          title: "Usuarios",
          description: "Gestión completa de usuarios del sistema",
          icon: "bi bi-people-fill",
          route: "/gestionUsuarios",
          colorClass: "card-purple",
          badge: "Admin"
        },
        {
          title: "Clientes",
          description: "Administración de base de clientes",
          icon: "bi bi-person-lines-fill",
          route: "/gestionClientes",
          colorClass: "card-blue",
          badge: "CRM"
        },
        {
          title: "Productos",
          description: "Control de inventario y catálogo",
          icon: "bi bi-bag-check-fill",
          route: "/productos",
          colorClass: "card-orange",
          badge: "Stock"
        },
        {
          title: "Reportes",
          description: "Análisis de métricas y estadísticas",
          icon: "bi bi-bar-chart-line-fill",
          route: "/reporteErrores",
          colorClass: "card-green",
          badge: "Analytics"
        },
        {
          title: "Desbloqueo",
          description: "Gestión de cuentas bloqueadas",
          icon: "bi bi-unlock-fill",
          route: "/desbloquearCuentas",
          colorClass: "card-cyan",
          badge: "Security"
        },
      ],
    };
  },
  mounted() {
    const token = localStorage.getItem("token");
    const role = localStorage.getItem("role");
    
    if (!token || (role !== "SuperUser" && role !== "Administrator")) {
      this.$router.push("/login");
    }
  },
  methods: {
    logout() {
      localStorage.clear();
      this.$router.push("/login");
    },
    goTo(route) {
      this.$router.push(route);
    },
  },
};
</script>

<style scoped>
.admin-page {
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

.admin-page::before {
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
  padding: 0.8rem 2rem;
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

/* NUEVO: Estilos para el perfil clickeable en el header */
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

/* Divisor vertical entre perfil y logout */
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
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.admin-card {
  background: white;
  border-radius: 18px;
  padding: 1.75rem;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
}

.admin-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: currentColor;
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

.admin-card:hover::before {
  transform: scaleX(1);
}

.admin-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
}

.card-purple { color: #9333ea; }
.card-blue { color: #3b82f6; }
.card-orange { color: #f59e0b; }
.card-green { color: #10b981; }
.card-cyan { color: #06b6d4; }
.card-pink { color: #ec4899; }

.card-header-section {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.card-icon-wrapper {
  width: 60px;
  height: 60px;
  border-radius: 14px;
  background: rgba(102, 126, 234, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
}

.card-icon {
  font-size: 1.6rem;
  color: currentColor;
}

.card-badge {
  background: currentColor;
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.card-title {
  font-size: 1.35rem;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 0.5rem;
}

.card-description {
  color: #718096;
  font-size: 0.9rem;
  line-height: 1.5;
  margin-bottom: 1.25rem;
}

.card-footer-action {
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: currentColor;
  font-weight: 600;
  font-size: 0.9rem;
}

.action-arrow {
  transition: transform 0.3s ease;
}

.admin-card:hover .action-arrow {
  transform: translateX(5px);
}

/* Quick Access Section */
.quick-access-section {
  margin-top: 2rem;
}

.section-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: white;
  margin-bottom: 1.5rem;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.quick-access-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); /* Responsive */
  gap: 1.5rem;
}

.quick-card {
  background: rgba(255, 255, 255, 0.97);
  border-radius: 14px;
  padding: 1.25rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  text-decoration: none;
  color: inherit;
}

.quick-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.12);
}

.quick-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
  flex-shrink: 0;
}

.bg-purple-soft { background: rgba(147, 51, 234, 0.12); }
.bg-blue-soft { background: rgba(59, 130, 246, 0.12); }
.bg-green-soft { background: rgba(16, 185, 129, 0.12); }

.text-purple { color: #9333ea; }
.text-blue { color: #3b82f6; }
.text-green { color: #10b981; }

.quick-content {
  flex: 1;
  text-align: left;
}

.quick-label {
  font-size: 0.8rem;
  color: #718096;
  margin-bottom: 0.25rem;
  font-weight: 500;
}

.quick-value {
  font-size: 0.95rem;
  color: #2d3748;
  font-weight: 700;
}
</style>