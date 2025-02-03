import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nutrition_app/food_detail_page.dart';

void main() {
  
  WidgetsFlutterBinding.ensureInitialized(); 

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]) //set to portrait only, then run app once it finishes
    .then((value) => runApp(const MaterialApp(home: Home(),)));
}


//removes the ".0" at the end of numbers to make them look smoother
num decimalFormat(double value) {
  if (value == value.round()) {
    return value.round();
  } else {
    return value;
  }
}

//Class for modeling the food data
class FoodItem {
  
  
  final double protein;
  final double fat;
  final double carbohydrates;
  final int calories;
  final int servingSize;
  final String name;
  final String servingName;
  final String brand;
  final String servingUnits;
  final String category;
  final int fdcID;
  final String ingredients;
  final double? satFat;
  final double? transFat;
  final double? cholesterol;
  final double? sodium;
  final double? dietaryFiber;
  final double? totalSugars;
  final double? addedSugars;
  final double? vitaminD;
  final double? calcium;
  final double? iron;
  final double? potassium;

  FoodItem({
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.calories,
    required this.servingSize,
    required this.name,
    required this.servingName,
    required this.brand,
    required this.servingUnits,
    required this.category,
    required this.fdcID,
    required this.satFat,
    required this.transFat,
    required this.cholesterol,
    required this.sodium,
    required this.dietaryFiber,
    required this.totalSugars,
    required this.addedSugars,
    required this.vitaminD,
    required this.calcium,
    required this.iron,
    required this.potassium,
    required this.ingredients
  });

  //Method to create a FoodItem from Json
  factory FoodItem.fromJson(Map<String, dynamic> json) {

    //round software because built in dart function only round to integers
    double roundToTens(num value) => (value * 10).round() / 10;

    //convert from the given nutrients per 100g or ml to nutrient per serving
    double? nutrientsPerServing(double? valuePer100, double servingSize) {
      if (valuePer100 != null) {
        return roundToTens((valuePer100 / 100) * servingSize);
      } else {
        return null;
      }
    }

    double? proteinPer100;
    double? fatPer100;
    double? carbsPer100;
    double? caloriesPer100;
    String units;
    double? saturated;
    double? trans;
    double? chol;
    double? Na; //chemical symbol for sodium
    double? dietFiber;
    double? sugarTotal;
    double? sugarAdded;
    double? Dvitamin;
    double? cal;
    double? Fe;
    double? potas;

    //get the nutrients (some are missing 1 or more nutrients)
    for (Map nutrient in json['foodNutrients']) {
      if (nutrient['nutrientName'] == 'Protein') {
        proteinPer100 = nutrient['value'].toDouble();
      } else if (nutrient['nutrientName'] == 'Total lipid (fat)') {
        fatPer100 = nutrient['value'].toDouble();
      } else if (nutrient['nutrientName'] == 'Carbohydrate, by difference') {
        carbsPer100 = nutrient['value'].toDouble();
      } else if (nutrient['nutrientName'] == 'Energy') {
        caloriesPer100 = nutrient['value'].toDouble();
      } else if (nutrient['nutrientName'] == 'Fatty acids, total saturated') {
        saturated = roundToTens(nutrient['value'].toDouble());
      } else if (nutrient['nutrientName'] == 'Fatty acids, total trans') {
        trans = roundToTens(nutrient['value'].toDouble());
      } else if (nutrient['nutrientName'] == 'Cholesterol') {
        chol = roundToTens(nutrient['value'].toDouble());
      } else if (nutrient['nutrientName'] == 'Sodium, Na') {
        Na = roundToTens(nutrient['value'].toDouble());
      } else if (nutrient['nutrientName'] == 'Fiber, total dietary') {
        dietFiber = roundToTens(nutrient['value'].toDouble());
      } else if (nutrient['nutrientName'] == 'Total Sugars') {
        sugarTotal = roundToTens(nutrient['value'].toDouble());
      } else if (nutrient['nutrientName'] == 'Sugars, added') {
        sugarAdded = roundToTens(nutrient['value'].toDouble());
      //some vitamins come in multiple different units and should be converted if neccessary
      } else if (nutrient['nutrientName'] == 'Vitamin D (D2 + D3)') {
        Dvitamin = roundToTens(nutrient['value'].toDouble());
      } else if (nutrient['nutrientName'] == 'Vitamin D (D2 + D3), International Units') {
        Dvitamin = roundToTens(nutrient['value'].toDouble()/40);
      } else if (nutrient['nutrientName'] == 'Calcium, Ca') {
        cal = roundToTens(nutrient['value'].toDouble());
      } else if (nutrient['nutrientName'] == 'Iron, Fe') {
        Fe = roundToTens(nutrient['value'].toDouble());
      } else if (nutrient['nutrientName'] == 'Potassium, K') {
        potas = roundToTens(nutrient['value'].toDouble());
      }
    }

    //Get other properties that may need prior calculations
    if (json['servingSizeUnit'] == 'GRM') {
      units = 'g';
    } else {
      units = json['servingSizeUnit'];
    }

    //print('Hiii');
    return FoodItem(
      name: json['description'],
      category: json['foodCategory'],
      servingSize: json['servingSize'].round(),
      servingName: json['householdServingFullText'],
      brand: json['brandName'], //?? 'Generic', //Some are missing this
      servingUnits: units,
      fdcID: json['fdcId'],
      ingredients: json['ingredients'],
      protein: nutrientsPerServing(proteinPer100!, json['servingSize'])!,
      fat: nutrientsPerServing(fatPer100!, json['servingSize'])!,
      carbohydrates: nutrientsPerServing(carbsPer100!, json['servingSize'])!,
      calories: nutrientsPerServing(caloriesPer100!, json['servingSize'])!.round(),
      satFat: nutrientsPerServing(saturated, json['servingSize']),
      transFat: nutrientsPerServing(trans, json['servingSize']),
      cholesterol: nutrientsPerServing(chol, json['servingSize']),
      sodium: nutrientsPerServing(Na, json['servingSize']),
      dietaryFiber: nutrientsPerServing(dietFiber, json['servingSize']),
      totalSugars: nutrientsPerServing(sugarTotal, json['servingSize']),
      addedSugars: nutrientsPerServing(sugarAdded, json['servingSize']),
      vitaminD: nutrientsPerServing(Dvitamin, json['servingSize']),
      calcium: nutrientsPerServing(cal, json['servingSize']),
      iron: nutrientsPerServing(Fe, json['servingSize']),
      potassium: nutrientsPerServing(potas, json['servingSize']),
      

      //protein: 0,
      //fat: 0,
      //carbohydrates: 0,
      //calories: 0,
      //name: 'e',
      //category: 'e',
      //servingSize: 0,
      //servingName: 'e',
      //brand: 'e',
      //servingUnits: 'e',



    );
  }
}


