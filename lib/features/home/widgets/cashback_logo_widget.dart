import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talabatcom/common/widgets/custom_asset_image_widget.dart';
import 'package:talabatcom/util/images.dart';
import 'package:talabatcom/util/styles.dart';
class CashBackLogoWidget extends StatelessWidget {
  const CashBackLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CustomAssetImageWidget(Images.cashBack),

        Positioned(
          top: 10, left: 15,
          child: Text('cash_back'.tr, style: robotoBold.copyWith(color: Colors.white)),
        )
      ],
    );
  }
}
