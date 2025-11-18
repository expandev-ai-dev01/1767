export interface PeriodSelectorProps {
  period: 'Mensal' | 'Trimestral' | 'Anual' | 'Todo o período';
  onPeriodChange: (period: 'Mensal' | 'Trimestral' | 'Anual' | 'Todo o período') => void;
}
