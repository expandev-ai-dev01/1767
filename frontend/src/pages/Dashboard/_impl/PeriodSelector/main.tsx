import type { PeriodSelectorProps } from './types';

export const PeriodSelector = ({ period, onPeriodChange }: PeriodSelectorProps) => {
  const periods: Array<'Mensal' | 'Trimestral' | 'Anual' | 'Todo o período'> = [
    'Mensal',
    'Trimestral',
    'Anual',
    'Todo o período',
  ];

  return (
    <div className="flex gap-2">
      {periods.map((p) => (
        <button
          key={p}
          onClick={() => onPeriodChange(p)}
          className={`px-4 py-2 rounded-lg font-medium transition-colors ${
            period === p ? 'bg-blue-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-100'
          }`}
        >
          {p}
        </button>
      ))}
    </div>
  );
};
