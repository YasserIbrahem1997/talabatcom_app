import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talabatcom/util/app_constants.dart';

ThemeData dark({Color color = const Color(0xFFD6324A)}) => ThemeData(
    fontFamily: AppConstants.fontFamily,
    primaryColor: color,
    secondaryHeaderColor: const Color(0xFF009f67),
    disabledColor: const Color(0xffa2a7ad),
    brightness: Brightness.dark,
    hintColor: const Color(0xFFbebebe),
    cardColor: const Color(0xFF30313C),
    popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xFF29292D), surfaceTintColor: Color(0xFF29292D)),
    dialogTheme: const DialogTheme(surfaceTintColor: Colors.white10),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
    bottomAppBarTheme: const BottomAppBarTheme(
      surfaceTintColor: Colors.black,
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 5),
    ),
    dividerTheme:
        const DividerThemeData(thickness: 0.5, color: Color(0xFFA0A4A8)),
    // appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle(
    //   statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.light,
    // )),
    appBarTheme:
        const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFffbd5c))),
    colorScheme: const ColorScheme.dark(
        primary: Color(0xFFffbd5c), secondary: Color(0xFFffbd5c)));
