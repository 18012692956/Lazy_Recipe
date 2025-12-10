package com.sky.lazy_recipe_backend.scheduler;

import com.sky.lazy_recipe_backend.service.DataService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class RecipeCleanupScheduler {

    private final DataService dataService;

    /**
     * 每天凌晨 00:00 点执行
     */
    @Scheduled(cron = "0 0 0 * * ?")
    public void scheduledClean() {
        log.info("定时任务启动：清理菜谱");
        dataService.cleanOldRecipes(1); // 1 天未浏览 + 未收藏 → 删除
    }
}
