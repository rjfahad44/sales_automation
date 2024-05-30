import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sales_automation/Models/Item.dart';
import 'package:sales_automation/Screens/Order/Models/OrderCreate.dart';

import 'Models/UserData.dart';

UserData userData = UserData();
OrderCreate orderCreate = OrderCreate();
double screenwidth = 0.0;
Item selectedChemist = Item();
Color themeColor = const Color(0xFFFFC680);
Color primaryButtonColor = const Color(0xff095f98);
Color secondaryButtonColor =  Colors.redAccent;
Color primaryTextColor = Colors.black;
Color secondaryTextColor = Colors.white;

// String serverPath = "https://osapi.bunoporibrajok.com";
String serverPath = "http://27.147.221.94:8083";

// late LocationInf cLocationInf;

 const int image_model_type_id = 0;
 const int product_model_type_id = 1;
 const int order_model_type_id = 2;