class Home extends StatefulWidget {
 const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  //for reseting to the top of the list
  final ScrollController scrollController = ScrollController();


  //filter variables
  bool filterMenu = false;
  final queryController = TextEditingController();
  List<String> allcategories = ['Any'];
  String selectedCategory = 'Any';

  //Food processing variables
  Future<List<FoodItem>>? foodList;
  List<FoodItem> fetchedFoodData = [];
  List<FoodItem> displayedFoodData = [];

  //sort variables
  String selectedSortOption = 'Relevance'; // Default sort options
  String sortOrder = 'Ascending';


  //Sort and filter based on selected options
  void sortAndFilter() {
    displayedFoodData = List.from(fetchedFoodData);

    if (selectedCategory != 'Any') {
      displayedFoodData = displayedFoodData.where((item) => item.category == selectedCategory).toList();
    }

    if (selectedSortOption == 'FatPerCal' || selectedSortOption == 'CarbsPerCal' || selectedSortOption == 'ProteinPerCal') {
      displayedFoodData = displayedFoodData.where((item) => item.calories != 0).toList();
    }

    //Make it so when filtering by x per cal, remove entries with 0 calories.

    displayedFoodData.sort((a, b) {
      int comparison = 0;
      switch (selectedSortOption) {
        case 'Calories':
          comparison = a.calories.compareTo(b.calories);
          break;
        case 'Protein':
          comparison = a.protein.compareTo(b.protein);
          break;
        case 'Fat':
          comparison = a.fat.compareTo(b.fat);
          break;
        case 'Carbs':
          comparison = a.carbohydrates.compareTo(b.carbohydrates);
          break;
        case 'FatPerCal':
          comparison = (a.fat/a.calories).compareTo(b.fat/b.calories);
          break;
        case 'ProteinPerCal':
          comparison = (a.protein/a.calories).compareTo(b.protein/b.calories);
          break;
        case 'CarbsPerCal':
          comparison = (a.carbohydrates/a.calories).compareTo(b.carbohydrates/b.calories);
          break;
        case 'ServingSize':
          comparison = (a.servingSize).compareTo(b.servingSize);
          break;
        default: // Relevance (or no specific order)
          comparison = 0;
      }
      if (sortOrder == 'Ascending') {
        return comparison;
      } else if (sortOrder == 'Descending') {
        return -comparison;
      } else {
        return 0;
      }
    });

    //reset scroll position if the list has already been generated

    if (scrollController.hasClients) {
      scrollController.jumpTo(0.0);
    }
  }

