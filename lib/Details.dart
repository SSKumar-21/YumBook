import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class MealDetailPage extends StatefulWidget {
  final String idMeal;

  const MealDetailPage({super.key, required this.idMeal});

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? meal;
  bool loading = false;
  bool isSaved = false;
  late AnimationController _controller;
  late Animation<double> _imageScale;

  @override
  void initState() {
    super.initState();
    fetchMealDetails();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _imageScale = Tween<double>(begin: 1.2, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  Future<void> fetchMealDetails() async {
    setState(() => loading = true);
    try {
      final url = Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.idMeal}');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          meal = data['meals'][0];
          await _checkIfMealIsSaved();
        }
      }
    } catch (e) {
      debugPrint("Error loading meal details: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _checkIfMealIsSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('savedMealsMap');
    if (savedData == null) return;

    final Map<String, dynamic> savedMealsMap = jsonDecode(savedData);
    setState(() => isSaved = savedMealsMap.containsKey(widget.idMeal));
  }

  Future<void> _toggleSaveMeal() async {
    if (meal == null) return;

    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('savedMealsMap');
    Map<String, dynamic> savedMealsMap =
    savedData != null ? jsonDecode(savedData) : {};

    String message;

    if (savedMealsMap.containsKey(meal!['idMeal'])) {
      savedMealsMap.remove(meal!['idMeal']);
      message = "Recipe removed from saved.";
      isSaved = false;
    } else {
      savedMealsMap[meal!['idMeal']] = meal!;
      message = "Recipe saved successfully!";
      isSaved = true;
    }

    await prefs.setString('savedMealsMap', jsonEncode(savedMealsMap));

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<Map<String, String>> extractIngredients(Map<String, dynamic> meal) {
    final ingredients = <Map<String, String>>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty &&
          measure != null &&
          measure.toString().trim().isNotEmpty) {
        ingredients.add({'ingredient': ingredient, 'measure': measure});
      }
    }
    return ingredients;
  }

  Widget buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : meal == null
          ? const Center(
        child: Text("Meal not found.",
            style: TextStyle(color: Colors.white)),
      )
          : Stack(
        children: [
          // 🌟 Premium GIF Background
          Image.asset(
            'assets/trial.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🍽 Animated Meal Image
                AnimatedBuilder(
                  animation: _imageScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _imageScale.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Stack(
                            children: [
                              Image.network(
                                meal!['strMealThumb'],
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 0, sigmaY: 0),
                                child: Container(
                                  height: 300,
                                  color: Colors.black.withOpacity(0.0),
                                ),
                              ),
                              Container(
                                height: 300,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black54
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              // ❤️ Save Button
                              Positioned(
                                top: 20,
                                right: 20,
                                child: GestureDetector(
                                  onTap: _toggleSaveMeal,
                                  child: AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSaved
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isSaved
                                          ? Colors.redAccent
                                          : Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // 🍛 Title
                Text(
                  meal!['strMeal'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // 🏷 Tags
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (meal!['strCategory'] != null)
                      buildTag(meal!['strCategory'], Colors.orangeAccent),
                    if (meal!['strArea'] != null)
                      buildTag(meal!['strArea'], Colors.blueAccent),
                  ],
                ),

                const SizedBox(height: 25),

                // 🎥 YouTube Button
                if (meal!['strYoutube'] != null &&
                    meal!['strYoutube'].toString().isNotEmpty)
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri =
                        Uri.parse(meal!['strYoutube'].toString());
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.play_circle_fill,
                          color: Colors.white, size: 26),
                      label: const Text(
                        "Watch on YouTube",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // 🧂 Ingredients
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "🧂 Ingredients",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: extractIngredients(meal!)
                        .map(
                          (ing) => Container(
                        margin:
                        const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ing['ingredient']!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16),
                              ),
                            ),
                            Text(
                              ing['measure']!,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 30),

                // 📜 Instructions
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "📜 Instructions",
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    meal!['strInstructions'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
