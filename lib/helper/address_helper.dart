import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/api/api_client.dart';
import 'package:talabatcom/features/address/domain/models/address_model.dart';
import 'package:talabatcom/util/app_constants.dart';

class AddressHelper {
  static Future<bool> saveUserAddressInSharedPref(AddressModel address) async {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    String userAddress = jsonEncode(address.toJson());
    Get.find<ApiClient>().updateHeader(
      sharedPreferences.getString(AppConstants.token),
      address.zoneIds,
      [],
      sharedPreferences.getString(AppConstants.languageCode),
      Get.find<SplashController>().module?.id,
      address.latitude,
      address.longitude,
    );
    return await sharedPreferences.setString(
        AppConstants.userAddress, userAddress);
  }

  static AddressModel? getUserAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    } catch (e) {
      debugPrint('Address Catch exception : $e');
    }
    return addressModel;
  }

  static bool clearAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    sharedPreferences.remove(AppConstants.userAddress);
    return true;
  }

  static  saveArea(String Area,String value) {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    sharedPreferences.setString(Area, value);
  }
  static getArea(String Area) {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    return sharedPreferences.getString(Area); // Return the stored value
  }
}
