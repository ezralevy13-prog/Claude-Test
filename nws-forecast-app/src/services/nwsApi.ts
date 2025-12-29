// NWS API Service for Bay Area Forecast Discussions
// API Endpoint: https://api.weather.gov/products/types/AFD/locations/MTR

export interface NWSProduct {
  id: string;
  wmoCollectiveId: string;
  issuingOffice: string;
  issuanceTime: string;
  productCode: string;
  productName: string;
}

export interface NWSProductDetail {
  '@context': any;
  id: string;
  wmoCollectiveId: string;
  issuingOffice: string;
  issuanceTime: string;
  productCode: string;
  productName: string;
  productText: string;
}

export interface NWSProductsResponse {
  '@context': any;
  '@graph': NWSProduct[];
}

export interface ForecastSection {
  title: string;
  content: string;
}

const BASE_URL = 'https://api.weather.gov';
const BAY_AREA_OFFICE = 'MTR'; // Monterey office covers Bay Area
const PRODUCT_TYPE = 'AFD'; // Area Forecast Discussion

const USER_AGENT = 'NWS-Bay-Area-Forecast-App/1.0 (github.com/your-repo)';

class NWSApiService {
  private async fetchWithHeaders(url: string): Promise<Response> {
    const response = await fetch(url, {
      headers: {
        'User-Agent': USER_AGENT,
        'Accept': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`NWS API error: ${response.status} ${response.statusText}`);
    }

    return response;
  }

  async getLatestForecastDiscussions(limit: number = 5): Promise<NWSProduct[]> {
    try {
      const url = `${BASE_URL}/products/types/${PRODUCT_TYPE}/locations/${BAY_AREA_OFFICE}`;
      const response = await this.fetchWithHeaders(url);
      const data: NWSProductsResponse = await response.json();

      return data['@graph'].slice(0, limit);
    } catch (error) {
      console.error('Error fetching forecast discussions:', error);
      throw error;
    }
  }

  async getForecastDiscussion(productId: string): Promise<NWSProductDetail> {
    try {
      const response = await this.fetchWithHeaders(productId);
      const data: NWSProductDetail = await response.json();
      return data;
    } catch (error) {
      console.error('Error fetching forecast discussion detail:', error);
      throw error;
    }
  }

  parseForecastText(productText: string): ForecastSection[] {
    // Split the forecast text into sections
    const lines = productText.split('\n');
    const sections: ForecastSection[] = [];
    let currentSection: ForecastSection | null = null;

    for (const line of lines) {
      const trimmedLine = line.trim();

      // Detect section headers (usually all caps with periods or specific patterns)
      if (trimmedLine.match(/^\.([A-Z\s\/]+)\.{3}/) ||
          trimmedLine.match(/^&&/) ||
          trimmedLine.match(/^\.[A-Z\s]+\.\.\./)) {

        if (currentSection) {
          sections.push(currentSection);
        }

        currentSection = {
          title: trimmedLine.replace(/^\./, '').replace(/\.{3}$/, '').trim(),
          content: '',
        };
      } else if (currentSection && trimmedLine) {
        currentSection.content += (currentSection.content ? '\n' : '') + trimmedLine;
      }
    }

    if (currentSection) {
      sections.push(currentSection);
    }

    return sections;
  }

  extractSummary(productText: string): string {
    // Extract the first few paragraphs as a summary
    const lines = productText.split('\n\n');
    const summaryParagraphs: string[] = [];

    for (const paragraph of lines) {
      const trimmed = paragraph.trim();
      // Skip headers and metadata
      if (!trimmed.match(/^\./) && !trimmed.match(/^\d{3,}/) && trimmed.length > 50) {
        summaryParagraphs.push(trimmed);
        if (summaryParagraphs.length >= 2) break;
      }
    }

    return summaryParagraphs.join('\n\n') || 'No summary available.';
  }

  formatIssuanceTime(isoTime: string): string {
    const date = new Date(isoTime);
    return date.toLocaleString('en-US', {
      weekday: 'long',
      month: 'long',
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit',
      timeZoneName: 'short',
    });
  }
}

export const nwsApi = new NWSApiService();