  //Function to fetch food data
  Future<List<FoodItem>> searchFoods() async {
    

    //Gathered Required Data
    final String query = queryController.text;
    const String apiKey = 'mgc3Z3I6pJgaoTudvWspb7LSGoomBwuPrxJUU9Q1';


    //Converts strings to integers. if no value is given return 10000 or 0 for max and min respectively
    //final int maxCalories = int.tryParse(maxCaloriesController.text) ?? 10000;
    //final int minCalories = int.tryParse(minCaloriesController.text) ?? 0;
    //final int maxCarbs = int.tryParse(maxCarbsController.text) ?? 10000;
    //final int minCarbs = int.tryParse(minCarbsController.text) ?? 0;
    //final int maxProtein = int.tryParse(maxProteinController.text) ?? 10000;
    //final int minProtein = int.tryParse(minProteinController.text) ?? 0;
    //final int maxFat = int.tryParse(maxFatController.text) ?? 10000;
    //final int minFat = int.tryParse(minFatController.text) ?? 0;

    //print('https://api.nal.usda.gov/fdc/v1/foods/search?query=$query&api_key=$apiKey&dataType=Branded&pageSize=200&pageNumber=1');
    final response = await http.get(
      Uri.parse(
        "https://api.nal.usda.gov/fdc/v1/foods/search?query=$query&api_key=$apiKey&dataType=Branded&pageSize=200&pageNumber=1"
      )
    );

    //print(response.body);

    //Checks if backend was reached successfully and formats the response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> foods = data['foods'] ?? [];
        
      //int count = 0;
      //Convert response to fooditem
      fetchedFoodData = foods.map((item) {
        try {
          return FoodItem.fromJson(item);
        } catch (e) {
          //count += 1;
          //print("${item['fdcId']}:  $e");
          //print('Error processing item: $item');
          return null; // Skip invalid items
        }
      }).where((item) => item != null).cast<FoodItem>().toList();

      //print(count);

      //Sort based on selected option
      sortAndFilter();
    } else {
      fetchedFoodData = [];
      displayedFoodData = [];
    }
    
