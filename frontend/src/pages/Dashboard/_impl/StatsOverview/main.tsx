import type { StatsOverviewProps } from './types';

export const StatsOverview = ({ stats }: StatsOverviewProps) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-sm font-medium text-gray-600 mb-2">Livros Lidos</h3>
        <p className="text-3xl font-bold text-gray-900">{stats.totalBooksRead}</p>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-sm font-medium text-gray-600 mb-2">Páginas Lidas</h3>
        <p className="text-3xl font-bold text-gray-900">{stats.totalPagesRead.toLocaleString()}</p>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-sm font-medium text-gray-600 mb-2">Média por Mês</h3>
        <p className="text-3xl font-bold text-gray-900">{stats.averageBooksPerMonth.toFixed(1)}</p>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-sm font-medium text-gray-600 mb-2">Avaliação Média</h3>
        <p className="text-3xl font-bold text-gray-900">
          {stats.averageRating.toFixed(1)}
          <span className="text-lg text-yellow-500 ml-1">★</span>
        </p>
      </div>
    </div>
  );
};
