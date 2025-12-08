package com.sky.lazy_recipe_backend.controller;

import com.sky.lazy_recipe_backend.model.Category;
import com.sky.lazy_recipe_backend.model.IngredientCategory;
import com.sky.lazy_recipe_backend.model.Recipe;
import com.sky.lazy_recipe_backend.model.RecommendRequest;
import com.sky.lazy_recipe_backend.service.DataService;
import com.sky.lazy_recipe_backend.service.RecommendService;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * API 控制层
 *
 * 当前迭代提供以下功能：
 *  - 获取食材列表（多级结构）
 *  - 获取口味与菜系选项
 *  - 获取调料列表
 *  - 根据用户选择食材推荐菜谱（伪AI版本）
 *  - 收藏菜谱 & 查看收藏
 *
 * TODO Iteration 3:
 *  - 将推荐逻辑替换为 AI 大模型服务（DeepSeek / Moonshot / GLM 等）
 */
@RestController
@RequestMapping("/api")
@CrossOrigin // 允许 HarmonyOS 前端访问
public class ApiController {

    private final DataService dataService;
    private final RecommendService recommendService;

    public ApiController(DataService dataService, RecommendService recommendService) {
        this.dataService = dataService;
        this.recommendService = recommendService;
    }

    /**
     * 获取所有可选食材（多级结构）
     * GET /api/ingredients
     */
    @GetMapping("/ingredients")
    public Map<Category, List<IngredientCategory>> getIngredients() {
        return dataService.getIngredients();
    }


    /**
     * 获取调料列表（独立分类）
     * GET /api/seasonings
     */
    @GetMapping("/seasonings")
    public List<String> getSeasonings() {
        return dataService.getSeasonings();
    }

    /**
     * 获取口味 + 菜系选项
     * GET /api/preferences
     */
    @GetMapping("/preferences")
    public Map<String, List<String>> getPreferences() {
        return Map.of(
                "tastes", dataService.getTastes(),
                "styles", dataService.getStyles()
        );
    }

    /**
     * 推荐菜谱（伪AI版本）
     * POST /api/recommend
     */
    @PostMapping("/recommend")
    public List<Recipe> recommend(@RequestBody RecommendRequest req) {
        return recommendService.recommend(req);
    }

    /**
     * 获取收藏列表
     * GET /api/favorites
     */
    @GetMapping("/favorites")
    public List<Recipe> getFavorites() {
        return dataService.getFavorites();
    }

    /**
     * 收藏菜谱
     * POST /api/favorites
     */
    @PostMapping("/favorites")
    public String addFavorite(@RequestBody Recipe recipe) {
        dataService.addFavorite(recipe);
        return "OK";
    }
}
