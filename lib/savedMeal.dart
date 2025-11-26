import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:ui';

class SavedMealPage extends StatefulWidget {
  final Map<String, dynamic> meal;

  const SavedMealPage({super.key, required this.meal});

  @override
  State<SavedMealPage> createState() => _SavedMealPageState();
}

class _SavedMealPageState extends State<SavedMealPage> {
  bool unsaving = false;

  // ✅ Extract ingredients safely
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // ✅ Unsave meal
  Future<void> unsaveMeal(String idMeal) async {
    setState(() => unsaving = true);
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('savedMealsMap');
    if (savedData != null) {
      final savedMealsMap = jsonDecode(savedData) as Map<String, dynamic>;
      savedMealsMap.remove(idMeal);
      await prefs.setString('savedMealsMap', jsonEncode(savedMealsMap));
    }
    setState(() => unsaving = false);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Recipe removed from saved list."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ✅ Open YouTube
  Future<void> openYouTube(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final ingredients = extractIngredients(meal);
    final idMeal = meal['idMeal'] ?? '';
    final youtubeLink = meal['strYoutube'];

    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Premium background GIF
          Image.asset(
            "assets/trial.jpg",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // 🖤 Semi-dark overlay
          Container(color: Colors.black.withOpacity(0.6)),

          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 🍽 Meal Image with frosted effect
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Stack(
                          children: [
                            Image.network(
                              meal['strMealThumb'] ?? '',
                              height: 280,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 280,
                                color: Colors.grey[800],
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.fastfood,
                                  color: Colors.white70,
                                  size: 60,
                                ),
                              ),
                            ),
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                              child: Container(
                                height: 280,
                                color: Colors.black.withOpacity(0.0),
                              ),
                            ),
                            Container(
                              height: 280,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orangeAccent.withOpacity(0.15),
                                    Colors.black.withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🍛 Meal Name
                      Text(
                        meal['strMeal'] ?? 'Unknown Recipe',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🏷 Tags
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (meal['strCategory'] != null &&
                              meal['strCategory'].toString().isNotEmpty)
                            buildTag(meal['strCategory'], Colors.orangeAccent),
                          if (meal['strArea'] != null &&
                              meal['strArea'].toString().isNotEmpty)
                            buildTag(meal['strArea'], Colors.blueAccent),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // 🧂 Ingredients
                      const Text(
                        "🧂 Ingredients",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...ingredients.map(
                            (ing) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ing['ingredient']!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                              Text(
                                ing['measure']!,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 📜 Instructions
                      const Text(
                        "📜 Instructions",
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meal['strInstructions']?.toString().trim().isNotEmpty ==
                            true
                            ? meal['strInstructions']
                            : "No instructions available.",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ▶️ YouTube Button
                      if (youtubeLink != null && youtubeLink.trim().isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => openYouTube(youtubeLink),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Watch on YouTube"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),

                // ❤️ Unsave floating button
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    iconSize: 30,
                    color: Colors.redAccent,
                    icon: unsaving
                        ? const CircularProgressIndicator(color: Colors.redAccent)
                        : const Icon(Icons.favorite),
                    tooltip: 'Remove from saved',
                    onPressed:
                    unsaving ? null : () => unsaveMeal(idMeal.toString()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
