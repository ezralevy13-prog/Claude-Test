import { useState, useEffect } from 'react';
import { nwsApi } from '../services/nwsApi';
import type { NWSProduct, NWSProductDetail } from '../services/nwsApi';
import { NotificationService } from '../services/notifications';

interface ForecastSummaryProps {
  onViewDetails: (product: NWSProduct) => void;
}

export const ForecastSummary = ({ onViewDetails }: ForecastSummaryProps) => {
  const [latestForecast, setLatestForecast] = useState<NWSProduct | null>(null);
  const [forecastDetail, setForecastDetail] = useState<NWSProductDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadLatestForecast();
  }, []);

  const loadLatestForecast = async () => {
    try {
      setLoading(true);
      setError(null);

      const forecasts = await nwsApi.getLatestForecastDiscussions(1);
      if (forecasts.length > 0) {
        const latest = forecasts[0];
        setLatestForecast(latest);

        const detail = await nwsApi.getForecastDiscussion(latest.id);
        setForecastDetail(detail);
      }
    } catch (err) {
      setError('Failed to load forecast. Please try again later.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="glass-card p-8 max-w-4xl mx-auto">
        <div className="flex items-center justify-center space-x-3">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-white"></div>
          <span className="text-white/80">Loading forecast...</span>
        </div>
      </div>
    );
  }

  if (error || !latestForecast || !forecastDetail) {
    return (
      <div className="glass-card p-8 max-w-4xl mx-auto">
        <div className="text-center">
          <p className="text-red-400 mb-4">{error || 'No forecast available'}</p>
          <button
            onClick={loadLatestForecast}
            className="px-6 py-2 bg-dark-sky-blue hover:bg-dark-sky-blue/80 rounded-lg transition-colors"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  const summary = nwsApi.extractSummary(forecastDetail.productText);
  const issuanceTime = nwsApi.formatIssuanceTime(latestForecast.issuanceTime);

  return (
    <div className="glass-card p-8 max-w-4xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-2">
          <h1 className="text-3xl font-bold text-white">
            Bay Area Forecast
          </h1>
          <button
            onClick={loadLatestForecast}
            className="text-dark-sky-blue hover:text-dark-sky-blue/80 transition-colors"
            title="Refresh"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
          </button>
        </div>
        <p className="text-dark-sky-text/70 text-sm">
          {latestForecast.productName}
        </p>
        <p className="text-dark-sky-text/60 text-xs mt-1">
          Issued: {issuanceTime}
        </p>
      </div>

      {/* Summary Card */}
      <div className="bg-dark-sky-accent/30 rounded-xl p-6 mb-6">
        <h2 className="section-header text-xl">Today's Summary</h2>
        <p className="forecast-text whitespace-pre-line">
          {summary}
        </p>
      </div>

      {/* View Full Discussion Button */}
      <button
        onClick={() => onViewDetails(latestForecast)}
        className="w-full py-4 bg-gradient-to-r from-dark-sky-blue to-dark-sky-accent hover:from-dark-sky-blue/90 hover:to-dark-sky-accent/90 rounded-xl font-semibold text-white transition-all duration-200 shadow-lg hover:shadow-xl"
      >
        View Full Forecast Discussion
      </button>

      {/* Daily Notification Toggle */}
      <div className="mt-6 pt-6 border-t border-white/10">
        <label className="flex items-center justify-between cursor-pointer">
          <span className="text-dark-sky-text/80">
            Enable daily notifications
          </span>
          <input
            type="checkbox"
            className="w-12 h-6 rounded-full appearance-none bg-dark-sky-accent/50 checked:bg-dark-sky-blue relative
                     before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white
                     before:top-0.5 before:left-0.5 before:transition-transform checked:before:translate-x-6
                     cursor-pointer transition-colors"
            onChange={async (e) => {
              if (e.target.checked) {
                const granted = await NotificationService.requestPermission();
                if (granted) {
                  NotificationService.sendTestNotification();
                }
              }
            }}
          />
        </label>
        <p className="text-xs text-dark-sky-text/50 mt-2">
          Get a summary of the latest forecast discussion each morning
        </p>
      </div>
    </div>
  );
};

