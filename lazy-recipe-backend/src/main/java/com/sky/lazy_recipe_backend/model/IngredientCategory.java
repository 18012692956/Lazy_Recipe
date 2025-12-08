package com.sky.lazy_recipe_backend.model;

import java.util.List;

public class IngredientCategory {
    private String subcategory; // 如“猪肉”、“鱼类”
    private List<String> ingredients; // 该子类下的食材名

    public IngredientCategory(String name, List<String> ingredients) {
        this.subcategory = name;
        this.ingredients = ingredients;
    }

    public String getSubcategory() {
        return subcategory;
    }

    public void setSubcategory(String subcategory) {
        this.subcategory = subcategory;
    }

    public List<String> getIngredients() {
        return ingredients;
    }

    public void setIngredients(List<String> ingredients) {
        this.ingredients = ingredients;
    }
}
