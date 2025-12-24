package com.sky.lazy_recipe_backend.scheduler;

import com.sky.lazy_recipe_backend.service.DataService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class RecipeUpdateScheduler {

    private final DataService dataService;

    /**
     * 每天凌晨 00:05 点执行
     */
    @Scheduled(cron = "0 5 0 * * ?")
    public void scheduleUpdate() {
        dataService.updateDailyRecipes();
    }

//    /**
//     * 测试每分钟更新
//     */
//    @Scheduled(cron = "0 * * * * ?")
//    public void scheduleUpdate() {
//        dataService.updateDailyRecipes();
//    }
}