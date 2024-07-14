import 'package:flutter/material.dart';
import 'package:talabatcom/features/language/domain/models/language_model.dart';

abstract class LanguageServiceInterface {
  bool setLTR(Locale locale);
  updateHeader(Locale locale, int? moduleId);
  Locale getLocaleFromSharedPref();
  setselectedIndex(List<LanguageModel> languages, Locale locale);
  void saveLanguage(Locale locale);
}