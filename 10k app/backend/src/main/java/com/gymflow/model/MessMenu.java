package com.gymflow.model;

import com.gymflow.model.enums.MealType;
import jakarta.persistence.*;
import lombok.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "mess_menu")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MessMenu {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String dayOfWeek;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MealType mealType;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "mess_menu_item",
        joinColumns = @JoinColumn(name = "mess_menu_id"),
        inverseJoinColumns = @JoinColumn(name = "food_item_id")
    )
    @Builder.Default
    private List<FoodItem> items = new ArrayList<>();
}
