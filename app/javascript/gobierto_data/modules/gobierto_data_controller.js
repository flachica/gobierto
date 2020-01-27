import Vue from "vue";
import VueRouter from "vue-router";
import VueCodemirror from 'vue-codemirror'
import 'codemirror/lib/codemirror.css'

Vue.use(VueRouter);
Vue.use(VueCodemirror);
Vue.config.productionTip = false;

export class GobiertoDataController {
  constructor(options) {
    const selector = "gobierto-datos-app";

    // Mount Vue application
    const entryPoint = document.getElementById(selector);
    if (entryPoint) {
      const htmlRouterBlock = `
        <keep-alive>
          <transition name="fade" mode="out-in">
            <router-view :key="$route.fullPath"></router-view>
          </transition>
        </keep-alive>
      `;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () => import("../webapp/pages/Home.vue");
      const Sets = () => import("../webapp/pages/Sets.vue");


      const router = new VueRouter({
        mode: "history",
        routes: [{
            path: "/datos",
            name: "home", component: Home
          },
          {
            path: "/datos/:id",
            name: "dataset",
            component: Sets
          }
        ]
      })

      new Vue({
        router,
        data: options,
      }).$mount(entryPoint);
    }
  }
}
