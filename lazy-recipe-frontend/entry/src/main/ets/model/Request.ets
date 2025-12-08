export interface RecommendRequest {
  ingredients: string[];
  taste: string;
  style: string;
}

export interface FavoriteRequest {
  recipe_id: number;
}
