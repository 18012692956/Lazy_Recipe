package com.sky.lazy_recipe_backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 菜谱类（Recipe）
 *
 * 当前迭代中 ingredients 使用 String 列表，便于前端直接展示。
 * 未来迭代将切换为 Ingredient 列表，以支持数据库、营养标签等扩展。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Recipe {
    private int id;                     // 菜谱ID
    private String title;               // 菜名
    private List<String> ingredients;   // 当前迭代：使用字符串表示食材

    // TODO Iteration 2:
    // private List<Ingredient> ingredientList;

    private String taste;               // 口味（清淡、微辣等）
    private String style;               // 菜系（家常菜、快手菜等）
    private int timeMinutes;            // 烹饪时间（分钟）
    private String difficulty;          // 难度（简单、中等）

    private List<String> steps;         // 制作步骤

    // TODO Iteration 3: 添加 thumbnail 图片URL
}
