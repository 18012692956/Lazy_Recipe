import { HttpClient } from './HttpClient';
import { IngredientsMap } from '../model/IngredientsMap';
import { Preferences } from '../model/Preferences';
import { Recipe } from '../model/Recipe';
import { RecommendRequest, FavoriteRequest } from '../model/Request';

export class ApiService {

  static async getIngredients(): Promise<IngredientsMap> {
    return await HttpClient.get<IngredientsMap>("/ingredients");
  }

  static async getPreferences(): Promise<Preferences> {
    return await HttpClient.get<Preferences>("/preferences");
  }

  // 收藏切换
  static async updateFavorite(recipeId: number): Promise<void> {
    const req: FavoriteRequest = { recipe_id: recipeId };
    await HttpClient.post<void, FavoriteRequest>(`/favorite`, req);
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
