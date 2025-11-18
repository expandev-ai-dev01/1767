import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { reviewService } from '../../services/reviewService';
import type { UseBookReviewOptions, UseBookReviewReturn } from './types';

export const useBookReview = (options: UseBookReviewOptions): UseBookReviewReturn => {
  const queryClient = useQueryClient();
  const { bookId } = options;

  const queryKey = ['review', bookId];

  const { data, isLoading, error } = useQuery({
    queryKey,
    queryFn: () => reviewService.getReview(bookId),
    enabled: !!bookId,
  });

  const { mutateAsync: create, isPending: isCreating } = useMutation({
    mutationFn: reviewService.createReview,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey });
      queryClient.invalidateQueries({ queryKey: ['stats'] });
    },
  });

  const { mutateAsync: update, isPending: isUpdating } = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => reviewService.updateReview(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey });
      queryClient.invalidateQueries({ queryKey: ['stats'] });
    },
  });

  const { mutateAsync: remove, isPending: isRemoving } = useMutation({
    mutationFn: reviewService.deleteReview,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey });
      queryClient.invalidateQueries({ queryKey: ['stats'] });
    },
  });

  return {
    review: data || null,
    isLoading,
    error,
    create,
    update,
    remove,
    isCreating,
    isUpdating,
    isRemoving,
  };
};
