import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:theramvp_project/utilities.dart/App_color.dart';
import 'package:theramvp_project/utilities.dart/App_language.dart';
import 'package:theramvp_project/utilities.dart/app_font.dart';

import '../utilities.dart/App_Image.dart';
import '../utilities.dart/app_constant.dart';

class Welcomescreen extends StatefulWidget {
  const Welcomescreen({super.key});

  @override
  State<Welcomescreen> createState() => _WelcomescreenState();
}

class _WelcomescreenState extends State<Welcomescreen> {
  TextEditingController fullnameTextEditingController = TextEditingController();
  bool isdroupdownSelect = false;
  // ========== ========chat List===================//
  List<dynamic> chatList = <dynamic>[
    {"mesg": "Hey! What’s up?", "time": "12:03", "status": false},
    {"mesg": "Hii I’m Ben", "time": "12:04", "status": true},
    {
      "mesg": "Hii ben, I’m Thera.\nHow are you today",
      "time": "12:03",
      "status": false
    },
    {"mesg": "I’m feeling sad", "time": "12:03", "status": true},
    {
      "mesg": "Can you please give me some \nsolution..",
      "time": "12:03",
      "status": true
    },
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColor.secondryColor,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 100 / 100,
          width: MediaQuery.of(context).size.width * 100 / 100,
          color: AppColor.secondryColor,
          child: Column(
            children: [
              Container(
                color: AppColor.selectcolor,
                height: MediaQuery.of(context).size.height * 10 / 100,
                width: MediaQuery.of(context).size.width * 100 / 100,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      child:  Text(
                         AppLanguage.logoText[language],
                        style:const TextStyle(
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 100,
              ),

              //----------------------text container ----------------------------------------------------------------//
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              isdroupdownSelect = !isdroupdownSelect;
                            });

                          },
                          child: isdroupdownSelect == true
                              ? SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      10 /
                                      100,
                                  child: Image.asset(
                                    App_Image.dropIcon,
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                7 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                7 /
                                                100,
                                        child: Image.asset(
                                          App_Image.droupdownIcon,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5 / 100,
                      ),
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            height:
                                MediaQuery.of(context).size.height * 5 / 100,
                            decoration: const BoxDecoration(
                                color: AppColor.textfilledColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: const Text(
                              "Hey what's up",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppColor.textcolor,
                                  fontFamily: AppFont.fontFamily),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100,
                          ),
                          Row(
                            children: [
                              const Text(
                                "Thera",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.textcolor),
                                textAlign: TextAlign.end,
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 6 / 100,
                              ),
                              const Text(
                                "12:03",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.chatTimeColor),
                                textAlign: TextAlign.end,
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),

              //----------------------start ----------------------------------------------------------------//

              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 65 / 100,
                  ),
                  Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // SizedBox(width: MediaQuery.of(context).size.width*90/100,),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: MediaQuery.of(context).size.height * 5 / 100,
                        decoration: const BoxDecoration(
                            color: AppColor.selectcolor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.elliptical(15, 4))),
                        child: const Text(
                          "Hii i am ben",
                          style: TextStyle(
                              fontSize: 16, color: AppColor.secondryColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),
                      const SizedBox(
                      
                        // color: Colors.blue,
                        child: Text(
                          "12:03",
                          style: TextStyle(
                              fontSize: 11,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.chatTimeColor),
                          textAlign: TextAlign.end,
                        ),
                      )
                    ],
                  )
                ],
              ),

              //----------------------text container ----------------------------------------------------------------//
              if (isdroupdownSelect == true)
                Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                               
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  decoration: const BoxDecoration(
                                      color: AppColor.textfilledColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                  child: const Text(
                                    "Hey what's up",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: AppColor.textcolor,
                                        fontFamily: AppFont.fontFamily),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      1 /
                                      100,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                         Text(
                                          "Thera",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.textcolor),
                                          textAlign: TextAlign.end,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          8/
                                          100,
                                    ),
                                    const Text(
                                      "12:03",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: AppFont.fontFamily,
                                          color: AppColor.chatTimeColor),
                                      textAlign: TextAlign.end,
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 65 / 100,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // SizedBox(width: MediaQuery.of(context).size.width*90/100,),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              height: MediaQuery.of(context).size.height *
                                  5 /
                                  100,
                              decoration: const BoxDecoration(
                                  color: AppColor.selectcolor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                     )),
                              child: const Text(
                                "Hii i am ben",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColor.secondryColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  1 /
                                  100,
                            ),
                            const SizedBox(
                            
                              // color: Colors.blue,
                              child: Text(
                                "12:03",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.chatTimeColor),
                                textAlign: TextAlign.end,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),

              //----------------------start ----------------------------------------------------------------//

              SizedBox(
                height: MediaQuery.of(context).size.height * 3 / 100,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 90 / 100,
                height: MediaQuery.of(context).size.height * 0.2 / 100,
                color: AppColor.greyLightColor,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 3 / 100,
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Container()
                 
                ),
              ),
              
              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 100,
              ),
              //-------------------------textfield---------------------------------------------------//
              Container(
                width: MediaQuery.of(context).size.width * 90 / 100,
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: TextFormField(
                  // inputFormatters: [maskFormatter],
                  maxLines: 1,
                  style: const TextStyle(height: 1, color: Colors.black),
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.emailAddress,
                  controller: fullnameTextEditingController,
                  // maxLength: AppConstant.emailMaxLength,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColor.textformfiledColor),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColor.textformfiledColor),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColor.textformfiledColor),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    suffixIcon: IconButton(
                      icon: GestureDetector(
                        onTap: () {
                        
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 5 / 100,
                          height: MediaQuery.of(context).size.width * 5 / 100,
                          child: Image.asset(
                            App_Image.textfielsarrowIcon,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      onPressed: () {},
                    ),
                    fillColor: AppColor.textformfiledColor,
                    filled: true,
                    counterText: '',
                    hintText: AppLanguage.typeLanguageText[language],
                    hintStyle:
                        const TextStyle(fontSize: 16, color: Color(0xffA3AFB8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}



