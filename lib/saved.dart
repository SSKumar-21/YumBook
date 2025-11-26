import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'savedMeal.dart';

class SavedMealsPage extends StatefulWidget {
  const SavedMealsPage({super.key});

  @override
  State<SavedMealsPage> createState() => _SavedMealsPageState();
}

class _SavedMealsPageState extends State<SavedMealsPage> {
  Map<String, dynamic> savedMealsMap = {};
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadSavedMeals();
  }

  // ✅ Load meals from SharedPreferences map
  Future<void> loadSavedMeals() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('savedMealsMap');

    if (savedData != null) {
      savedMealsMap = jsonDecode(savedData);
    } else {
      savedMealsMap = {};
    }

    setState(() => loading = false);
  }

  // ✅ Remove a meal from savedMealsMap
  Future<void> removeMeal(String idMeal) async {
    final prefs = await SharedPreferences.getInstance();
    savedMealsMap.remove(idMeal);
    await prefs.setString('savedMealsMap', jsonEncode(savedMealsMap));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mealsList = savedMealsMap.values.toList();

    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background GIF
          Image.asset(
            "assets/home.gif",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),

          // 🌒 Dark overlay
          Container(color: Colors.black.withOpacity(0.4)),

          SafeArea(
            child: loading
                ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
                : mealsList.isEmpty
                ? const Center(
              child: Text(
                "No saved recipes yet 🍳",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
                : RefreshIndicator(
              onRefresh: loadSavedMeals,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.8,
                ),
                itemCount: mealsList.length,
                itemBuilder: (context, index) {
                  final meal =
                  mealsList[index] as Map<String, dynamic>;
                  final idMeal = meal['idMeal'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SavedMealPage(meal: meal),
                        ),
                      );
                    },
                    onLongPress: () async {
                      await removeMeal(idMeal);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Recipe removed from saved.",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.grey[900],
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 📸 Meal Image
                          meal['strMealThumb'] != null &&
                              meal['strMealThumb']
                                  .toString()
                                  .isNotEmpty
                              ? Image.network(
                            meal['strMealThumb'],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child,
                                loadingProgress) {
                              if (loadingProgress == null)
                                return child;
                              return const Center(
                                child:
                                CircularProgressIndicator(
                                  color: Colors.white70,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) =>
                                Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.fastfood,
                                    color: Colors.white70,
                                    size: 50,
                                  ),
                                ),
                          )
                              : Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.white70,
                              size: 50,
                            ),
                          ),

                          // 🌫 Frosted glass effect
                          BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaX: 0, sigmaY: 0),
                            child: Container(
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),

                          // 🌫 Gradient overlay for glow effect
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.orangeAccent
                                      .withOpacity(0.15),
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),

                          // 🍴 Meal Info
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal['strMeal'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  meal['strCategory'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
