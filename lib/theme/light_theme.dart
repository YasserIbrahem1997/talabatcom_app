import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talabatcom/util/app_constants.dart';

ThemeData light({Color color = const Color(0xFFD6324A)}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  secondaryHeaderColor: const Color(0xFF1ED7AA),
  disabledColor: const Color(0xFFBABFC4),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogTheme(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarTheme(
    surfaceTintColor: Colors.white, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(thickness: 0.2, color: Color(0xFFA0A4A8)),
  // appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle(
  //   statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.dark,
  // )),
  appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
    textButtonTheme: TextButtonThemeData(
        style:
        TextButton.styleFrom(foregroundColor: const Color(0xFFD6324A))),
    colorScheme: const ColorScheme.light(
        primary: Color(0xFFD6324A), secondary: Color(0xFFD6324A))

);