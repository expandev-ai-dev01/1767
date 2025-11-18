import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { goalService } from '../../services/goalService';
import type { UseReadingGoalsReturn } from './types';

export const useReadingGoals = (): UseReadingGoalsReturn => {
  const queryClient = useQueryClient();

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['goals'],
    queryFn: goalService.getGoals,
  });

  const { mutateAsync: create, isPending: isCreating } = useMutation({
    mutationFn: goalService.createGoal,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['goals'] });
      queryClient.invalidateQueries({ queryKey: ['stats'] });
    },
  });

  const { mutateAsync: update, isPending: isUpdating } = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => goalService.updateGoal(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['goals'] });
    },
  });

  const { mutateAsync: remove, isPending: isRemoving } = useMutation({
    mutationFn: goalService.deleteGoal,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['goals'] });
    },
  });

  return {
    goals: data || [],
    isLoading,
    error,
    refetch,
    create,
    update,
    remove,
    isCreating,
    isUpdating,
    isRemoving,
  };
};
