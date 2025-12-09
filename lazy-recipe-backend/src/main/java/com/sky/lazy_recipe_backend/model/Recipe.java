package com.sky.lazy_recipe_backend.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "recipes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Recipe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;  // 使用 Integer 更符合 JPA 标准

    private String title;

    @ElementCollection
    @CollectionTable(name = "recipe_ingredients", joinColumns = @JoinColumn(name = "recipe_id"))
    @Column(name = "ingredient")
    private List<String> ingredients;

    private String taste;
    private String style;
    private Integer timeMinutes;
    private String difficulty;

    @ElementCollection
    @CollectionTable(name = "recipe_steps", joinColumns = @JoinColumn(name = "recipe_id"))
    @Column(name = "step")
    private List<String> steps;

    // Getter & Setter
    @Setter
    @Getter
    @Column(nullable = false)
    private boolean favorite = false;

//    @Column(name = "last_viewed_at", columnDefinition = "DATETIME DEFAULT NULL")
//    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
//    private LocalDateTime lastViewedAt = null;
}
