🍳 Lazy Recipe Assistant（AI 懒人食谱助手）
===================================

一个基于 **HarmonyOS + Spring Boot** 的智能菜谱推荐系统，融合 **规则推荐算法** 与 **DeepSeek 大模型生成能力**，支持食材驱动推荐、收藏与历史记录、AI 自动生成与数据自更新。

* * *

✨ 项目特性
------

* 🧠 **规则 + AI 混合推荐**
  
  * 基于用户已有食材、口味、风格进行规则推荐
  
  * 当本地高质量候选不足时，自动调用 AI 生成新菜谱补全

* 🗂️ **三表规范化数据库设计**
  
  * 菜谱主表 / 食材表 / 步骤表分离，结构清晰、可扩展

* 🔄 **数据自动演化**
  
  * AI 每日自动生成新菜谱入库
  
  * 定期清理未收藏且长期未浏览的菜谱

* ⭐ **收藏与历史记录**
  
  * 收藏状态实时更新
  
  * 浏览历史自动记录并支持清空

* 📱 **HarmonyOS 前端**
  
  * 页面跳转清晰、交互简洁
  
  * 主流程最短化，符合“懒人做饭”使用场景

* * *

🏗️ 系统架构
--------

```context

```

* * *

🧩 后端技术栈
--------

* **Java**：17

* **Spring Boot**：4.0.0

* **Spring Data JPA / JDBC**

* **MySQL**

* **OkHttp 4.12.0**（AI 接口调用）

* **Jackson**（JSON 序列化）

* **Lombok**

* **Maven**

* * *

🎨 前端技术栈
--------

* **HarmonyOS**

* **ArkTS (ETS)**

* **DevEco Studio**

* **HTTP / JSON 通信**

* 页面组件化 + 服务封装（ApiService / HttpClient）

* * *

🗄️ 数据库设计（3 表结构）
----------------

| 表名                   | 说明                        |
| -------------------- | ------------------------- |
| `recipes`            | 菜谱基本信息（标题、口味、风格、收藏、浏览时间等） |
| `recipe_ingredients` | 菜谱-食材关联表                  |
| `recipe_steps`       | 菜谱制作步骤表（有序）               |

三张表通过 `recipe_id` 关联，符合第三范式（3NF）。

* * *

🤖 推荐算法说明
---------

### 1️⃣ 规则推荐（优先）

* 食材交集召回

* 评分规则：
  
  * 食材命中：`+3.0 / 个`
  
  * 口味匹配：`+2.0`
  
  * 风格匹配：`+1.5`
  
  * 已收藏：`+0.1`

* 高分阈值：`score >= 7.5`

* 强候选 ≥ 3 时直接返回 Top5

### 2️⃣ AI 补全（DeepSeek）

当规则候选不足时：

1. 调用 DeepSeek Chat Completions API

2. 生成结构化菜谱 JSON

3. 清洗返回内容（去 markdown / think）

4. 多维去重（标题 / 食材 / 步骤）

5. 写入数据库并参与推荐

* * *

🔁 数据自更新机制
----------

* **每日 00:05**
  
  * 基于代表菜谱特征调用 AI 生成新菜谱

* **每日 00:00**
  
  * 清理未收藏且长期未浏览的菜谱

* 数据库内容随使用自动演化，规模可控

* * *

📱 前端页面说明
---------

| 页面            | 功能         |
| ------------- | ---------- |
| PreviewPage   | 引导页 / 冷启动页 |
| HomePage      | 食材与偏好选择    |
| RecommendPage | 推荐结果展示     |
| DetailPage    | 菜谱详情、收藏、历史 |
| FavoritesPage | 收藏列表       |
| HistoryPage   | 浏览历史       |

主流程：  
**Preview → Home → Recommend → Detail**

* * *

🚀 快速开始
-------

### 1️⃣ 后端启动

`cd lazy-recipe-backendmvn spring-boot:run`

配置 `application.yml`：

```yml
spring:
   datasource:
      url: jdbc:mysql://localhost:3306/recipe_db
      username: root
      password: your_password
deepseek:
   api-key: YOUR_API_KEY
```

* * *

### 2️⃣ 前端运行

* 使用 **DevEco Studio** 打开前端项目

* 配置后端地址（模拟器）：

`http://10.0.2.2:8080/api`

* 运行到模拟器或真机

***

作者：邓泽宇
