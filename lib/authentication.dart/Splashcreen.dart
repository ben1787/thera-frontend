import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:theramvp_project/utilities.dart/App_color.dart';
import 'package:theramvp_project/utilities.dart/app_font.dart';
import '../other.dart/welcomescrren.dart';
import '../utilities.dart/App_language.dart';
import '../utilities.dart/app_constant.dart';


class Splash extends StatefulWidget {
   static String routeName = "./Splash";
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: 3),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const  Welcomescreen()),
      ),
    );
  }

  Widget build(BuildContext context) {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColor.secondryColor,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      backgroundColor: AppColor.secondryColor,
      body: SafeArea(
        child: Center(
          child: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height*100/100,
            width: MediaQuery.of(context).size.width*100/100,
            color: AppColor.selectcolor,
             child: Text(
                       AppLanguage.logoText[language],style: TextStyle(fontFamily: AppFont.fontFamily,fontSize:50,color:Colors.white,fontWeight: FontWeight.w700,letterSpacing: 4),
                    ),
          ),
        ) ,
        ),
    );
  }
}