import { authenticatedClient } from '@/core/lib/api';
import type { Book, Shelf, CreateBookDto, UpdateBookDto, MoveBookDto } from '../types';

export const bookService = {
  async getShelves(): Promise<Shelf[]> {
    const response = await authenticatedClient.get('/shelves');
    return response.data.data;
  },

  async getBooksByShelf(shelfId: string): Promise<Book[]> {
    const response = await authenticatedClient.get(`/shelves/${shelfId}/books`);
    return response.data.data;
  },

  async getBook(id: string): Promise<Book> {
    const response = await authenticatedClient.get(`/books/${id}`);
    return response.data.data;
  },

  async createBook(data: CreateBookDto): Promise<Book> {
    const response = await authenticatedClient.post('/books', data);
    return response.data.data;
  },

  async updateBook(id: string, data: UpdateBookDto): Promise<Book> {
    const response = await authenticatedClient.put(`/books/${id}`, data);
    return response.data.data;
  },

  async deleteBook(id: string): Promise<void> {
    await authenticatedClient.delete(`/books/${id}`);
  },

  async moveBook(data: MoveBookDto): Promise<Book> {
    const response = await authenticatedClient.post('/books/move', data);
    return response.data.data;
  },
};
