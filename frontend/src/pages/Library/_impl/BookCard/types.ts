import type { Book, Shelf } from '@/domain/book/types';

export interface BookCardProps {
  book: Book;
  shelves: Shelf[];
  currentShelfId: string;
  onMoveBook: (bookId: string, targetShelfId: string) => void;
  isMoving: boolean;
}
