import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'Details.dart';

class Lookup extends StatefulWidget {
  @override
  State<Lookup> createState() => LookupState();
}

class LookupState extends State<Lookup> {
  var msg = "Search by Meal ID";
  var search = TextEditingController();
  List<Map<String, dynamic>> recipes = [];
  bool loading = false;

  Future<void> fetchRecipeById() async {
    var text = search.text.trim();
    if (text.isEmpty) {
      setState(() {
        msg = "Nothing to Cook";
        recipes.clear();
      });
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$text');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['meals'] == null) {
          setState(() {
            msg = "No recipes found 😢";
            recipes.clear();
          });
        } else {
          recipes.clear();
          for (var item in data['meals']) {
            recipes.add({
              "id": item['idMeal'] ?? '0000',
              "name": item['strMeal'] ?? "Unknown Dish",
              "category": item['strCategory'] ?? "Unknown",
              "thumb": item['strMealThumb'] ?? "",
            });
          }
          setState(() => msg = "Found recipe 🍳");
        }
      } else {
        setState(() => msg = "Error: ${res.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background
          Image.asset(
            "assets/home.gif",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // 🌒 Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.2),
                  Color.fromRGBO(0, 0, 0, 0.3)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🌈 Gradient Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.orangeAccent, Colors.yellowAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      msg,
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

                  // 🔍 Search Field (NO prefix icon)
                  TextField(
                    controller: search,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter Meal ID (e.g., 52772)...",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.orangeAccent.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => fetchRecipeById(),
                  ),

                  const SizedBox(height: 15),

                  // 🔘 New Modern Search Button
                  Center(
                    child: ElevatedButton(
                      onPressed: fetchRecipeById,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.orangeAccent.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        "Search Recipe",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🍲 Recipe Grid
                  if (loading)
                    const Center(
                        child:
                        CircularProgressIndicator(color: Colors.white))
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipes.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final meal = recipes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MealDetailPage(
                                    idMeal: meal['id']),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.03)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                  color:
                                  Colors.white.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(25),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Meal Image
                                  meal['thumb']!.isNotEmpty
                                      ? Image.network(
                                    meal['thumb'],
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.fastfood_outlined,
                                      color: Colors.white70,
                                      size: 50,
                                    ),
                                  ),

                                  // Gradient overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black
                                              .withOpacity(0.7)
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Text section
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          meal['name'],
                                          maxLines: 2,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Container(
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .orangeAccent
                                                .withOpacity(0.8),
                                            borderRadius:
                                            BorderRadius.circular(
                                                12),
                                          ),
                                          child: Text(
                                            meal['category'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.bold,
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
