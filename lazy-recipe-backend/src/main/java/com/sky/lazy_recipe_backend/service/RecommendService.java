package com.sky.lazy_recipe_backend.service;

import com.sky.lazy_recipe_backend.model.Recipe;
import com.sky.lazy_recipe_backend.model.RecommendRequest;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class RecommendService {

    private final DataService dataService;
    private final AIService aiService;   // ★ 新增：AI 服务

    public RecommendService(DataService dataService, AIService aiService) {
        this.dataService = dataService;
        this.aiService = aiService;
    }

    /**
     * 获取推荐菜谱
     * 1) 规则匹配
     * 2) 不足时调用 AI 自动补全
     */
    public List<Recipe> recommend(RecommendRequest req) {
        List<Recipe> baseCandidates = ruleBasedRecommend(req);

        // ========= AI 兜底增强 =========
        if (baseCandidates.size() < 2) {
            Recipe aiRecipe = aiService.generateRecipe(
                    req.getIngredients(),
                    req.getTaste(),
                    req.getStyle()
            );
            baseCandidates.add(aiRecipe);
        }

        return baseCandidates;
    }

    /**
     * 规则匹配推荐
     */
    private List<Recipe> ruleBasedRecommend(RecommendRequest req) {
        List<String> userIngredients = req.getIngredients();

        return dataService.getRecipes().stream()
                .filter(recipe -> isIngredientMatched(recipe, userIngredients))
                .sorted((a, b) -> Integer.compare(score(b, req), score(a, req)))
                .limit(5)
                .collect(Collectors.toList());
    }

    /**
     * 至少一个匹配食材
     */
    private boolean isIngredientMatched(Recipe recipe, List<String> userIngredients) {
        return recipe.getIngredients().stream()
                .anyMatch(userIngredients::contains);
    }

    /**
     * 推荐评分
     */
    private int score(Recipe r, RecommendRequest req) {
        int score = 0;

        long matches = r.getIngredients().stream()
                .filter(req.getIngredients()::contains)
                .count();
        score += matches * 2;

        if (r.getTaste().equals(req.getTaste())) score += 3;
        if (r.getStyle().equals(req.getStyle())) score += 3;

        return score;
    }
}
