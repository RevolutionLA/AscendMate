import DefaultTheme from 'vitepress/theme'
import HomeOverview from './components/HomeOverview.vue'
import './styles/ascendmate.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('HomeOverview', HomeOverview)
  },
}
