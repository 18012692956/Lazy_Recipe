package com.sky.lazy_recipe_backend.model;

import lombok.Data;
import java.util.List;

/**
 * 用户请求推荐菜谱的请求体模型
 */
@Data
public class RecommendRequest {

    // 用户已有食材（当前迭代为字符串列表）
    private List<String> ingredients;

    private String taste;     // 用户选择的口味
    private String style;     // 用户选择的菜系风格

    // TODO Iteration 2: 支持用户偏好记录（如“低脂”“高蛋白”）
}
