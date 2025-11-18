import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { progressService } from '../../services/progressService';
import type { UseReadingProgressOptions, UseReadingProgressReturn } from './types';

export const useReadingProgress = (
  options: UseReadingProgressOptions
): UseReadingProgressReturn => {
  const queryClient = useQueryClient();
  const { bookId } = options;

  const queryKey = ['progress', bookId];

  const { data, isLoading, error } = useQuery({
    queryKey,
    queryFn: () => progressService.getProgress(bookId),
    enabled: !!bookId,
  });

  const { data: history, isLoading: isLoadingHistory } = useQuery({
    queryKey: ['progress-history', bookId],
    queryFn: () => progressService.getProgressHistory(bookId),
    enabled: !!bookId,
  });

  const { mutateAsync: update, isPending: isUpdating } = useMutation({
    mutationFn: progressService.updateProgress,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey });
      queryClient.invalidateQueries({ queryKey: ['progress-history', bookId] });
      queryClient.invalidateQueries({ queryKey: ['stats'] });
    },
  });

  return {
    progress: data || null,
    history: history || [],
    isLoading,
    isLoadingHistory,
    error,
    update,
    isUpdating,
  };
};
