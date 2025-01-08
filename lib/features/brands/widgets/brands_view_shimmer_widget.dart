import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talabatcom/common/widgets/title_widget.dart';
import 'package:talabatcom/util/dimensions.dart';

class BrandViewShimmer extends StatelessWidget {
  const BrandViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: TitleWidget(
          title: 'brands'.tr,
          onTap: () => null,
        ),
      ),

      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 13, mainAxisSpacing: 13,
          childAspectRatio: 1.0,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            enabled: true,
            baseColor: Colors.white.withOpacity(0.05) ,
            highlightColor: Colors.white.withOpacity(0.05) ,
            child: Container(
              height: 100,
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[300],
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [BoxShadow(color: Get.isDarkMode ? Colors.black12 : Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
              ),
              child: Row(children: [

                Container(
                  height: 80, width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: Get.isDarkMode ? Theme.of(context).disabledColor.withOpacity(0.2) : Theme.of(context).cardColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 20, width: double.maxFinite, color: Get.isDarkMode ? Theme.of(context).disabledColor.withOpacity(0.2) : Theme.of(context).cardColor),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(height: 15, width: double.maxFinite, color: Get.isDarkMode ? Theme.of(context).disabledColor.withOpacity(0.2) : Theme.of(context).cardColor),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(height: 15, width: double.maxFinite, color: Get.isDarkMode ? Theme.of(context).disabledColor.withOpacity(0.2) : Theme.of(context).cardColor),
                  ]),
                ),

              ]),
            ),
          );
        },
      ),

    ]);
  }
}