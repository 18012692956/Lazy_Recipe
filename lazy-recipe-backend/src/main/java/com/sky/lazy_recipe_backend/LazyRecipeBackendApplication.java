package com.sky.lazy_recipe_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class LazyRecipeBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(LazyRecipeBackendApplication.class, args);
	}

}
