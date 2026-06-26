import { createRouter, createWebHistory } from 'vue-router'
import ColorToolPage from '../views/color/ColorToolPage.vue'
import OffworkCountdownPage from '../views/countdown/OffworkCountdownPage.vue'
import FrontendProcessToolPage from '../views/frontend/FrontendProcessToolPage.vue'
import HomePage from '../views/HomePage.vue'
import JsonToolPage from '../views/json/JsonToolPage.vue'
import QrCodeToolPage from '../views/qrcode/QrCodeToolPage.vue'
import ResumeWorkbench from '../views/resume/ResumeWorkbench.vue'
import TimeToolPage from '../views/time/TimeToolPage.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomePage
    },
    {
      path: '/workbench',
      name: 'workbench',
      component: ResumeWorkbench
    },
    {
      path: '/json',
      name: 'json',
      component: JsonToolPage
    },
    {
      path: '/time',
      name: 'time',
      component: TimeToolPage
    },
    {
      path: '/offwork',
      name: 'offwork',
      component: OffworkCountdownPage
    },
    {
      path: '/color',
      name: 'color',
      component: ColorToolPage
    },
    {
      path: '/qrcode',
      name: 'qrcode',
      component: QrCodeToolPage
    },
    {
      path: '/frontend-tools',
      name: 'frontend-tools',
      component: FrontendProcessToolPage
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/'
    }
  ]
})

export default router
