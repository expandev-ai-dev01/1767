import type { Book, Shelf } from '@/domain/book/types';

export interface BookGridProps {
  books: Book[];
  shelves: Shelf[];
  currentShelfId: string;
  onMoveBook: (bookId: string, targetShelfId: string) => void;
  isMoving: boolean;
}
