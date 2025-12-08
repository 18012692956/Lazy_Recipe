export interface SubIngredientCategory {
  subcategory: string;
  ingredients: string[];
}

export interface IngredientCategory {
  category: string;
  subcategories: SubIngredientCategory[];
}

export type IngredientsMap = Record<string, SubIngredientCategory[]>;
