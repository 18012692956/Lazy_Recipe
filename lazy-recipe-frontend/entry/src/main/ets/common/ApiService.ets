import { HttpClient } from './HttpClient';
import { IngredientsMap } from '../model/IngredientsMap';
import { Preferences } from '../model/Preferences';
import { Recipe } from '../model/Recipe';
import { RecommendRequest } from '../model/RecommendRequest';

export class ApiService {

  static async getIngredients(): Promise<IngredientsMap> {
    return await HttpClient.get<IngredientsMap>("/ingredients");
  }

  static async getPreferences(): Promise<Preferences> {
    return await HttpClient.get<Preferences>("/preferences");
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

    return await HttpClient.post<Recipe[]>("/recommend", req);
  }
}
