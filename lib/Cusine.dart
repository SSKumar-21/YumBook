import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CusineMeal.dart';
import 'dart:ui';

class CuisinePage extends StatefulWidget {
  @override
  State<CuisinePage> createState() => _CuisinePageState();
}

class _CuisinePageState extends State<CuisinePage> {
  List<String> cuisines = [];
  bool loading = false;

  Future<void> fetchCuisines() async {
    setState(() => loading = true);
    try {
      final url =
      Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?a=list');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> list = data['meals'];
        cuisines = list.map((item) => item['strArea'].toString()).toList();
      }
    } catch (e) {
      print("Error loading cuisines: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  final Map<String, String> cuisineFlags = {
    "American": "🇺🇸",
    "British": "🇬🇧",
    "Canadian": "🇨🇦",
    "Chinese": "🇨🇳",
    "Dutch": "🇳🇱",
    "Egyptian": "🇪🇬",
    "French": "🇫🇷",
    "Greek": "🇬🇷",
    "Indian": "🇮🇳",
    "Irish": "🇮🇪",
    "Italian": "🇮🇹",
    "Jamaican": "🇯🇲",
    "Japanese": "🇯🇵",
    "Kenyan": "🇰🇪",
    "Malaysian": "🇲🇾",
    "Mexican": "🇲🇽",
    "Moroccan": "🇲🇦",
    "Polish": "🇵🇱",
    "Portuguese": "🇵🇹",
    "Russian": "🇷🇺",
    "Spanish": "🇪🇸",
    "Thai": "🇹🇭",
    "Tunisian": "🇹🇳",
    "Turkish": "🇹🇷",
    "Vietnamese": "🇻🇳",
  };

  @override
  void initState() {
    super.initState();
    fetchCuisines();
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
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                    child: const Text(
                      "🌍 Explore Cuisines",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 🍲 Cuisine Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cuisines.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final cuisine = cuisines[index];
                      final emoji =
                          cuisineFlags[cuisine] ?? "🍽️"; // default

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CuisineMealsPage(cuisine: cuisine),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 🌫️ Gradient background
                              Container(
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

                              // 🌫️ Frosted glass
                              BackdropFilter(
                                filter:
                                ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                child: Container(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),

                              // 🌟 Flag and Cuisine Name
                              Center(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      emoji,
                                      style: const TextStyle(
                                        fontSize: 48,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      cuisine,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        letterSpacing: 1,
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