    //Display the approprite categories based on the returned foods
    setState(() {
      selectedCategory = 'Any';
      allcategories = ['Any'];
      for (var food in displayedFoodData) {
        if (!allcategories.contains(food.category)) {
          allcategories.add(food.category);
        }
      }
    });
    return displayedFoodData;
  }

  //rounding software because built in dart function only round to integers
  double roundToThousands(num value) => (value * 1000).round() / 1000;







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          "FuelFinder",
          style: TextStyle(
            color: Colors.lightGreenAccent
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[850],    
        elevation: 0,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: queryController,
                  style: TextStyle(
                    color: Colors.grey[300]
                  ),
                  decoration: const InputDecoration(
                    hintText: "What are you craving today?",
                    border: OutlineInputBorder(),
                    hintStyle: TextStyle(
                      color: Colors.grey
                    )
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      foodList = searchFoods();
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  ),
                onPressed:() {
                  setState(() {
                    foodList = searchFoods();
                  });
                },
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              ElevatedButton(
                onPressed:() {
                  setState(() {
                    filterMenu = !filterMenu;
                  });
                }, 
                child: const Icon(Icons.filter_alt_sharp)
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(120),
                ),
                child: Row(
                  children: [
                    const Text(
                      "Sort by ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                    if (selectedSortOption != 'Relevance') DropdownButton(
                      value: sortOrder,
                      items: const [
                        DropdownMenuItem(
                          value: 'Ascending',
                          child: Text("least"),
                        ),
                        DropdownMenuItem(
                          value: 'Descending',
                          child: Text("most"),
                        )
                      ], 
                      onChanged:(String? newValue) {
                        setState(() {
                          sortOrder = newValue!;
                          sortAndFilter(); //update displayed food
                        });
                      },
                    ),
                    DropdownButton(
                      value: selectedSortOption,
                      items: const [
                        DropdownMenuItem(
                          value: 'Relevance',
                          child: Text('Relevance')
                        ),
                        DropdownMenuItem(
                          value: 'ServingSize',
                          child: Text('Serving Size')
                        ),
                        DropdownMenuItem(
                          value: 'Calories',
                          child: Text('Calories')
                        ),
                        DropdownMenuItem(
                          value: 'Fat',
                          child: Text('Fat')
                        ),
                        DropdownMenuItem(
                          value: 'Protein',
                          child: Text('Protein')
                        ),
                        DropdownMenuItem(
                          value: 'Carbs',
                          child: Text('Carbs')
                        ),
                        DropdownMenuItem(
                          value: 'FatPerCal',
                          child: Text('Fat per cal')
                        ),
                        DropdownMenuItem(
                          value: 'ProteinPerCal',
                          child: Text('Protein per cal')
                        ),
                        DropdownMenuItem(
                          value: 'CarbsPerCal',
                          child: Text('Carbs per cal')
                        ),
                      ],
                      onChanged:(String? newValue) {
                        setState(() {
                          selectedSortOption = newValue!;
                          sortAndFilter(); //update displayed food
                        });
                    
                      },
                    ),
                  ]
                )
              )
            ]
          ),
          //Filters menu
          if (filterMenu) Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
            margin: const EdgeInsets.all(10),
            width: 300,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Category:  ',
                      style: TextStyle(
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButton(
                        isExpanded: true,
                        value: selectedCategory,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        items: allcategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                            //update based on selected value
                            sortAndFilter();
                          });
                        },
                      ),
                    )
                  ]
                ) 
              ],
            ),
          ),
          const SizedBox(height: 25),
          FutureBuilder(
            future: foodList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              } else if (foodList == null) {
                return const Center(child: Text(
                  "Nothing to see here",
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),);
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(
                      color: Colors.grey
                    ),
                    ),);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty || displayedFoodData.isEmpty) {
                return const Center(child: Text(
                  "No foods match your search",
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),);
              } else {

                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: displayedFoodData.length,
                    itemBuilder: (context, index) {
                      final food = displayedFoodData[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => FoodDetailPage(food: food),
                              )
                            );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            border: const Border(
                              top: BorderSide(color: Colors.grey),
                              bottom: BorderSide(color: Colors.grey)
                            )
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Text('${food.fdcID}'),
                                Text(
                                  '${food.brand}: ${food.name}',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[300]
                                  ),
                                ),
                                Text(
                                  food.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[300]
                                  ),
                                ),
                                Text(
                                  "Nutrition per ${food.servingName} (${food.servingSize} ${food.servingUnits})",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                  ),
                                ),
                                //Testing the nutrition lable for the next screen-----------------------------------------------
                        
                                //TESTING^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                          
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                  '  •  Calories(kcal): ${food.calories}',
                                  style: TextStyle(
                                    color: Colors.grey[300]
                                  ),
                                ),
                                Text(
                                  '  •  Protein(g): ${decimalFormat(food.protein)}',
                                  style: TextStyle(
                                    color: Colors.grey[300]
                                  ),
                                ),
                                Text(
                                  '  •  Fat(g): ${decimalFormat(food.fat)}',
                                  style: TextStyle(
                                    color: Colors.grey[300]
                                  ),
                                ),
                                Text(
                                  '  •  Carbohydrates(g): ${decimalFormat(food.carbohydrates)}',
                                  style: TextStyle(
                                    color: Colors.grey[300]
                                  ),
                                ),
                                      ],
                                    ),
                                    if (selectedSortOption == 'Calories') Text(
                                      '${(food.calories)} cal',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ) else if (selectedSortOption == 'Fat') Text(
                                      '${decimalFormat(food.fat)} g',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ) else if (selectedSortOption == 'Protein') Text(
                                      '${decimalFormat(food.protein)} g',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ) else if (selectedSortOption == 'Carbs') Text(
                                      '${decimalFormat(food.carbohydrates)} g',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ) else if (food.calories != 0 && selectedSortOption == 'FatPerCal') Text(
                                      '${roundToThousands(food.fat/food.calories)}',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ) else if (food.calories != 0 && selectedSortOption == 'ProteinPerCal') Text(
                                      '${roundToThousands(food.protein/food.calories)}',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ) else if (food.calories != 0 && selectedSortOption == 'CarbsPerCal') Text(
                                      '${roundToThousands(food.carbohydrates/food.calories)}',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ) else if (selectedSortOption == 'ServingSize') Text(
                                      '${food.servingSize} ${food.servingUnits}',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    )
                                  ]
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                );
              }
            }
          )
        ] //Column children
      ),
    );
  }
}