export interface Recipe {
  id: number;
  title: string;
  ingredients: string[];
  taste: string;
  style: string;
  timeMinutes: number;
  difficulty: string;
  steps: string[];
  favorite: boolean;
}
