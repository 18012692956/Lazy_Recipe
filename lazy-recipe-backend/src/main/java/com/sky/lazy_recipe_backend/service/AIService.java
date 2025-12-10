package com.sky.lazy_recipe_backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sky.lazy_recipe_backend.model.Recipe;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.*;

@Service
public class AIService {

    private static final String API_URL = "https://api.deepseek.com/v1/chat/completions";

    @Value("${deepseek.api-key}")
    private String API_KEY;

    private final OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(15, java.util.concurrent.TimeUnit.SECONDS)  // 连接超时
            .readTimeout(60, java.util.concurrent.TimeUnit.SECONDS)     // 读取响应最大等待时间（建议 60 秒）
            .writeTimeout(60, java.util.concurrent.TimeUnit.SECONDS)    // 写入数据最大等待时间
            .build();


    private final ObjectMapper mapper = new ObjectMapper();

    public List<Recipe> generateRecipes(List<String> titles, List<String> ingredients, String taste, String style, Boolean update) {
        String prompt = update ? buildUpdatePrompt(titles, ingredients, taste, style) : buildRecommendPrompt(ingredients, taste, style);

        try {
            String bodyJson = mapper.writeValueAsString(
                    mapper.createObjectNode()
                            .put("model", "deepseek-chat")
                            .set("messages", mapper.createArrayNode().add(
                                    mapper.createObjectNode()
                                            .put("role", "user")
                                            .put("content", prompt)
                            ))
            );

            Request request = new Request.Builder()
                    .url(API_URL)
                    .addHeader("Authorization", "Bearer " + API_KEY)
                    .addHeader("Content-Type", "application/json")
                    .post(RequestBody.create(bodyJson, MediaType.parse("application/json")))
                    .build();

            Response response = client.newCall(request).execute();
            if (!response.isSuccessful()) {
                throw new RuntimeException("AI 调用失败: " + response);
            }

            String rawResult = response.body().string();
            JsonNode root = mapper.readTree(rawResult);
            String content = root
                    .get("choices").get(0)
                    .get("message")
                    .get("content")
                    .asText();

            String cleanJson = cleanupJson(content);

            // 返回多个 Recipe
            return Arrays.asList(mapper.readValue(cleanJson, Recipe[].class));

        } catch (IOException e) {
            throw new RuntimeException("AI 请求出错", e);
        }
    }

    private String buildRecommendPrompt(List<String> ingredients, String taste, String style) {
        return """
        你是一个专业厨师助手，请根据用户提供的食材、口味和菜系风格，生成多道适合家庭的中式菜谱。

        要求：
        - 如果食材较少（少于 5 种），可以使用不同搭配做出多种做法。
        - 如果食材很多，请合理拆分，生成多道不同的菜品，每道菜使用 2–6 种食材，无需覆盖全部食材。
        - 每道菜可包含 3–8 步操作，结构合理、通顺自然。
        - 菜名简洁明了，步骤清晰，整体符合家庭日常烹饪习惯。
        - 所有菜品尽量风格不重复，体现口味与菜系多样性。

        用户输入：
        - 食材：%s
        - 口味：%s
        - 风格：%s

        请以 JSON 数组形式返回 **3 个菜谱对象**（不使用 markdown 代码块、不包含解释说明），格式如下：

        [
          {
            "title": "菜名",
            "ingredients": ["食材1", "食材2", "食材3", "..."],
            "taste": "口味",
            "style": "风格",
            "timeMinutes": 20,
            "difficulty": "中等",
            "steps": [
              "第一步操作",
              "第二步操作",
              "...",
              "最后一步操作"
            ]
          },
          ...
        ]
        """.formatted(
                String.join(", ", ingredients),
                taste.isEmpty() ? "清淡" : taste,
                style.isEmpty() ? "家常菜" : style
        );
    }

    private String buildUpdatePrompt(List<String> existingTitles, List<String> ingredients, String taste, String style) {
        return """
        你是一个专业厨师助手，请根据用户提供的食材、口味和菜系风格，生成多道适合家庭的中式菜谱。

        要求：
        - 如果食材较少（少于 2 种），可以使用不同搭配做出多种做法。
        - 如果食材很多，请合理拆分，生成多道不同的菜品，每道菜使用 2–3 种食材，无需覆盖全部食材。
        - 每道菜可包含 3–8 步操作，结构合理、通顺自然。
        - 菜名简洁明了，步骤清晰，整体符合家庭日常烹饪习惯。
        - 所有菜品尽量风格不重复，体现口味与菜系多样性。
        
        食材：%s
        口味：%s
        风格：%s

        以下菜名是用户已经收藏/浏览过的，请确保生成的菜谱 '不与这些菜名重复，也不相似'：
        已存在菜名：%s

        请以 JSON 数组形式返回 **3 个菜谱对象**（不使用 markdown 代码块、不包含解释说明），格式如下：

        [
          {
            "title": "菜名",
            "ingredients": ["食材1", "食材2", "食材3", "..."],
            "taste": "口味",
            "style": "风格",
            "timeMinutes": 20,
            "difficulty": "中等",
            "steps": [
              "第一步操作",
              "第二步操作",
              "...",
              "最后一步操作"
            ]
          },
          ...
        ]
        """.formatted(
                    String.join(", ", ingredients),
                    String.join(", ", taste),
                    String.join(", ", style),
                    String.join(", ", existingTitles)
        );
    }

    private String cleanupJson(String raw) {
        if (raw == null) return "";

        String cleaned = raw.trim();
        cleaned = cleaned.replace("```json", "").replace("```", "").trim();

        if (cleaned.contains("<think>")) {
            int end = cleaned.lastIndexOf("</think>");
            if (end != -1) {
                cleaned = cleaned.substring(end + "</think>".length()).trim();
            }
        }

        int start = cleaned.indexOf("[");
        int end = cleaned.lastIndexOf("]");
        if (start >= 0 && end > start) {
            cleaned = cleaned.substring(start, end + 1);
        }

        return cleaned.trim();
    }
}
