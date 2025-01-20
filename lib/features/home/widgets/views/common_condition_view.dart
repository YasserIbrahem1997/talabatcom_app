import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talabatcom/features/item/controllers/item_controller.dart';
import 'package:talabatcom/features/language/controllers/language_controller.dart';
import 'package:talabatcom/features/home/widgets/web/web_basic_medicine_nearby_view_widget.dart';
import 'package:talabatcom/features/home/widgets/web/widgets/medicine_item_card.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/styles.dart';

class CommonConditionView extends StatelessWidget {
  const CommonConditionView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      return itemController.commonConditions != null
          ? itemController.commonConditions!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: Dimensions.paddingSizeDefault,
                              left: Get.find<LocalizationController>().isLtr
                                  ? Dimensions.paddingSizeDefault
                                  : 0,
                              right: Get.find<LocalizationController>().isLtr
                                  ? 0
                                  : Dimensions.paddingSizeDefault,
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('common_condition'.tr,
                                      style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeLarge)),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),
                                  SizedBox(
                                    height: 35,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: itemController
                                          .commonConditions!.length,
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        bool isSelected = itemController
                                                .selectedCommonCondition ==
                                            index;
                                        double width = double.parse(
                                                itemController
                                                    .commonConditions![index]
                                                    .name!
                                                    .length
                                                    .toString()) *
                                            5;
                                        return InkWell(
                                          onTap: () => itemController
                                              .selectCommonCondition(index),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: Dimensions
                                                    .paddingSizeDefault),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '${itemController.commonConditions![index].name}',
                                                  style: robotoMedium.copyWith(
                                                      color: isSelected
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .disabledColor),
                                                ),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraSmall),
                                                isSelected
                                                    ? Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            top: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        height: 2,
                                                        width: width,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ]),
                          ),
                          itemController.conditionWiseProduct != null &&
                                  itemController
                                      .conditionWiseProduct!.isNotEmpty
                              ? SizedBox(
                                  height: 250,
                                  width: double.infinity,
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeDefault),
                                    itemCount: itemController
                                        .conditionWiseProduct!.length,
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return MedicineItemCard(
                                          item: itemController
                                              .conditionWiseProduct![index]);
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            SizedBox(
                                      width: 30,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Padding(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault),
                                  child: Text('no_product_available'.tr),
                                )),
                        ]),
                  ),
                )
              : const SizedBox()
          : const MedicineCardShimmer();
    });
  }
}
