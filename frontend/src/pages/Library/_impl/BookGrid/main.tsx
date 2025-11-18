import { BookCard } from '../BookCard';
import type { BookGridProps } from './types';

export const BookGrid = ({
  books,
  shelves,
  currentShelfId,
  onMoveBook,
  isMoving,
}: BookGridProps) => {
  if (books.length === 0) {
    return (
      <div className="text-center py-16">
        <p className="text-gray-500 text-lg">Nenhum livro nesta estante ainda.</p>
        <p className="text-gray-400 mt-2">Adicione seu primeiro livro!</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
      {books.map((book) => (
        <BookCard
          key={book.id}
          book={book}
          shelves={shelves}
          currentShelfId={currentShelfId}
          onMoveBook={onMoveBook}
          isMoving={isMoving}
        />
      ))}
    </div>
  );
};
