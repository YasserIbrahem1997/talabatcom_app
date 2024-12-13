import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talabatcom/common/widgets/custom_ink_well.dart';
import 'package:talabatcom/features/item/controllers/item_controller.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/features/item/domain/models/item_model.dart';
import 'package:talabatcom/features/taxi_booking/booking_checkout_screen/widgets/custom_text.dart';
import 'package:talabatcom/helper/price_converter.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/util/app_constants.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/images.dart';
import 'package:talabatcom/util/styles.dart';
import 'package:talabatcom/common/widgets/add_favourite_view.dart';
import 'package:talabatcom/common/widgets/cart_count_view.dart';
import 'package:talabatcom/common/widgets/custom_image.dart';
import 'package:talabatcom/common/widgets/discount_tag.dart';
import 'package:talabatcom/common/widgets/hover/on_hover.dart';
import 'package:talabatcom/common/widgets/organic_tag.dart';

class MedicineItemCard extends StatelessWidget {
  final Item item;

  const MedicineItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.ecommerce;
    double? discount =
        item.storeDiscount == 0 ? item.discount : item.storeDiscount;
    String? discountType =
        item.storeDiscount == 0 ? item.discountType : 'percent';

    return OnHover(
      isItem: true,
      child: Container(
        width: ResponsiveHelper.isDesktop(context)
            ? 230
            : isShop
                ? 200
                : 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
        ),
        child: CustomInkWell(
          onTap: () =>
              Get.find<ItemController>().navigateToItemPage(item, context),
          radius: Dimensions.radiusDefault,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(children: [
                  item.stock == 0 ? Container(
                    decoration: BoxDecoration(

                color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radiusDefault),
                          topRight: Radius.circular(Dimensions.radiusDefault),
                        ),
                      image: DecorationImage(
                          opacity: 0.250,
                          fit: BoxFit.cover,
                          image: NetworkImage(
                        '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                            '/${item.image}',
                      ))
                    ),
                    child: Center(
                      child: Text(
                        'not_available_now_break'.tr, textAlign: TextAlign.center,
                        style: robotoMedium.copyWith(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ):     ClipRRect(

                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radiusDefault),
                      topRight: Radius.circular(Dimensions.radiusDefault),
                    ),
                    child: CustomImage(
                      placeholder: Images.placeholder,
                      image:
                          '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                          '/${item.image}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  AddFavouriteView(
                    item: item,
                  ),
                  DiscountTag(
                    discount: discount,
                    discountType: discountType,
                    freeDelivery: false,
                  ),
                  OrganicTag(item: item, placeInImage: false),
                  isShop
                      ? const SizedBox()
                      : Positioned(
                          bottom: 10,
                          right: 10,
                          child: CartCountView(
                            item: item,
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColor),
                              child: Icon(Icons.add,
                                  size: 20, color: Theme.of(context).cardColor),
                            ),
                          ),
                        ),
                ]),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(
                    crossAxisAlignment: isShop
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        item.storeName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).disabledColor),
                      ),
                      Text(
                        item.name ?? '',
                        style: robotoBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isShop
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Icon(Icons.star,
                                      size: 15,
                                      color: Theme.of(context).primaryColor),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Text(item.avgRating.toString(),
                                      style: robotoRegular),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Text("(${item.ratingCount})",
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color:
                                              Theme.of(context).disabledColor)),
                                ])
                          : const SizedBox(),
                      item.discount != null && item.discount! > 0
                          ? Text(
                              PriceConverter.convertPrice(
                                  Get.find<ItemController>()
                                      .getStartingPrice(item)),
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).disabledColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                              textDirection: TextDirection.rtl,
                            )
                          : const SizedBox(),
                      Align(
                        alignment:
                            isShop ? Alignment.center : Alignment.centerLeft,
                        child: Row(
                            mainAxisAlignment: isShop
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            children: [
                              Text(
                                PriceConverter.convertPrice(
                                  Get.find<ItemController>()
                                      .getStartingPrice(item),
                                  discount: item.discount,
                                  discountType: item.discountType,
                                ),
                                textDirection: TextDirection.rtl,
                                style: robotoMedium,
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              (Get.find<SplashController>()
                                          .configModel!
                                          .moduleConfig!
                                          .module!
                                          .unit! &&
                                      item.unitType != null)
                                  ? Text(
                                      '/ ${item.unitType ?? ''}',
                                      style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color: Theme.of(context).hintColor),
                                    )
                                  : const SizedBox(),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
