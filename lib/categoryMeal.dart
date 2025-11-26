import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'Details.dart'; // Make sure MealDetailPage exists

class CategoryMealsPage extends StatefulWidget {
  final String category;
  const CategoryMealsPage({required this.category});

  @override
  State<CategoryMealsPage> createState() => _CategoryMealsPageState();
}

class _CategoryMealsPageState extends State<CategoryMealsPage> {
  List<Map<String, dynamic>> meals = [];
  bool loading = false;

  Future<void> fetchMeals() async {
    setState(() => loading = true);
    try {
      final url = Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.category}');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['meals'] != null) {
          meals = (data['meals'] as List)
              .where((item) =>
          item['idMeal'] != null &&
              item['strMeal'] != null &&
              item['strMealThumb'] != null)
              .map((item) => {
            "id": item['idMeal'],
            "name": item['strMeal'],
            "thumb": item['strMealThumb'],
          })
              .toList();
        } else {
          meals = [];
        }
      }
    } catch (e) {
      print("Error loading meals: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  @override
  Widget build(BuildContext context) {
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

          // 🌒 Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(0, 0, 0, 0.2), Color.fromRGBO(0, 0, 0, 0.3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: loading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🍛 Category Title with Gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.orangeAccent, Colors.yellowAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "🍛 ${widget.category} Dishes",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 🌟 Meals Grid
                  if (meals.isEmpty)
                    const Center(
                      child: Text(
                        "No meals found 😕",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: meals.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final meal = meals[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MealDetailPage(
                                  idMeal: meal['id'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.12),
                                  Colors.white.withOpacity(0.05)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Meal Image
                                  meal['thumb']!.isNotEmpty
                                      ? Image.network(meal['thumb'], fit: BoxFit.cover)
                                      : Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.fastfood_outlined,
                                      color: Colors.white70,
                                      size: 50,
                                    ),
                                  ),
                                  // Frosted Glass
                                  BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ),
                                  // Gradient for text visibility
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7)
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Meal Name & Category
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          meal['name'] ?? 'Unnamed Dish',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.orangeAccent.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            widget.category,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

