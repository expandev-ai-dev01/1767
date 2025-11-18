import { authenticatedClient } from '@/core/lib/api';
import type { ReadingProgress, UpdateProgressDto } from '../types';

export const progressService = {
  async getProgress(bookId: string): Promise<ReadingProgress | null> {
    try {
      const response = await authenticatedClient.get(`/books/${bookId}/progress`);
      return response.data.data;
    } catch (error: unknown) {
      if (typeof error === 'object' && error !== null && 'response' in error) {
        const axiosError = error as { response: { status: number } };
        if (axiosError.response?.status === 404) {
          return null;
        }
      }
      throw error;
    }
  },

  async getProgressHistory(bookId: string): Promise<ReadingProgress[]> {
    const response = await authenticatedClient.get(`/books/${bookId}/progress/history`);
    return response.data.data;
  },

  async updateProgress(data: UpdateProgressDto): Promise<ReadingProgress> {
    const response = await authenticatedClient.post('/progress', data);
    return response.data.data;
  },
};
