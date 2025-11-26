import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'search.dart';
import 'LoopUp.dart';
import 'random.dart';
import 'category.dart';
import 'Cusine.dart';
import 'saved.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var option = ["Search", "Random", "Look Up", "Category", "Cuisine/Region", "Saved"];

  Widget getPage(String name) {
    switch (name) {
      case "Search":
        return Search();
      case "Random":
        return Random();
      case "Look Up":
        return Lookup();
      case "Category":
        return CategoryPage();
      case "Cuisine/Region":
        return CuisinePage();
    case "Saved":
      return SavedMealsPage();
      default:
        return Scaffold(
          body: Center(child: Text("Page not found: $name")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          children: [
            Image.asset(
              "assets/home.gif",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              color: const Color.fromRGBO(0, 0, 0, 0.4),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  Text(
                    "Yum Book",
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.orangeAccent.withOpacity(0.8),
                          offset: Offset(0, 2),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "❤️ Discover. Cook. Enjoy.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          for (var item in option)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                              width: 360,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => getPage(item)),
                                  );
                                },
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0.55),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  elevation: 6,
                                ).copyWith(
                                  overlayColor: WidgetStateProperty.all(Colors.white24),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
