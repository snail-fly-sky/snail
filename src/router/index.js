import { createRouter, createWebHashHistory } from 'vue-router'
import ColorToolPage from '../views/color/ColorToolPage.vue'
import OffworkCountdownPage from '../views/countdown/OffworkCountdownPage.vue'
import FrontendProcessToolPage from '../views/frontend/FrontendProcessToolPage.vue'
import HomePage from '../views/HomePage.vue'
import JsonToolPage from '../views/json/JsonToolPage.vue'
import QrCodeToolPage from '../views/qrcode/QrCodeToolPage.vue'
import ResumeWorkbench from '../views/resume/ResumeWorkbench.vue'
import TimeToolPage from '../views/time/TimeToolPage.vue'

const router = createRouter({
  history: createWebHashHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'HomePage',
      component: HomePage
    },
    {
      path: '/ResumeWorkbench',
      name: 'ResumeWorkbench',
      component: ResumeWorkbench
    },
    {
      path: '/JsonToolPage',
      name: 'JsonToolPage',
      component: JsonToolPage
    },
    {
      path: '/TimeToolPage',
      name: 'TimeToolPage',
      component: TimeToolPage
    },
    {
      path: '/OffworkCountdownPage',
      name: 'OffworkCountdownPage',
      component: OffworkCountdownPage
    },
    {
      path: '/ColorToolPage',
      name: 'ColorToolPage',
      component: ColorToolPage
    },
    {
      path: '/QrCodeToolPage',
      name: 'QrCodeToolPage',
      component: QrCodeToolPage
    },
    {
      path: '/FrontendProcessToolPage',
      name: 'FrontendProcessToolPage',
      component: FrontendProcessToolPage
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/'
    }
  ]
})

export default router
