import { useState } from 'react';
import type { BookCardProps } from './types';

export const BookCard = ({
  book,
  shelves,
  currentShelfId,
  onMoveBook,
  isMoving,
}: BookCardProps) => {
  const [showMenu, setShowMenu] = useState(false);

  const otherShelves = shelves.filter((shelf) => shelf.id !== currentShelfId);

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
      <div className="aspect-[2/3] bg-gray-200 relative">
        {book.coverUrl ? (
          <img src={book.coverUrl} alt={book.title} className="w-full h-full object-cover" />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-gray-400">
            <span className="text-4xl">📚</span>
          </div>
        )}
      </div>

      <div className="p-4">
        <h3 className="font-semibold text-gray-900 truncate" title={book.title}>
          {book.title}
        </h3>
        <p className="text-sm text-gray-600 truncate" title={book.author}>
          {book.author}
        </p>
        {book.year && <p className="text-xs text-gray-500 mt-1">{book.year}</p>}
        {book.genre && (
          <span className="inline-block mt-2 px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded">
            {book.genre}
          </span>
        )}

        <div className="mt-4 relative">
          <button
            onClick={() => setShowMenu(!showMenu)}
            disabled={isMoving}
            className="w-full px-3 py-2 text-sm bg-gray-100 text-gray-700 rounded hover:bg-gray-200 transition-colors disabled:opacity-50"
          >
            Mover para...
          </button>

          {showMenu && (
            <div className="absolute bottom-full left-0 right-0 mb-2 bg-white border border-gray-200 rounded shadow-lg z-10">
              {otherShelves.map((shelf) => (
                <button
                  key={shelf.id}
                  onClick={() => {
                    onMoveBook(book.id, shelf.id);
                    setShowMenu(false);
                  }}
                  className="w-full px-4 py-2 text-left text-sm hover:bg-gray-100 transition-colors"
                >
                  {shelf.type}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
