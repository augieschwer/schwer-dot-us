import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Schwer.us",
  description: "Schwer, like where?",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/augieschwer' },
      { icon: 'linkedin', link: 'https://www.linkedin.com/in/augustschwer/' }
    ]
  }
})
