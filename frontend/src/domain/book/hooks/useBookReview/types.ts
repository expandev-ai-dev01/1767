import type { BookReview, CreateReviewDto, UpdateReviewDto } from '../../types';

export interface UseBookReviewOptions {
  bookId: string;
}

export interface UseBookReviewReturn {
  review: BookReview | null;
  isLoading: boolean;
  error: Error | null;
  create: (data: CreateReviewDto) => Promise<BookReview>;
  update: (params: { id: string; data: UpdateReviewDto }) => Promise<BookReview>;
  remove: (id: string) => Promise<void>;
  isCreating: boolean;
  isUpdating: boolean;
  isRemoving: boolean;
}
