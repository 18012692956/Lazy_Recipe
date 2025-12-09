export interface RecommendRequest {
  ingredients: string[];
  taste: string;
  style: string;
}

export interface DefaultRequest {
  recipe_id: number;
}
