export interface Book {
  id: string;
  title: string;
  author: string;
  year?: number;
  genre?: string;
  coverUrl?: string;
  isbn?: string;
  pages?: number;
  shelfId: string;
  createdAt: string;
}

export interface Shelf {
  id: string;
  type: 'Lido' | 'Lendo' | 'Quero Ler';
  userId: string;
  bookCount: number;
}

export interface BookReview {
  id: string;
  bookId: string;
  userId: string;
  rating: number;
  review?: string;
  visibility: 'Pública' | 'Privada';
  createdAt: string;
  updatedAt?: string;
}

export interface ReadingProgress {
  id: string;
  bookId: string;
  userId: string;
  currentPage: number;
  percentage: number;
  notes?: string;
  recordedAt: string;
}

export interface ReadingGoal {
  id: string;
  userId: string;
  type: 'Livros' | 'Páginas';
  target: number;
  period: 'Mensal' | 'Trimestral' | 'Anual' | 'Personalizado';
  startDate: string;
  endDate: string;
  current: number;
  percentage: number;
  status: 'Em andamento' | 'Concluída' | 'Não concluída';
  notifications: boolean;
}

export interface ReadingStats {
  userId: string;
  period: 'Mensal' | 'Trimestral' | 'Anual' | 'Todo o período';
  totalBooksRead: number;
  totalPagesRead: number;
  averageBooksPerMonth: number;
  topGenres: Array<{ genre: string; count: number }>;
  topAuthors: Array<{ author: string; count: number }>;
  averageRating: number;
  goal?: ReadingGoal;
}

export interface CreateBookDto {
  title: string;
  author: string;
  year?: number;
  genre?: string;
  coverUrl?: string;
  isbn?: string;
  pages?: number;
  shelfId: string;
}

export interface UpdateBookDto {
  title?: string;
  author?: string;
  year?: number;
  genre?: string;
  coverUrl?: string;
  isbn?: string;
  pages?: number;
}

export interface MoveBookDto {
  bookId: string;
  targetShelfId: string;
}

export interface CreateReviewDto {
  bookId: string;
  rating: number;
  review?: string;
  visibility: 'Pública' | 'Privada';
}

export interface UpdateReviewDto {
  rating?: number;
  review?: string;
  visibility?: 'Pública' | 'Privada';
}

export interface UpdateProgressDto {
  bookId: string;
  currentPage: number;
  notes?: string;
}

export interface CreateGoalDto {
  type: 'Livros' | 'Páginas';
  target: number;
  period: 'Mensal' | 'Trimestral' | 'Anual' | 'Personalizado';
  startDate: string;
  endDate: string;
  notifications: boolean;
}

export interface UpdateGoalDto {
  target?: number;
  notifications?: boolean;
}
