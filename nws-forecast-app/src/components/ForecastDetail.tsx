import { useState, useEffect } from 'react';
import { nwsApi } from '../services/nwsApi';
import type { NWSProduct, NWSProductDetail, ForecastSection } from '../services/nwsApi';

interface ForecastDetailProps {
  product: NWSProduct;
  onBack: () => void;
}

export const ForecastDetail = ({ product, onBack }: ForecastDetailProps) => {
  const [detail, setDetail] = useState<NWSProductDetail | null>(null);
  const [sections, setSections] = useState<ForecastSection[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [expandedSections, setExpandedSections] = useState<Set<number>>(new Set([0]));

  useEffect(() => {
    loadForecastDetail();
  }, [product.id]);

  const loadForecastDetail = async () => {
    try {
      setLoading(true);
      setError(null);

      const forecastDetail = await nwsApi.getForecastDiscussion(product.id);
      setDetail(forecastDetail);

      const parsedSections = nwsApi.parseForecastText(forecastDetail.productText);
      setSections(parsedSections);

      // Expand the first section by default
      setExpandedSections(new Set([0]));
    } catch (err) {
      setError('Failed to load forecast details.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const toggleSection = (index: number) => {
    const newExpanded = new Set(expandedSections);
    if (newExpanded.has(index)) {
      newExpanded.delete(index);
    } else {
      newExpanded.add(index);
    }
    setExpandedSections(newExpanded);
  };

  if (loading) {
    return (
      <div className="glass-card p-8 max-w-4xl mx-auto">
        <div className="flex items-center justify-center space-x-3">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-white"></div>
          <span className="text-white/80">Loading detailed forecast...</span>
        </div>
      </div>
    );
  }

  if (error || !detail) {
    return (
      <div className="glass-card p-8 max-w-4xl mx-auto">
        <button
          onClick={onBack}
          className="mb-4 text-dark-sky-blue hover:text-dark-sky-blue/80 flex items-center space-x-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          <span>Back</span>
        </button>
        <div className="text-center">
          <p className="text-red-400">{error || 'Failed to load forecast'}</p>
        </div>
      </div>
    );
  }

  const issuanceTime = nwsApi.formatIssuanceTime(product.issuanceTime);

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Header */}
      <div className="glass-card p-8">
        <button
          onClick={onBack}
          className="mb-6 text-dark-sky-blue hover:text-dark-sky-blue/80 flex items-center space-x-2 transition-colors"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          <span>Back to Summary</span>
        </button>

        <h1 className="text-3xl font-bold text-white mb-2">
          Detailed Forecast Discussion
        </h1>
        <p className="text-dark-sky-text/70 text-sm mb-1">
          {product.productName}
        </p>
        <p className="text-dark-sky-text/60 text-xs">
          Issued: {issuanceTime}
        </p>
        <p className="text-dark-sky-text/60 text-xs">
          Office: {product.issuingOffice}
        </p>
      </div>

      {/* Forecast Sections */}
      {sections.length > 0 ? (
        <div className="space-y-4">
          {sections.map((section, index) => (
            <div key={index} className="glass-card overflow-hidden">
              <button
                onClick={() => toggleSection(index)}
                className="w-full p-6 flex items-center justify-between hover:bg-white/5 transition-colors"
              >
                <h2 className="text-xl font-semibold text-white text-left">
                  {section.title || `Section ${index + 1}`}
                </h2>
                <svg
                  className={`w-6 h-6 text-dark-sky-blue transition-transform ${
                    expandedSections.has(index) ? 'rotate-180' : ''
                  }`}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>

              {expandedSections.has(index) && (
                <div className="px-6 pb-6">
                  <div className="border-t border-white/10 pt-4">
                    <p className="forecast-text whitespace-pre-line">
                      {section.content}
                    </p>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      ) : (
        <div className="glass-card p-8">
          <h2 className="section-header">Full Forecast Text</h2>
          <pre className="forecast-text whitespace-pre-wrap font-mono text-sm">
            {detail.productText}
          </pre>
        </div>
      )}

      {/* Action Buttons */}
      <div className="glass-card p-6 flex gap-4">
        <button
          onClick={() => {
            navigator.clipboard.writeText(detail.productText);
            alert('Forecast copied to clipboard!');
          }}
          className="flex-1 py-3 bg-dark-sky-accent hover:bg-dark-sky-accent/80 rounded-lg font-medium text-white transition-colors flex items-center justify-center space-x-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
          </svg>
          <span>Copy Text</span>
        </button>

        <button
          onClick={() => {
            window.open(product.id, '_blank');
          }}
          className="flex-1 py-3 bg-dark-sky-blue hover:bg-dark-sky-blue/80 rounded-lg font-medium text-white transition-colors flex items-center justify-center space-x-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
          </svg>
          <span>View on NWS</span>
        </button>
      </div>
    </div>
  );
};
