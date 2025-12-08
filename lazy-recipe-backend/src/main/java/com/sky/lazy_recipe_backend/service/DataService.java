package com.sky.lazy_recipe_backend.service;

import com.sky.lazy_recipe_backend.model.Recipe;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 数据服务层
 * 当前迭代使用内存结构模拟数据库，便于快速开发。
 *
 * TODO Iteration 2:
 *   - 将数据迁移到数据库（MySQL / MongoDB）
 *   - Ingredient 替换为数据库实体
 */
@Service
public class DataService {

    // ---------- 食材（按分类） ----------
    private static final Map<String, List<String>> INGREDIENTS = new HashMap<>();

    // ---------- 用户口味选项 ----------
    private static final List<String> TASTES = List.of(
            "清淡", "咸香", "微辣", "重辣", "酸甜"
    );

    // ---------- 菜系风格 ----------
    private static final List<String> STYLES = List.of(
            "家常菜", "川菜", "粤菜", "快手菜", "健康减脂"
    );

    // ---------- 本地内置菜谱（伪数据库） ----------
    private static final List<Recipe> RECIPES = new ArrayList<>();

    // ---------- 收藏记录 ----------
    private static final List<Recipe> FAVORITES = new ArrayList<>();


    // 静态初始化（模拟数据库）
    static {
        INGREDIENTS.put("meat", List.of("鸡胸肉", "牛肉", "猪肉", "虾仁"));
        INGREDIENTS.put("vegetables", List.of("西红柿", "土豆", "青椒", "胡萝卜", "西兰花"));
        INGREDIENTS.put("staple", List.of("鸡蛋", "豆腐", "米饭", "面条"));

        // -------------------- 第1个菜谱 --------------------
        Recipe r1 = new Recipe();
        r1.setId(1);
        r1.setTitle("西红柿炒鸡蛋");
        r1.setIngredients(List.of("西红柿", "鸡蛋"));
        r1.setTaste("咸香");
        r1.setStyle("家常菜");
        r1.setTimeMinutes(10);
        r1.setDifficulty("简单");
        r1.setSteps(List.of("打蛋", "炒蛋", "炒番茄", "合并翻炒"));
        RECIPES.add(r1);

        // -------------------- 第2个菜谱 --------------------
        Recipe r2 = new Recipe();
        r2.setId(2);
        r2.setTitle("青椒炒肉丝");
        r2.setIngredients(List.of("青椒", "猪肉"));
        r2.setTaste("微辣");
        r2.setStyle("川菜");
        r2.setTimeMinutes(15);
        r2.setDifficulty("简单");
        r2.setSteps(List.of("切肉丝", "切青椒", "热锅翻炒"));
        RECIPES.add(r2);
    }


    // -------------------- 对外提供数据访问 API --------------------

    public Map<String, List<String>> getIngredients() {
        return INGREDIENTS;
    }

    public List<String> getTastes() {
        return TASTES;
    }

    public List<String> getStyles() {
        return STYLES;
    }

    public List<Recipe> getRecipes() {
        return RECIPES;
    }

    // 收藏管理
    public List<Recipe> getFavorites() {
        return FAVORITES;
    }

    public void addFavorite(Recipe recipe) {
        FAVORITES.add(recipe);
    }
}
