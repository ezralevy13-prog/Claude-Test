# NWS Bay Area Forecast App

A beautiful, Dark Sky-inspired web application that displays daily summaries and detailed forecasts from the National Weather Service Bay Area office.

![Dark Sky-inspired UI](https://img.shields.io/badge/Design-Dark%20Sky%20Inspired-blue)
![TypeScript](https://img.shields.io/badge/TypeScript-5.6-blue)
![React](https://img.shields.io/badge/React-18-blue)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-3.4-blue)

## Features

- 🌤️ **Daily Forecast Summaries** - Clean, readable summaries of NWS Bay Area forecast discussions
- 📖 **Detailed Discussions** - Full scientific forecast discussion with expandable sections
- 🎨 **Dark Sky-Inspired UI** - Beautiful gradient backgrounds, glass-morphism cards, and smooth animations
- 🔔 **Daily Notifications** - Optional browser notifications for morning forecast updates
- 📱 **Responsive Design** - Works seamlessly on desktop and mobile devices
- ⚡ **Real-time Updates** - Fetch the latest forecast discussions with one click
- 📋 **Copy & Share** - Easy copying of forecast text to clipboard

## Screenshots

### Summary View
The main view shows a clean summary of today's forecast discussion with key highlights.

### Detail View
Expandable sections showing the full scientific forecast discussion from NWS meteorologists.

## Tech Stack

- **Frontend Framework**: React 18 with TypeScript
- **Build Tool**: Vite 6
- **Styling**: Tailwind CSS 3.4
- **API**: National Weather Service API (api.weather.gov)
- **Notifications**: Web Notifications API

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd nws-forecast-app
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

4. Open your browser and navigate to:
```
http://localhost:5173
```

### Building for Production

```bash
npm run build
```

The built files will be in the `dist` directory, ready for deployment.

### Deployment

You can deploy this app to any static hosting service:

- **Vercel**: `vercel deploy`
- **Netlify**: `netlify deploy`
- **GitHub Pages**: See [Vite deployment guide](https://vitejs.dev/guide/static-deploy.html)

## Usage

### Viewing Forecast Summaries

1. The app loads the latest Bay Area forecast discussion automatically
2. Read the summary on the main page
3. Click "View Full Forecast Discussion" to see detailed sections

### Enabling Daily Notifications

1. Toggle the "Enable daily notifications" switch
2. Grant notification permissions when prompted
3. Receive daily forecast updates at 8 AM (customizable in code)

### Customizing Notification Time

Edit `/src/services/notifications.ts` and change:
```typescript
private static DEFAULT_NOTIFICATION_HOUR = 8; // Change to your preferred hour
```

## API Information

This app uses the free [National Weather Service API](https://www.weather.gov/documentation/services-web-api):

- **Endpoint**: `https://api.weather.gov/products/types/AFD/locations/MTR`
- **Office**: MTR (Monterey - covers Bay Area)
- **Product Type**: AFD (Area Forecast Discussion)
- **Rate Limit**: No API key required, reasonable usage expected
- **User-Agent**: Required header (already configured)

## Project Structure

```
nws-forecast-app/
├── src/
│   ├── components/
│   │   ├── ForecastSummary.tsx    # Main summary view
│   │   └── ForecastDetail.tsx     # Detailed discussion view
│   ├── services/
│   │   ├── nwsApi.ts              # NWS API service
│   │   └── notifications.ts       # Notification service
│   ├── App.tsx                    # Main app component
│   ├── index.css                  # Tailwind styles
│   └── main.tsx                   # App entry point
├── tailwind.config.js             # Tailwind configuration
├── vite.config.ts                 # Vite configuration
└── package.json                   # Dependencies
```

## Customization

### Colors

Edit `tailwind.config.js` to customize the color scheme:

```javascript
colors: {
  'dark-sky-bg': '#1a1a2e',      // Background gradient start
  'dark-sky-card': '#16213e',     // Card background
  'dark-sky-accent': '#0f3460',   // Accent color
  'dark-sky-text': '#e4e4e4',     // Text color
  'dark-sky-blue': '#5b8fb9',     // Primary blue
},
```

### Different NWS Office

To use a different NWS office, edit `/src/services/nwsApi.ts`:

```typescript
const BAY_AREA_OFFICE = 'MTR'; // Change to your office code
```

Find office codes at [NWS Office Locator](https://www.weather.gov/srh/nwsoffices).

## Features in Detail

### Dark Sky-Inspired Design

- **Gradient Backgrounds**: Smooth color transitions mimicking sky gradients
- **Glass-morphism Cards**: Semi-transparent cards with backdrop blur
- **Smooth Animations**: Subtle transitions and hover effects
- **Clean Typography**: Readable fonts with proper hierarchy
- **Responsive Layout**: Mobile-first design approach

### Forecast Parsing

The app intelligently parses NWS forecast text into sections:
- Automatically detects section headers
- Formats long text for readability
- Extracts key summary information
- Handles various forecast formats

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

**Note**: Notifications require HTTPS in production (works on localhost for development).

## Troubleshooting

### Notifications not working?

1. Check browser permissions for notifications
2. Ensure you're using HTTPS (required in production)
3. Clear browser cache and localStorage

### API errors?

1. Check your internet connection
2. Verify the NWS API is operational: https://api.weather.gov/
3. Check browser console for detailed error messages

### Build errors?

```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is open source and available under the MIT License.

## Acknowledgments

- **National Weather Service** for providing free, comprehensive weather data
- **Dark Sky** (RIP) for design inspiration
- **NWS Meteorologists** at MTR for their detailed forecast discussions

## Resources

- [NWS API Documentation](https://www.weather.gov/documentation/services-web-api)
- [NWS Bay Area Office](https://www.weather.gov/mtr/)
- [Vite Documentation](https://vitejs.dev/)
- [React Documentation](https://react.dev/)
- [Tailwind CSS Documentation](https://tailwindcss.com/)

---

**Made with ☁️ for weather enthusiasts**
