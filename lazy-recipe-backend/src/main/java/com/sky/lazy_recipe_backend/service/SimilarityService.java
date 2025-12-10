package com.sky.lazy_recipe_backend.service;

import com.sky.lazy_recipe_backend.model.Recipe;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class SimilarityService {

    public boolean isDuplicate(Recipe newRecipe, List<Recipe> existingRecipes) {
        for (Recipe existing : existingRecipes) {
            if (existing.getTitle().equalsIgnoreCase(newRecipe.getTitle())) {
                return true;
            }

            if (jaccardSimilarity(existing.getIngredients(), newRecipe.getIngredients()) > 0.8) {
                return true;
            }

            if (existing.getTaste().equalsIgnoreCase(newRecipe.getTaste())
                    && existing.getStyle().equalsIgnoreCase(newRecipe.getStyle())
                    && stepsSimilarity(existing.getSteps(), newRecipe.getSteps()) > 0.85) {
                return true;
            }
        }
        return false;
    }

    public double jaccardSimilarity(List<String> a, List<String> b) {
        Set<String> setA = new HashSet<>(a);
        Set<String> setB = new HashSet<>(b);
        Set<String> intersection = new HashSet<>(setA);
        intersection.retainAll(setB);
        Set<String> union = new HashSet<>(setA);
        union.addAll(setB);
        return union.isEmpty() ? 0 : (double) intersection.size() / union.size();
    }

    public double stepsSimilarity(List<String> a, List<String> b) {
        String aText = String.join(",", a).toLowerCase();
        String bText = String.join(",", b).toLowerCase();
        return cosineSimilarity(aText, bText);
    }

    private double cosineSimilarity(String a, String b) {
        Map<String, Integer> freqA = wordFreq(a);
        Map<String, Integer> freqB = wordFreq(b);

        Set<String> allWords = new HashSet<>();
        allWords.addAll(freqA.keySet());
        allWords.addAll(freqB.keySet());

        int dot = 0;
        int magA = 0;
        int magB = 0;

        for (String word : allWords) {
            int va = freqA.getOrDefault(word, 0);
            int vb = freqB.getOrDefault(word, 0);
            dot += va * vb;
            magA += va * va;
            magB += vb * vb;
        }

        return (magA == 0 || magB == 0) ? 0 : dot / (Math.sqrt(magA) * Math.sqrt(magB));
    }

    private Map<String, Integer> wordFreq(String text) {
        Map<String, Integer> freq = new HashMap<>();
        for (String word : text.split("[,\\s]+")) {
            freq.put(word, freq.getOrDefault(word, 0) + 1);
        }
        return freq;
    }

    /**
     * 从代表菜中提取：
     * 1. 最常见口味（1 个）
     * 2. 最常见风格（1 个）
     * 3. 高频食材（5 个以内）
     * 4. 菜名列表（用于避免 AI 重复）
     */
    public Map<String, Object> extractRecipeFeatures(List<Recipe> recipes) {

        Map<String, Integer> tasteCount = new HashMap<>();
        Map<String, Integer> styleCount = new HashMap<>();
        Map<String, Integer> ingredientCount = new HashMap<>();
        List<String> titles = new ArrayList<>();

        for (Recipe r : recipes) {

            // 1. 统计 taste
            if (r.getTaste() != null) {
                tasteCount.put(r.getTaste(), tasteCount.getOrDefault(r.getTaste(), 0) + 1);
            }

            // 2. 统计 style
            if (r.getStyle() != null) {
                styleCount.put(r.getStyle(), styleCount.getOrDefault(r.getStyle(), 0) + 1);
            }

            // 3. 汇总 ingredients
            if (r.getIngredients() != null) {
                for (String ingredient : r.getIngredients()) {
                    ingredientCount.put(
                            ingredient,
                            ingredientCount.getOrDefault(ingredient, 0) + 1
                    );
                }
            }

            titles.add(r.getTitle());
        }

        // 选出最常见 taste & style
        String topTaste = tasteCount.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);

        String topStyle = styleCount.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);

        // 选出频率最高的前 5 个 ingredients
        List<String> topIngredients = ingredientCount.entrySet().stream()
                .sorted((a, b) -> b.getValue() - a.getValue())
                .limit(5)
                .map(Map.Entry::getKey)
                .toList();

        Map<String, Object> result = new HashMap<>();
        result.put("taste", topTaste);
        result.put("style", topStyle);
        result.put("ingredients", topIngredients);
        result.put("titles", titles);
        return result;
    }
}
