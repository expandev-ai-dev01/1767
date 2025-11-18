import { useQuery } from '@tanstack/react-query';
import { bookService } from '../../services/bookService';
import type { UseShelvesReturn } from './types';

export const useShelves = (): UseShelvesReturn => {
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['shelves'],
    queryFn: bookService.getShelves,
  });

  return {
    shelves: data || [],
    isLoading,
    error,
    refetch,
  };
};
