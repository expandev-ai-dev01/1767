import type { ShelfTabsProps } from './types';

export const ShelfTabs = ({ shelves, selectedShelfId, onSelectShelf }: ShelfTabsProps) => {
  return (
    <div className="flex gap-4 mb-8 border-b border-gray-200">
      {shelves.map((shelf) => (
        <button
          key={shelf.id}
          onClick={() => onSelectShelf(shelf.id)}
          className={`px-6 py-3 font-medium transition-colors ${
            selectedShelfId === shelf.id
              ? 'text-blue-600 border-b-2 border-blue-600'
              : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          {shelf.type}
          <span className="ml-2 text-sm text-gray-500">({shelf.bookCount})</span>
        </button>
      ))}
    </div>
  );
};
