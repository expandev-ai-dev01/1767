import type { TopGenresProps } from './types';

export const TopGenres = ({ genres }: TopGenresProps) => {
  if (genres.length === 0) {
    return (
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Gêneros Mais Lidos</h3>
        <p className="text-gray-500">Nenhum gênero registrado ainda.</p>
      </div>
    );
  }

  const maxCount = Math.max(...genres.map((g) => g.count));

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Gêneros Mais Lidos</h3>
      <div className="space-y-4">
        {genres.map((genre) => (
          <div key={genre.genre}>
            <div className="flex justify-between mb-1">
              <span className="text-sm font-medium text-gray-700">{genre.genre}</span>
              <span className="text-sm text-gray-500">{genre.count} livros</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-blue-600 h-2 rounded-full transition-all"
                style={{ width: `${(genre.count / maxCount) * 100}%` }}
              />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
