package com.sky.lazy_recipe_backend.service;

import com.sky.lazy_recipe_backend.model.Recipe;
import com.sky.lazy_recipe_backend.model.RecommendRequest;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class RecommendService {

    private final DataService dataService;
    private final AIService aiService;

    public RecommendService(DataService dataService, AIService aiService) {
        this.dataService = dataService;
        this.aiService = aiService;
    }

    /**
     * 推荐菜谱（本地匹配 → AI 兜底）
     */
    public List<Recipe> recommend(RecommendRequest req) {

        // ① 本地规则推荐
        List<Recipe> candidates = ruleBasedRecommend(req);

        if (!candidates.isEmpty()) {
            return candidates; // 本地命中直接返回
        }

        // ② 本地为空 → 调用 AI 生成菜谱
        Recipe aiRecipe = aiService.generateRecipe(
                req.getIngredients(),
                req.getTaste(),
                req.getStyle()
        );

        // ③ 存入本地菜谱库（关键步骤）
        dataService.addRecipe(aiRecipe);

        // ④ 返回 AI 生成的菜谱
        return List.of(aiRecipe);
    }

    /**
     * 规则匹配推荐（本地列表）
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
     * 至少一个食材匹配
     */
    private boolean isIngredientMatched(Recipe recipe, List<String> userIngredients) {
        return recipe.getIngredients().stream()
                .anyMatch(userIngredients::contains);
    }

    /**
     * 简单评分算法
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
