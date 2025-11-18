import type { Shelf } from '../../types';

export interface UseShelvesReturn {
  shelves: Shelf[];
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
}
