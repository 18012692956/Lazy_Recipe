package com.sky.lazy_recipe_backend.repository;

import com.sky.lazy_recipe_backend.model.Recipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Integer> {
    /**
     * ✅ 查询最近浏览的菜谱（按时间倒序）
     */
    List<Recipe> findByLastViewedAtAfterOrderByLastViewedAtDesc(LocalDateTime time);

    List<Recipe> findTop3ByOrderByIdDesc();

    /**
     * ✅ 或者使用自定义查询，限制返回数量
     */
    @Query("SELECT r FROM Recipe r WHERE r.lastViewedAt IS NOT NULL " +
            "ORDER BY r.lastViewedAt DESC")
    List<Recipe> findRecentlyViewed();

    /**
     * ✅ 清空所有浏览历史
     */
    @Modifying
    @Query("UPDATE Recipe r SET r.lastViewedAt = NULL")
    void clearAllViewHistory();

    @Query("""
       SELECT r FROM Recipe r
       WHERE (r.lastViewedAt IS NULL OR r.lastViewedAt < :expireTime)
       AND r.favorite = false
       """)
    List<Recipe> findUnusedAndUnfavorited(LocalDateTime expireTime);

    @Query("""
       SELECT r FROM Recipe r WHERE r.favorite = true
       """)
    List<Recipe> findByFavoriteTrue();

    // 你可以在这里添加自定义查询方法，例如：
    // List<Recipe> findByTaste(String taste);
    // List<Recipe> findByStyle(String style);
}
