// Daily Notification Service
// Manages browser notifications for daily forecast summaries

import { nwsApi } from './nwsApi';

export class NotificationService {
  private static NOTIFICATION_TIME_KEY = 'nws-notification-time';
  private static LAST_NOTIFICATION_KEY = 'nws-last-notification';
  private static DEFAULT_NOTIFICATION_HOUR = 8; // 8 AM

  static async requestPermission(): Promise<boolean> {
    if (!('Notification' in window)) {
      console.warn('This browser does not support notifications');
      return false;
    }

    if (Notification.permission === 'granted') {
      return true;
    }

    if (Notification.permission !== 'denied') {
      const permission = await Notification.requestPermission();
      return permission === 'granted';
    }

    return false;
  }

  static async sendTestNotification(): Promise<void> {
    const granted = await this.requestPermission();
    if (!granted) {
      console.warn('Notification permission not granted');
      return;
    }

    new Notification('NWS Bay Area Forecast', {
      body: 'Daily notifications are now enabled!',
      icon: '/weather-icon.png',
      badge: '/weather-badge.png',
      tag: 'nws-test',
    });
  }

  static async sendDailyForecastNotification(): Promise<void> {
    const granted = await this.requestPermission();
    if (!granted) return;

    try {
      const forecasts = await nwsApi.getLatestForecastDiscussions(1);
      if (forecasts.length === 0) return;

      const latest = forecasts[0];
      const detail = await nwsApi.getForecastDiscussion(latest.id);
      const summary = nwsApi.extractSummary(detail.productText);

      // Truncate summary for notification
      const shortSummary = summary.length > 150
        ? summary.substring(0, 147) + '...'
        : summary;

      new Notification('Bay Area Forecast Update', {
        body: shortSummary,
        icon: '/weather-icon.png',
        badge: '/weather-badge.png',
        tag: 'nws-daily',
        requireInteraction: false,
        data: {
          url: window.location.origin,
        },
      });

      // Update last notification time
      localStorage.setItem(
        this.LAST_NOTIFICATION_KEY,
        new Date().toISOString()
      );
    } catch (error) {
      console.error('Failed to send forecast notification:', error);
    }
  }

  static setupDailyNotifications(): void {
    if (!('Notification' in window)) return;

    // Check if we should send a notification (once per day at the set time)
    const checkAndNotify = () => {
      const now = new Date();
      const currentHour = now.getHours();
      const notificationHour = parseInt(
        localStorage.getItem(this.NOTIFICATION_TIME_KEY) ||
        String(this.DEFAULT_NOTIFICATION_HOUR)
      );

      const lastNotification = localStorage.getItem(this.LAST_NOTIFICATION_KEY);
      const lastNotificationDate = lastNotification
        ? new Date(lastNotification)
        : null;

      // Check if it's time to send and we haven't sent one today
      const shouldSend =
        currentHour === notificationHour &&
        (!lastNotificationDate ||
          now.toDateString() !== lastNotificationDate.toDateString());

      if (shouldSend) {
        this.sendDailyForecastNotification();
      }
    };

    // Check every hour
    checkAndNotify();
    setInterval(checkAndNotify, 60 * 60 * 1000);
  }

  static setNotificationTime(hour: number): void {
    if (hour < 0 || hour > 23) {
      throw new Error('Hour must be between 0 and 23');
    }
    localStorage.setItem(this.NOTIFICATION_TIME_KEY, String(hour));
  }

  static getNotificationTime(): number {
    return parseInt(
      localStorage.getItem(this.NOTIFICATION_TIME_KEY) ||
      String(this.DEFAULT_NOTIFICATION_HOUR)
    );
  }
}

// Initialize notifications when the module loads
if (typeof window !== 'undefined') {
  NotificationService.setupDailyNotifications();
}
