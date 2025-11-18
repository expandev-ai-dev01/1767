import type { ReadingGoal, CreateGoalDto, UpdateGoalDto } from '../../types';

export interface UseReadingGoalsReturn {
  goals: ReadingGoal[];
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
  create: (data: CreateGoalDto) => Promise<ReadingGoal>;
  update: (params: { id: string; data: UpdateGoalDto }) => Promise<ReadingGoal>;
  remove: (id: string) => Promise<void>;
  isCreating: boolean;
  isUpdating: boolean;
  isRemoving: boolean;
}
