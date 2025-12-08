package com.sky.lazy_recipe_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration;

@SpringBootApplication
public class LazyRecipeBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(LazyRecipeBackendApplication.class, args);
	}

}
