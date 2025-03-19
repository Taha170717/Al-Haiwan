import 'package:al_haiwan/repository/splash/splashscreen.dart';
import 'package:flutter/material.dart';

void main (){
  runApp(MyApp());
}


class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Al-Haiwan',
     debugShowCheckedModeBanner: false,
     theme: ThemeData(

     ),
     home: SplashScreen(),
   );
  }


}