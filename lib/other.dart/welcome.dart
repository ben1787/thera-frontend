import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thera_frontend/utilities.dart/App_color.dart';
import '../utilities.dart/App_Image.dart';
import '../utilities.dart/app_font.dart';
import 'welcomescrren.dart';



class Welcome extends StatefulWidget {
   static String routeName = "./Welcome";
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomescreenState();
}

class _WelcomescreenState extends State<Welcome> {
  get fullnameTextEditingController => null;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColor.secondryColor,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
               height: MediaQuery.of(context).size.height*100/100,
               width: MediaQuery.of(context).size.width*100/100,
               color: AppColor.secondryColor,
               child: Column(
                children: [
                  Container(
                  color: AppColor.selectcolor,
                 height: MediaQuery.of(context).size.height*10/100,
                 width: MediaQuery.of(context).size.width*100/100,
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*3/100,),
                      Container(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      child: const Text(
                        "LOGO",
                        style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.secondryColor,
                            fontSize: 28,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w800),
                      ),
                    )
                    ],
                  ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*2/100,),
               Expanded(
                 child: SingleChildScrollView(
                    child: Container(
                        width: MediaQuery.of(context).size.width*90/100,
                      child: Column(
                        children: [
                               //----------------------text container ----------------------------------------------------------------//           
                           Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Row(
                    children: [
                     
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5 / 100,
                      ),
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(left: 6),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height:
                                MediaQuery.of(context).size.height * 5 / 100,
                            decoration: const BoxDecoration(
                                color: AppColor.textfilledColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: Container(
                              child: const Text(
                                "Hey what's up",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: AppColor.textcolor,
                                    fontFamily: AppFont.fontFamily),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100,
                          ),
                          Row(
                            children: [
                              Container(
                                // color: Colors.blue,
                                child: const Text(
                                  "Thera",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.textcolor),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 6 / 100,
                              ),
                              Container(
                                //color: Colors.blue,
                                child: const Text(
                                  "12:03",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: AppFont.fontFamily,
                                      color: AppColor.chatTimeColor),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),

              
                    
                        ],
                      ),
                    ),
                  ),
               ) ,
            SizedBox(height: MediaQuery.of(context).size.height*2/100,),
            //-------------------------textfield---------------------------------------------------//
              Container(  
                                width: MediaQuery.of(context).size.width * 90 / 100,
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: TextFormField(
                                  // inputFormatters: [maskFormatter],
                                  maxLines: 1,
                                  style: const TextStyle(
                                      height: 1, color: Colors.black),
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: fullnameTextEditingController,
                                  // maxLength: AppConstant.emailMaxLength,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.secondryColor ),
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(10.0)),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.secondryColor),
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(10.0)),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                             color: AppColor.themeColor),
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(10.0)),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Welcomescreen()));
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context).size.width *
                                                5/
                                                100,
                                            height:
                                                MediaQuery.of(context).size.width *
                                                    5/
                                                    100,
                                            child: Image.asset(
                                            App_Image.textfielsarrowIcon,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {},
                                      ),
                                      fillColor: const Color.fromARGB(255, 228, 231, 235),
                                      filled: true,
                                      counterText: '',
                                       hintText:"Type a message",
                                      // hintStyle: AppConstant.textFilledStyle),
                                ),
                              ),
                            ),
                
                ],
               ),
          ),
        )
        ),
    );
  }
}

