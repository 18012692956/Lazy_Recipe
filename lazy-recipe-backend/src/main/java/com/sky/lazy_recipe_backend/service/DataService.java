package com.sky.lazy_recipe_backend.service;

import com.sky.lazy_recipe_backend.model.Category;
import com.sky.lazy_recipe_backend.model.IngredientCategory;
import com.sky.lazy_recipe_backend.model.Recipe;
import com.sky.lazy_recipe_backend.repository.RecipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class DataService {

    @Autowired
    private RecipeRepository recipeRepository;

    // ---------- 多级食材结构（仍内存） ----------
    private static final Map<Category, List<IngredientCategory>> INGREDIENTS = new LinkedHashMap<>();

    // ---------- 调料 ----------
    private static final List<String> SEASONINGS = List.of(
            "食盐", "酱油", "食醋", "料酒", "蚝油", "番茄酱",
            "胡椒粉", "辣椒粉", "五香粉", "花椒", "八角", "鸡精", "味精"
    );

    // ---------- 用户口味选项 ----------
    private static final List<String> TASTES = List.of(
            "清淡", "咸香", "微辣", "重辣", "酸甜", "香辣", "麻辣", "鲜香"
    );

    // ---------- 菜系风格 ----------
    private static final List<String> STYLES = List.of(
            "家常菜", "快手菜", "健康减脂", "川菜", "粤菜", "湘菜", "东北菜", "西北菜", "本帮菜", "日式料理", "韩式料理"
    );

    // ---------- 收藏（可选：仍为内存） ----------
    private static final List<Recipe> FAVORITES = new ArrayList<>();

    static {
        // 主食
        INGREDIENTS.put(Category.STAPLE, List.of(
                new IngredientCategory("米类", List.of("大米", "糯米", "黑米", "小米")),
                new IngredientCategory("面类", List.of("面条", "面粉", "意面", "馒头", "饺子皮")),
                new IngredientCategory("杂粮", List.of("玉米粒", "燕麦", "荞麦", "红豆", "绿豆"))
        ));

        // 蔬菜
        INGREDIENTS.put(Category.VEGETABLE, List.of(
                new IngredientCategory("叶菜类", List.of("菠菜", "油麦菜", "生菜", "小白菜")),
                new IngredientCategory("根茎类", List.of("土豆", "胡萝卜", "山药", "莲藕")),
                new IngredientCategory("茄瓜类", List.of("茄子", "黄瓜", "西红柿", "苦瓜", "冬瓜", "南瓜")),
                new IngredientCategory("葱姜蒜类", List.of("大葱", "洋葱", "大蒜", "生姜", "小米椒")),
                new IngredientCategory("豆类蔬菜", List.of("四季豆", "毛豆", "豌豆")),
                new IngredientCategory("菌菇类", List.of("香菇", "金针菇", "平菇", "木耳", "杏鲍菇"))
        ));

        // 肉类
        INGREDIENTS.put(Category.MEAT, List.of(
                new IngredientCategory("猪肉", List.of("五花肉", "猪里脊", "猪排骨", "猪蹄", "猪肚", "猪血")),
                new IngredientCategory("牛肉", List.of("牛腩", "牛里脊", "牛肋条", "牛腱子", "肥牛片")),
                new IngredientCategory("羊肉", List.of("羊排", "羊腿", "羊肉片", "羊蝎子")),
                new IngredientCategory("鸡肉", List.of("鸡胸肉", "鸡腿", "鸡翅", "鸡肝", "整鸡")),
                new IngredientCategory("鸭肉", List.of("鸭腿", "鸭胸", "鸭掌", "鸭血"))
        ));

        // 水产
        INGREDIENTS.put(Category.SEAFOOD, List.of(
                new IngredientCategory("鱼类", List.of("鲈鱼", "草鱼", "鲫鱼", "三文鱼", "鳕鱼")),
                new IngredientCategory("虾蟹贝", List.of("基围虾", "龙虾", "螃蟹", "蛤蜊", "花甲", "扇贝")),
                new IngredientCategory("其他", List.of("海带", "紫菜", "鱿鱼", "章鱼"))
        ));

        // 蛋奶
        INGREDIENTS.put(Category.EGG_DAIRY, List.of(
                new IngredientCategory("蛋类", List.of("鸡蛋", "鸭蛋", "鹌鹑蛋")),
                new IngredientCategory("乳类", List.of("牛奶", "酸奶", "奶酪", "黄油"))
        ));

        // 豆制品
        INGREDIENTS.put(Category.BEAN_PRODUCT, List.of(
                new IngredientCategory("豆类", List.of("黄豆", "绿豆", "黑豆", "红豆")),
                new IngredientCategory("制品", List.of("豆腐", "豆腐皮", "豆腐干", "腐竹", "豆浆"))
        ));

    }

    public Map<Category, List<IngredientCategory>> getIngredients() {
        return INGREDIENTS;
    }

    public List<String> getSeasonings() {
        return SEASONINGS;
    }

    public List<String> getTastes() {
        return TASTES;
    }

    public List<String> getStyles() {
        return STYLES;
    }

    // ✅ 数据库读取菜谱
    public List<Recipe> getRecipes() {
        return recipeRepository.findAll();
    }

    // ✅ 添加菜谱到数据库
    public void addRecipe(Recipe recipe) {
        recipeRepository.save(recipe);
    }

    public List<Recipe> getFavorites() {
        return recipeRepository.findAll().stream()
                .filter(Recipe::isFavorite)
                .toList();
    }


    public void updateFavorite(int recipeId) {
        Optional<Recipe> optional = recipeRepository.findById(recipeId);
        optional.ifPresent(recipe -> {
            recipe.setFavorite(!recipe.isFavorite());
            recipeRepository.save(recipe);
        });
    }

}

