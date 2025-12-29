import { useState } from 'react';
import { ForecastSummary } from './components/ForecastSummary';
import { ForecastDetail } from './components/ForecastDetail';
import type { NWSProduct } from './services/nwsApi';

type View = 'summary' | 'detail';

function App() {
  const [currentView, setCurrentView] = useState<View>('summary');
  const [selectedProduct, setSelectedProduct] = useState<NWSProduct | null>(null);

  const handleViewDetails = (product: NWSProduct) => {
    setSelectedProduct(product);
    setCurrentView('detail');
  };

  const handleBackToSummary = () => {
    setCurrentView('summary');
    setSelectedProduct(null);
  };

  return (
    <div className="min-h-screen p-4 sm:p-8">
      <div className="container mx-auto">
        {/* App Header */}
        <header className="text-center mb-8">
          <div className="inline-flex items-center space-x-3 mb-2">
            <svg className="w-10 h-10 text-dark-sky-blue" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z" />
            </svg>
            <h1 className="text-4xl font-bold text-white">
              Bay Area Weather
            </h1>
          </div>
          <p className="text-dark-sky-text/70">
            National Weather Service Forecast Discussions
          </p>
        </header>

        {/* Main Content */}
        <main>
          {currentView === 'summary' ? (
            <ForecastSummary onViewDetails={handleViewDetails} />
          ) : (
            selectedProduct && (
              <ForecastDetail
                product={selectedProduct}
                onBack={handleBackToSummary}
              />
            )
          )}
        </main>

        {/* Footer */}
        <footer className="mt-12 text-center text-dark-sky-text/50 text-sm">
          <p>
            Data provided by the{' '}
            <a
              href="https://www.weather.gov/mtr/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-dark-sky-blue hover:text-dark-sky-blue/80 transition-colors"
            >
              National Weather Service
            </a>
          </p>
          <p className="mt-2">
            Bay Area Forecast Office (MTR) - Monterey, CA
          </p>
        </footer>
      </div>
    </div>
  );
}

export default App;
