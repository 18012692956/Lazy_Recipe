package com.sky.lazy_recipe_backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sky.lazy_recipe_backend.model.Recipe;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
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

                请严格输出以下 **纯 JSON**（不要使用 ```json 代码块）：

                {
                  "title": "菜名",
                  "ingredients": ["食材1", "食材2"],
                  "taste": "口味",
                  "style": "风格",
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

            // 获取 AI 返回的文本
            String rawResult = response.body().string();
            JsonNode root = mapper.readTree(rawResult);

            String content = root
                    .get("choices").get(0)
                    .get("message")
                    .get("content")
                    .asText();

            // ========= 清理 AI 输出（核心修复）=========
            String cleanJson = cleanupJson(content);

            // ========= 将清理后的 JSON 转为 Recipe =========
            return mapper.readValue(cleanJson, Recipe.class);

        } catch (IOException e) {
            throw new RuntimeException("AI 请求出错", e);
        }
    }


    /**
     * 清洗 AI 输出：
     * - 去掉 ```json 和 ```
     * - 去掉思维链（reasoning）
     * - 仅保留最外层完整 JSON
     */
    private String cleanupJson(String raw) {
        if (raw == null) return "";

        String cleaned = raw.trim();

        // 去掉 markdown 代码块
        cleaned = cleaned.replace("```json", "")
                .replace("```", "")
                .trim();

        // 去掉 DeepSeek 可能输出的 <think> 思维链内容
        if (cleaned.contains("<think>")) {
            int end = cleaned.lastIndexOf("</think>");
            if (end != -1) {
                cleaned = cleaned.substring(end + "</think>".length()).trim();
            }
        }

        // 只截取第一个 { 到 最后一个 }
        int start = cleaned.indexOf("{");
        int end = cleaned.lastIndexOf("}");

        if (start >= 0 && end > start) {
            cleaned = cleaned.substring(start, end + 1);
        }

        return cleaned.trim();
    }
}
