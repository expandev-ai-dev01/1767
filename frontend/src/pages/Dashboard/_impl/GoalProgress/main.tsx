import type { GoalProgressProps } from './types';

export const GoalProgress = ({ goal }: GoalProgressProps) => {
  return (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Meta de Leitura</h3>
          <p className="text-sm text-gray-600">
            {goal.type === 'Livros' ? 'Livros' : 'Páginas'} - {goal.period}
          </p>
        </div>
        <span
          className={`px-3 py-1 rounded-full text-sm font-medium ${
            goal.status === 'Concluída'
              ? 'bg-green-100 text-green-800'
              : goal.status === 'Em andamento'
              ? 'bg-blue-100 text-blue-800'
              : 'bg-red-100 text-red-800'
          }`}
        >
          {goal.status}
        </span>
      </div>

      <div className="mb-4">
        <div className="flex justify-between mb-2">
          <span className="text-sm font-medium text-gray-700">
            {goal.current} de {goal.target} {goal.type === 'Livros' ? 'livros' : 'páginas'}
          </span>
          <span className="text-sm text-gray-500">{goal.percentage.toFixed(0)}%</span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-3">
          <div
            className={`h-3 rounded-full transition-all ${
              goal.percentage >= 100
                ? 'bg-green-600'
                : goal.percentage >= 75
                ? 'bg-blue-600'
                : goal.percentage >= 50
                ? 'bg-yellow-600'
                : 'bg-red-600'
            }`}
            style={{ width: `${Math.min(goal.percentage, 100)}%` }}
          />
        </div>
      </div>

      <div className="text-sm text-gray-600">
        <p>
          Período: {new Date(goal.startDate).toLocaleDateString()} -{' '}
          {new Date(goal.endDate).toLocaleDateString()}
        </p>
      </div>
    </div>
  );
};
