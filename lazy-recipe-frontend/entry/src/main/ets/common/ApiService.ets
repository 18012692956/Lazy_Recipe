import { HttpClient } from './HttpClient';
import { IngredientsMap } from '../model/IngredientsMap';
import { Preferences } from '../model/Preferences';
import { Recipe } from '../model/Recipe';
import { RecommendRequest, DefaultRequest } from '../model/Request';

export class ApiService {

  static async getIngredients(): Promise<IngredientsMap> {
    return await HttpClient.get<IngredientsMap>("/ingredients");
  }

  static async getPreferences(): Promise<Preferences> {
    return await HttpClient.get<Preferences>("/preferences");
  }

  static async getFavorites(): Promise<Recipe[]> {
    return await HttpClient.get<Recipe[]>("/favorites");
  }

  // ✅ 获取浏览历史
  static async getHistory(): Promise<Recipe[]> {
    return await HttpClient.get<Recipe[]>("/history");
  }

  // 收藏切换
  static async updateFavorite(recipeId: number): Promise<void> {
    const req: DefaultRequest = { request: "" };
    await HttpClient.post<void, DefaultRequest>(`/recipes/${recipeId}/favorite`, req);
  }

  // ✅ 更新浏览记录
  static async updateViewHistory(recipeId: number): Promise<void> {
    const req: DefaultRequest = { request: "" };
    await HttpClient.post<void, DefaultRequest>(`/recipes/${recipeId}/view`, req);
  }

  // ✅ 清空浏览历史
  static async clearHistory(): Promise<void> {
    const req: DefaultRequest = { request: "" };
    await HttpClient.post<void, DefaultRequest>("/history/clear", req);
  }

  static async recommend(
    ingredients: string[],
    taste: string,
    style: string
  ): Promise<Recipe[]> {

    const req: RecommendRequest = {
      ingredients: ingredients,
      taste: taste,
      style: style
    };

    return await HttpClient.post<Recipe[], RecommendRequest>("/recommend", req);
  }
}
