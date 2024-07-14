import 'package:talabatcom/features/favourite/controllers/favourite_controller.dart';
import 'package:talabatcom/features/auth/controllers/auth_controller.dart';
import 'package:talabatcom/helper/route_helper.dart';
import 'package:talabatcom/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false}) {
    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      Get.find<FavouriteController>().removeFavourite();
      Get.offAllNamed(GetPlatform.isWeb ? RouteHelper.getInitialRoute() : RouteHelper.getSignInRoute(RouteHelper.splash));
    }else {
      showCustomSnackBar(response.statusText, getXSnackBar: getXSnackBar);
    }
  }
}
