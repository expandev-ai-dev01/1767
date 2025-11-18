import type { TopAuthorsProps } from './types';

export const TopAuthors = ({ authors }: TopAuthorsProps) => {
  if (authors.length === 0) {
    return (
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Autores Mais Lidos</h3>
        <p className="text-gray-500">Nenhum autor registrado ainda.</p>
      </div>
    );
  }

  const maxCount = Math.max(...authors.map((a) => a.count));

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Autores Mais Lidos</h3>
      <div className="space-y-4">
        {authors.map((author) => (
          <div key={author.author}>
            <div className="flex justify-between mb-1">
              <span className="text-sm font-medium text-gray-700">{author.author}</span>
              <span className="text-sm text-gray-500">{author.count} livros</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-green-600 h-2 rounded-full transition-all"
                style={{ width: `${(author.count / maxCount) * 100}%` }}
              />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
