import { authenticatedClient } from '@/core/lib/api';
import type { ReadingGoal, CreateGoalDto, UpdateGoalDto } from '../types';

export const goalService = {
  async getGoals(): Promise<ReadingGoal[]> {
    const response = await authenticatedClient.get('/goals');
    return response.data.data;
  },

  async getGoal(id: string): Promise<ReadingGoal> {
    const response = await authenticatedClient.get(`/goals/${id}`);
    return response.data.data;
  },

  async createGoal(data: CreateGoalDto): Promise<ReadingGoal> {
    const response = await authenticatedClient.post('/goals', data);
    return response.data.data;
  },

  async updateGoal(id: string, data: UpdateGoalDto): Promise<ReadingGoal> {
    const response = await authenticatedClient.put(`/goals/${id}`, data);
    return response.data.data;
  },

  async deleteGoal(id: string): Promise<void> {
    await authenticatedClient.delete(`/goals/${id}`);
  },
};
