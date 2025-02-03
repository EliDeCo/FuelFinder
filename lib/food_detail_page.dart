import 'package:flutter/material.dart';

import 'main.dart'; // Import the main file to use the FoodItem model

class FoodDetailPage extends StatelessWidget {
  final FoodItem food;
  
  const FoodDetailPage({super.key, required this.food}); //get the food from other page
  

  //Widget template for nutrition label rows
  Widget mainNutrientRow(String label, double value, String unit, int dailyValue) {
    int percentDailyValue = ((value*100)/dailyValue).round();
    return Column(
      children: [
        const Divider(color: Colors.black, thickness: 1, height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  " $label ",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900
                  ),
                ),      
                Text(
                  '${decimalFormat(value)}$unit',
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                )
              ],
            ),
            Text(
              "$percentDailyValue% ",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            )
          ],
        )
      ],
    );
  }

  //widget for formatting the rows for vitamins and minerals
  Widget micronutrientRow(String label, double value, String unit, int dailyValue) {
    int percentDailyValue = ((value*100)/dailyValue).round();
    return Column(
      children: [
        const Divider(color: Colors.black, thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  " $label ",
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),      
                Text(
                  '${decimalFormat(value)}$unit',
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                )
              ],
            ),
            Text(
              "$percentDailyValue% ",
              style: const TextStyle(
                fontSize: 13,
              ),
            )
          ],
        )
      ],
    );
  }

  //widget for the unique formatting of the added sugar row
  Widget addedSugarRow(double value) {
    //daily added sugar reccomendation is 50g
    int percentDailyValue = ((value*100)/50).round();
    return Column(
      children: [
        const Divider(color: Colors.black, thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "          Includes ${decimalFormat(value)}g Added Sugars",
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
            Text(
              "$percentDailyValue% ",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            )
          ],
        )
      ],
    );
  }

  //Widget for displaying subnutrients like saturated and trans fat
  Widget minorNutrientRow(String label, double value, String unit, int dailyValue, bool useDailyValue) {
    int percentDailyValue = ((value*100)/dailyValue).round();
    return Column(
      children: [
        const Divider(color: Colors.black, thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "     $label ",
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),      
                Text(
                  '${decimalFormat(value)}$unit',
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                )
              ],
            ),
            if (useDailyValue) Text(
              "$percentDailyValue% ",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          '${food.brand}: ${food.name}',
          style: const TextStyle(
            color: Colors.lightGreenAccent
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[850],    
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Nutrition Facts",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900
                      ),
                    ),
                    //const Text("--- Servings per Container",),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Serving Size  ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "${food.servingName} (${food.servingSize}${food.servingUnits})",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                        )
                      ],
                    ),
                    
                    const Divider(color: Colors.black, thickness: 10),
                    const Text(
                      'Amount per serving',
                      style: TextStyle(
                        fontSize: 11
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Calories',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "${food.calories}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      ]
                    ),
                    const Divider(color: Colors.black, thickness: 5),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(""),
                        Text(
                          "% Daily Value*",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                          )
                      ],
                    ),
                    mainNutrientRow("Total Fat", food.fat, "g", 78),
                    if (food.satFat != null) minorNutrientRow("Saturated Fat", food.satFat!, "g", 20, true),
                    if (food.transFat != null) minorNutrientRow("Trans Fat", food.transFat!, "g", 1, false),
                    if (food.cholesterol != null) mainNutrientRow("Cholesterol", food.cholesterol!, "mg", 300),
                    if (food.sodium != null) mainNutrientRow("Sodium", food.sodium!, "mg", 2300),
                    mainNutrientRow("Total Carbohydrate", food.carbohydrates, "g", 275),
                    if (food.dietaryFiber != null) minorNutrientRow("Dietary Fiber", food.dietaryFiber!, "g", 28, true),
                    if (food.totalSugars != null) minorNutrientRow("Total Sugars", food.totalSugars!, 'g', 1, false),
                    if (food.addedSugars != null) addedSugarRow(food.addedSugars!),
                    mainNutrientRow("Protein", food.protein, "g", 50),
                    const Divider(color: Colors.black, thickness: 10),
                    if (food.vitaminD != null) micronutrientRow("Vitamin D", food.vitaminD!, "mcg", 20),
                    if (food.calcium != null) micronutrientRow("Calcium", food.calcium!, "mg", 1300),
                    if (food.iron != null) micronutrientRow("Iron", food.iron!, "mg", 18),
                    if (food.potassium != null) micronutrientRow("Potassium", food.potassium!, "mg", 4700),
                  ],
                ),
              ),
            ),            
            const Text(
              'Ingredients:',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold
              ),
            ),
            Text(
              food.ingredients,
              style: const TextStyle(
                color: Colors.grey
              ),
            ),
          ],
        ),
      ),
    );
  }
}