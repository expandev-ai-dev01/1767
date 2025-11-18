import type { Book, CreateBookDto, UpdateBookDto, MoveBookDto } from '../../types';

export interface UseBookListOptions {
  shelfId: string;
}

export interface UseBookListReturn {
  books: Book[];
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
  create: (data: CreateBookDto) => Promise<Book>;
  update: (params: { id: string; data: UpdateBookDto }) => Promise<Book>;
  remove: (id: string) => Promise<void>;
  move: (data: MoveBookDto) => Promise<Book>;
  isCreating: boolean;
  isUpdating: boolean;
  isRemoving: boolean;
  isMoving: boolean;
}
