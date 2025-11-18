import type { Shelf } from '@/domain/book/types';

export interface ShelfTabsProps {
  shelves: Shelf[];
  selectedShelfId: string;
  onSelectShelf: (shelfId: string) => void;
}
