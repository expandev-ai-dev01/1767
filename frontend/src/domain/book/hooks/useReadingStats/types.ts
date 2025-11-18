import type { ReadingStats } from '../../types';

export interface UseReadingStatsOptions {
  period?: 'Mensal' | 'Trimestral' | 'Anual' | 'Todo o período';
}

export interface UseReadingStatsReturn {
  stats: ReadingStats | null;
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
}
