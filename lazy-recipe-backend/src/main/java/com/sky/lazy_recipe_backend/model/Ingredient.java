package com.sky.lazy_recipe_backend.model;

import lombok.Data;

/**
 * 食材类（迭代预留版本）
 *
 * 当前迭代中，系统仍使用字符串作为食材表示。
 * 本类用于未来迭代实现数据库持久化、食材属性管理、营养信息等功能。
 */
@Data
public class Ingredient {
    private Long id;            // 食材唯一ID（未来数据库使用）
    private String name;        // 食材名称，例如“鸡胸肉”
    private String category;    // 食材分类，如“meat”“vegetable”

    // TODO Iteration 2: 添加营养成分字段（calories, protein 等）
    // TODO Iteration 3: 添加图片字段 iconUrl
}
