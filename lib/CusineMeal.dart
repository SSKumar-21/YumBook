import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // ✅ For BackdropFilter
import 'Details.dart'; // MealDetailPage

class CuisineMealsPage extends StatefulWidget {
  final String cuisine;
  const CuisineMealsPage({required this.cuisine});

  @override
  State<CuisineMealsPage> createState() => _CuisineMealsPageState();
}

class _CuisineMealsPageState extends State<CuisineMealsPage> {
  List<Map<String, dynamic>> meals = [];
  bool loading = false;

  Future<void> fetchMeals() async {
    setState(() => loading = true);
    try {
      final url = Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?a=${widget.cuisine}');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> list = data['meals'] ?? [];

        meals = list
            .map((item) => {
          "id": item['idMeal'],
          "name": item['strMeal'],
          "thumb": item['strMealThumb'],
        })
            .toList();
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

          // 🌒 Dark overlay
          Container(color: const Color.fromRGBO(0, 0, 0, 0.4)),

          SafeArea(
            child: loading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
                : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✨ Page Heading
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.orangeAccent, Colors.yellowAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "🥘 ${widget.cuisine} Cuisine",
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

                  // 🍲 Meals Grid
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
                              builder: (_) => MealDetailPage(
                                idMeal: meal['id'].toString(),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 📸 Meal Image
                              meal['thumb'] != null &&
                                  meal['thumb'].toString().isNotEmpty
                                  ? Image.network(
                                meal['thumb'],
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
                              )
                                  : Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.fastfood_outlined,
                                  color: Colors.white70,
                                  size: 50,
                                ),
                              ),

                              // 🌫 Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.6),
                                    ],
                                  ),
                                ),
                              ),

                              // 🌫 Frosted glass effect
                              BackdropFilter(
                                filter:
                                ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                child: Container(
                                  color: Colors.black.withOpacity(0.1),
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
                                      meal['name'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.cuisine,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
