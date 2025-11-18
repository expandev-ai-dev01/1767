import { useQuery } from '@tanstack/react-query';
import { statsService } from '../../services/statsService';
import type { UseReadingStatsOptions, UseReadingStatsReturn } from './types';

export const useReadingStats = (options: UseReadingStatsOptions = {}): UseReadingStatsReturn => {
  const { period = 'Anual' } = options;

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['stats', period],
    queryFn: () => statsService.getStats(period),
  });

  return {
    stats: data || null,
    isLoading,
    error,
    refetch,
  };
};
