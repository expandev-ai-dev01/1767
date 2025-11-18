import { authenticatedClient } from '@/core/lib/api';
import type { ReadingStats } from '../types';

export const statsService = {
  async getStats(
    period: 'Mensal' | 'Trimestral' | 'Anual' | 'Todo o período'
  ): Promise<ReadingStats> {
    const response = await authenticatedClient.get('/stats', {
      params: { period },
    });
    return response.data.data;
  },
};
