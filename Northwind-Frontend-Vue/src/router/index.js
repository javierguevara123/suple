import { createRouter, createWebHistory } from "vue-router";
import LoginForm from "../components/LoginForm.vue";
import RegisterForm from "../components/RegisterForm.vue";
import MenuPrincipal from "../components/MenuPrincipal.vue";
import MenuAdmin from "../components/MenuAdmin.vue";
import GestionUsuarios from "../components/GestionUsuarios.vue";
import GestionProductos from "../components/GestionProductos.vue";
import OrderForm from "../components/OrderForm.vue";
import GestionClientes from "../components/GestionClientes.vue";
import DesbloquearCuentas from "../components/DesbloquearCuentas.vue";
import ReporteErrores from "../components/ReporteErrores.vue";
import PerfilUsuario from "../components/PerfilUsuario.vue";
import ListadoFacturas from "../components/ListadoFacturas.vue";
import SelectProductos from "@/components/SelectProductos.vue";
import SelectClientes from "@/components/SelectClientes.vue";
import PrintInvoice from "@/components/PrintInvoice.vue";
import PerformanceTest from "@/components/PerformanceTest.vue";

const routes = [
  { path: "/", redirect: "/login" },
  { path: "/login", component: LoginForm },
  { path: "/register", component: RegisterForm },
  { path: "/menuPrincipal", component: MenuPrincipal },
  { path: "/menuAdmin", component: MenuAdmin },
  { path: "/gestionUsuarios", component: GestionUsuarios },
  { path: "/productos", component: GestionProductos },
  { path: "/order", component: OrderForm },
  { path: "/gestionClientes", component: GestionClientes },
  { path: "/desbloquearCuentas", component: DesbloquearCuentas },
  { path: "/reporteErrores", component: ReporteErrores },
  { path: "/perfil", component: PerfilUsuario },
  { path: "/facturas", component: ListadoFacturas },
  { path: "/selectProductos", component: SelectProductos },
  { path: "/selectClientes", component: SelectClientes },
  { 
    path: "/printInvoice/:id", 
    name: "PrintInvoice",       
    component: PrintInvoice,
    props: true                 
  },
  {
    path: '/performance',
    name: 'Performance',
    component: PerformanceTest
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// --- PROTECCIÓN DE RUTAS (Navigation Guard) ---
router.beforeEach((to, from, next) => {
  // 1. Definir páginas públicas (que no requieren token)
  const publicPages = ['/login', '/register'];
  
  // 2. Verificar si la ruta a la que va el usuario requiere autenticación
  const authRequired = !publicPages.includes(to.path);
  
  // 3. Verificar si existe el token en el almacenamiento local
  const loggedIn = localStorage.getItem('token');

  // CASO A: Intenta entrar a ruta protegida sin token -> Redirigir a Login
  if (authRequired && !loggedIn) {
    return next('/login');
  }

  // CASO B: Ya tiene token e intenta ir al Login -> Redirigir al Menú correspondiente
  if (loggedIn && (to.path === '/login' || to.path === '/')) {
     const role = localStorage.getItem('role');
     if (role === 'Administrator' || role === 'SuperUser') {
         return next('/menuAdmin');
     } else {
         return next('/menuPrincipal');
     }
  }

  // CASO C: Todo correcto -> Dejar pasar
  next();
});

export default router;