import { authenticatedClient } from '@/core/lib/api';
import type { BookReview, CreateReviewDto, UpdateReviewDto } from '../types';

export const reviewService = {
  async getReview(bookId: string): Promise<BookReview | null> {
    try {
      const response = await authenticatedClient.get(`/books/${bookId}/review`);
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

  async createReview(data: CreateReviewDto): Promise<BookReview> {
    const response = await authenticatedClient.post('/reviews', data);
    return response.data.data;
  },

  async updateReview(id: string, data: UpdateReviewDto): Promise<BookReview> {
    const response = await authenticatedClient.put(`/reviews/${id}`, data);
    return response.data.data;
  },

  async deleteReview(id: string): Promise<void> {
    await authenticatedClient.delete(`/reviews/${id}`);
  },
};
