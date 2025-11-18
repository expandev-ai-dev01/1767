import { useNavigate } from 'react-router-dom';
import type { AddBookButtonProps } from './types';

export const AddBookButton = ({ shelfId }: AddBookButtonProps) => {
  const navigate = useNavigate();

  return (
    <button
      onClick={() => navigate(`/books/new?shelfId=${shelfId}`)}
      className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
    >
      + Adicionar Livro
    </button>
  );
};
