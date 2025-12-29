/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'dark-sky-bg': '#1a1a2e',
        'dark-sky-card': '#16213e',
        'dark-sky-accent': '#0f3460',
        'dark-sky-text': '#e4e4e4',
        'dark-sky-blue': '#5b8fb9',
      },
      fontFamily: {
        'sans': ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
