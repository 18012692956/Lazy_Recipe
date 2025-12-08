package com.sky.lazy_recipe_backend.repository;

import com.sky.lazy_recipe_backend.model.Recipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Integer> {
    // 你可以在这里添加自定义查询方法，例如：
    // List<Recipe> findByTaste(String taste);
    // List<Recipe> findByStyle(String style);
}
