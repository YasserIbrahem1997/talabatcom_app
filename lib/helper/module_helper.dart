import 'package:get/get.dart';
import 'package:talabatcom/common/models/config_model.dart';
import 'package:talabatcom/common/models/module_model.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';

import '../features/flash_sale/domain/models/flash_sale_model.dart';

class ModuleHelper {
  static ModuleModel? getModule() {
    return Get.find<SplashController>().module;
  }

  static ModuleModel? getCacheModule() {
    return Get.find<SplashController>().cacheModule;
  }

  static Module getModuleConfig(String? moduleType) {
    return Get.find<SplashController>().getModuleConfig(moduleType);
  }
}
