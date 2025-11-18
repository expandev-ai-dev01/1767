import { useState } from 'react';
import { useReadingStats } from '@/domain/book/_module';
import { LoadingSpinner } from '@/core/components/LoadingSpinner';
import { ErrorMessage } from '@/core/components/ErrorMessage';
import { StatsOverview } from './_impl/StatsOverview';
import { PeriodSelector } from './_impl/PeriodSelector';
import { TopGenres } from './_impl/TopGenres';
import { TopAuthors } from './_impl/TopAuthors';
import { GoalProgress } from './_impl/GoalProgress';

export const DashboardPage = () => {
  const [period, setPeriod] = useState<'Mensal' | 'Trimestral' | 'Anual' | 'Todo o período'>(
    'Anual'
  );
  const { stats, isLoading, error } = useReadingStats({ period });

  if (isLoading) {
    return <LoadingSpinner size="lg" />;
  }

  if (error) {
    return (
      <ErrorMessage
        title="Erro ao carregar estatísticas"
        message="Não foi possível carregar suas estatísticas de leitura."
        onRetry={() => window.location.reload()}
      />
    );
  }

  if (!stats) {
    return (
      <ErrorMessage
        title="Sem dados"
        message="Comece a adicionar livros para ver suas estatísticas."
      />
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900">Dashboard</h1>
          <PeriodSelector period={period} onPeriodChange={setPeriod} />
        </div>

        <StatsOverview stats={stats} />

        {stats.goal && (
          <div className="mb-8">
            <GoalProgress goal={stats.goal} />
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <TopGenres genres={stats.topGenres} />
          <TopAuthors authors={stats.topAuthors} />
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
