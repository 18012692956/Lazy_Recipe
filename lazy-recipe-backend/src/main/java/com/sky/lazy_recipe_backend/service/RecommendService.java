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
    private final SimilarityService similarityService;

    public RecommendService(DataService dataService, AIService aiService) {
        this.dataService = dataService;
        this.aiService = aiService;
        this.similarityService = new SimilarityService();
    }

    public List<Recipe> recommend(RecommendRequest req) {
        List<Recipe> localMatches = ruleBasedRecommend(req);

        // 高于 AI 标准分的本地候选
        final double AI_SCORE_STANDARD = 4.5;
        List<Recipe> strongLocals = localMatches.stream()
                .filter(r -> score(r, req) >= AI_SCORE_STANDARD)
                .collect(Collectors.toList());

        if (strongLocals.size() >= 3) {
            return strongLocals.stream()
                    .sorted((a, b) -> Double.compare(score(b, req), score(a, req)))
                    .limit(5)
                    .collect(Collectors.toList());
        }

        // 不足 → 补充 AI 菜谱（先查重）
        List<Recipe> aiGenerated = aiService.generateRecipes(
                req.getIngredients(),
                req.getTaste(),
                req.getStyle()
        );

        List<Recipe> existing = dataService.getRecipes();

        List<Recipe> filteredAI = aiGenerated.stream()
                .filter(r -> !similarityService.isDuplicate(r, existing))
                .collect(Collectors.toList());

        // 只保存不重复的
        filteredAI.forEach(dataService::addRecipe);

        // 合并并排序
        List<Recipe> allCandidates = new ArrayList<>(strongLocals);
        allCandidates.addAll(filteredAI);

        return allCandidates.stream()
                .sorted((a, b) -> Double.compare(score(b, req), score(a, req)))
                .limit(5)
                .collect(Collectors.toList());

    }

    private List<Recipe> ruleBasedRecommend(RecommendRequest req) {
        List<String> userIngredients = req.getIngredients();

        return dataService.getRecipes().stream()
                .filter(r -> r.getIngredients().stream().anyMatch(userIngredients::contains))
                .collect(Collectors.toList());
    }

    /**
     * 匹配评分：
     * - 食材匹配：每个匹配 +3.0（主权重）
     * - 口味匹配：+2.0
     * - 菜系匹配：+1.5
     * - 收藏加分：+0.1
     */
    private double score(Recipe r, RecommendRequest req) {
        double score = 0.0;

        long matchCount = r.getIngredients().stream()
                .filter(req.getIngredients()::contains)
                .count();
        score += matchCount * 3.0;

        if (req.getTaste().isEmpty() || r.getTaste().equals(req.getTaste())) score += 2.0;
        if (req.getStyle().isEmpty() || r.getStyle().equals(req.getStyle())) score += 1.5;
        if (r.isFavorite()) score += 0.1;

        return score;
    }
}
