import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Home.dart';

class splash extends StatefulWidget{

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  double _opacity = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1),(){
      _opacity = 1.0;
      setState(() {
      });
    });
    
    Future.delayed(Duration(seconds: 4),(){
      Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (context) => Home()));
    });
    
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset("assets/splash.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,),
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Color.fromRGBO(0, 0, 0, 0.5),
          ),
          Center(
            child:AnimatedOpacity(
              curve: Curves.easeIn,
                duration: Duration(seconds: 1),
                opacity: _opacity,
                child: Image.asset("assets/logo.png",)
            ),
          )
        ],
      ),
    );
  }
}