import { useState } from 'react';
import { useShelves, useBookList } from '@/domain/book/_module';
import { LoadingSpinner } from '@/core/components/LoadingSpinner';
import { ErrorMessage } from '@/core/components/ErrorMessage';
import { ShelfTabs } from './_impl/ShelfTabs';
import { BookGrid } from './_impl/BookGrid';
import { AddBookButton } from './_impl/AddBookButton';

export const LibraryPage = () => {
  const { shelves, isLoading: isLoadingShelves, error: shelvesError } = useShelves();
  const [selectedShelfId, setSelectedShelfId] = useState<string>('');

  const {
    books,
    isLoading: isLoadingBooks,
    error: booksError,
    move,
    isMoving,
  } = useBookList({
    shelfId: selectedShelfId,
  });

  if (isLoadingShelves) {
    return <LoadingSpinner size="lg" />;
  }

  if (shelvesError) {
    return (
      <ErrorMessage
        title="Erro ao carregar estantes"
        message="Não foi possível carregar suas estantes. Tente novamente."
        onRetry={() => window.location.reload()}
      />
    );
  }

  if (!shelves || shelves.length === 0) {
    return (
      <ErrorMessage
        title="Nenhuma estante encontrada"
        message="Suas estantes serão criadas automaticamente."
      />
    );
  }

  if (!selectedShelfId && shelves.length > 0) {
    setSelectedShelfId(shelves[0].id);
  }

  const handleMoveBook = async (bookId: string, targetShelfId: string) => {
    try {
      await move({ bookId, targetShelfId });
    } catch (error: unknown) {
      console.error('Erro ao mover livro:', error);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900">Minha Biblioteca</h1>
          <AddBookButton shelfId={selectedShelfId} />
        </div>

        <ShelfTabs
          shelves={shelves}
          selectedShelfId={selectedShelfId}
          onSelectShelf={setSelectedShelfId}
        />

        {isLoadingBooks ? (
          <LoadingSpinner size="lg" />
        ) : booksError ? (
          <ErrorMessage
            title="Erro ao carregar livros"
            message="Não foi possível carregar os livros desta estante."
            onRetry={() => window.location.reload()}
          />
        ) : (
          <BookGrid
            books={books}
            shelves={shelves}
            currentShelfId={selectedShelfId}
            onMoveBook={handleMoveBook}
            isMoving={isMoving}
          />
        )}
      </div>
    </div>
  );
};

export default LibraryPage;
