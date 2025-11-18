export * from './types';
export * from './hooks/useBookList';
export * from './hooks/useShelves';
export * from './hooks/useBookReview';
export * from './hooks/useReadingProgress';
export * from './hooks/useReadingStats';
export * from './hooks/useReadingGoals';

export const moduleMetadata = {
  name: 'book',
  domain: 'functional',
  version: '1.0.0',
  publicHooks: [
    'useBookList',
    'useShelves',
    'useBookReview',
    'useReadingProgress',
    'useReadingStats',
    'useReadingGoals',
  ],
  publicServices: [
    'bookService',
    'reviewService',
    'progressService',
    'statsService',
    'goalService',
  ],
  dependencies: {
    internal: ['@/core/lib/api', '@/core/lib/queryClient'],
    external: ['react', '@tanstack/react-query', 'axios'],
    domains: [],
  },
  exports: {
    hooks: [
      'useBookList',
      'useShelves',
      'useBookReview',
      'useReadingProgress',
      'useReadingStats',
      'useReadingGoals',
    ],
    services: ['bookService', 'reviewService', 'progressService', 'statsService', 'goalService'],
    types: [
      'Book',
      'Shelf',
      'BookReview',
      'ReadingProgress',
      'ReadingGoal',
      'ReadingStats',
      'CreateBookDto',
      'UpdateBookDto',
      'MoveBookDto',
      'CreateReviewDto',
      'UpdateReviewDto',
      'UpdateProgressDto',
      'CreateGoalDto',
      'UpdateGoalDto',
    ],
  },
} as const;
