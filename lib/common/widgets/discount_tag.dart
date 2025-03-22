import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountTag extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double fromTop;
  final double? fontSize;
  final bool inLeft;
  final bool? freeDelivery;
  final bool? isFloating;
  const DiscountTag({super.key,
    required this.discount, required this.discountType, this.fromTop = 4, this.fontSize, this.freeDelivery = false,
    this.inLeft = true, this.isFloating = true,
  });

  @override
  Widget build(BuildContext context) {
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;

    return (discount! > 0 || freeDelivery!) ? Positioned(
      top: fromTop, left: inLeft ? isFloating! ? Dimensions.fontSizeExtraSmall : 0 : null, right: inLeft ? null : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.8),
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(isFloating! ? Dimensions.radiusLarge : inLeft ? Dimensions.radiusSmall : 0),
            left: Radius.circular(isFloating! ? Dimensions.radiusLarge : inLeft ? 0 : Dimensions.radiusSmall),
          ),
        ),
        child: Text(
          discount! > 0 ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%'
              : isRightSide ? currencySymbol : ''} ${'discount'.tr}' : 'free_delivery'.tr,
          style: robotoMedium.copyWith(
            color: Theme.of(context).cardColor,
            fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 10 : 14),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ) : const SizedBox();
  }
}
