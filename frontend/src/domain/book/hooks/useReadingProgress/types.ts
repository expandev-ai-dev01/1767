import type { ReadingProgress, UpdateProgressDto } from '../../types';

export interface UseReadingProgressOptions {
  bookId: string;
}

export interface UseReadingProgressReturn {
  progress: ReadingProgress | null;
  history: ReadingProgress[];
  isLoading: boolean;
  isLoadingHistory: boolean;
  error: Error | null;
  update: (data: UpdateProgressDto) => Promise<ReadingProgress>;
  isUpdating: boolean;
}
