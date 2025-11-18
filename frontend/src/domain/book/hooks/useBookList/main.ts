import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { bookService } from '../../services/bookService';
import type { UseBookListOptions, UseBookListReturn } from './types';

export const useBookList = (options: UseBookListOptions): UseBookListReturn => {
  const queryClient = useQueryClient();
  const { shelfId } = options;

  const queryKey = ['books', shelfId];

  const { data, isLoading, error, refetch } = useQuery({
    queryKey,
    queryFn: () => bookService.getBooksByShelf(shelfId),
    enabled: !!shelfId,
  });

  const { mutateAsync: create, isPending: isCreating } = useMutation({
    mutationFn: bookService.createBook,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['books'] });
      queryClient.invalidateQueries({ queryKey: ['shelves'] });
    },
  });

  const { mutateAsync: update, isPending: isUpdating } = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => bookService.updateBook(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['books'] });
    },
  });

  const { mutateAsync: remove, isPending: isRemoving } = useMutation({
    mutationFn: bookService.deleteBook,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['books'] });
      queryClient.invalidateQueries({ queryKey: ['shelves'] });
    },
  });

  const { mutateAsync: move, isPending: isMoving } = useMutation({
    mutationFn: bookService.moveBook,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['books'] });
      queryClient.invalidateQueries({ queryKey: ['shelves'] });
    },
  });

  return {
    books: data || [],
    isLoading,
    error,
    refetch,
    create,
    update,
    remove,
    move,
    isCreating,
    isUpdating,
    isRemoving,
    isMoving,
  };
};
