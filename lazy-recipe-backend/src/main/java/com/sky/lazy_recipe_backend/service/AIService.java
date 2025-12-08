package com.sky.lazy_recipe_backend.service;

import org.springframework.beans.factory.annotation.Value;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import com.sky.lazy_recipe_backend.model.Recipe;
import okhttp3.*;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.List;

@Service
public class AIService {

    private static final String API_URL = "https://api.deepseek.com/v1/chat/completions";
    @Value("${deepseek.api-key}")
    private String API_KEY;


    private final OkHttpClient client = new OkHttpClient();
    private final ObjectMapper mapper = new ObjectMapper();

    public Recipe generateRecipe(List<String> ingredients, String taste, String style) {
        String prompt = """
                你是一个专业厨师，请根据以下要求生成一个菜谱：
                
                食材：%s
                口味：%s
                风格：%s
                
                请严格输出以下 JSON 格式：
                {
                  "title": "...",
                  "ingredients": ["...", "..."],
                  "taste": "...",
                  "style": "...",
                  "timeMinutes": 15,
                  "difficulty": "简单",
                  "steps": ["步骤1", "步骤2", "步骤3"]
                }
                """.formatted(
                String.join(", ", ingredients),
                taste,
                style
        );

        try {
            // 构造 JSON body
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

            // 获取 AI 输出文本
            String result = response.body().string();
            JsonNode root = mapper.readTree(result);

            String content = root
                    .get("choices").get(0)
                    .get("message")
                    .get("content")
                    .asText();

            // content 是一个 JSON 菜谱 → 转成 Recipe
            return mapper.readValue(content, Recipe.class);

        } catch (IOException e) {
            throw new RuntimeException("AI 请求出错", e);
        }
    }
}
