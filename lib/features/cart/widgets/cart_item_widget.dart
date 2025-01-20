import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talabatcom/common/widgets/custom_asset_image_widget.dart';
import 'package:talabatcom/common/widgets/custom_image.dart';
import 'package:talabatcom/common/widgets/custom_ink_well.dart';
import 'package:talabatcom/common/widgets/item_bottom_sheet.dart';
import 'package:talabatcom/common/widgets/quantity_button.dart';
import 'package:talabatcom/common/widgets/rating_bar.dart';
import 'package:talabatcom/features/cart/controllers/cart_controller.dart';
import 'package:talabatcom/features/cart/domain/models/cart_model.dart';
import 'package:talabatcom/features/item/domain/models/item_model.dart';
import 'package:talabatcom/features/language/controllers/language_controller.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/helper/price_converter.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/images.dart';
import 'package:talabatcom/util/styles.dart';

class CartItemWidget extends StatefulWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;

  const CartItemWidget(
      {super.key,
      required this.cart,
      required this.cartIndex,
      required this.isAvailable,
      required this.addOns});

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  @override
  void initState() {
    super.initState();
    print("this cart in item ${widget.cart.note.toString()}");
  }

// استرجاع الملاحظة لطلب معين

// الدالة الخاصة بإظهار الملاحظة للطلب
  Future<String?> getNoteForOrder(int orderId) async {
    final prefs = await SharedPreferences.getInstance();

    // الحصول على البيانات الحالية (إذا كانت موجودة)
    String? notesJson = prefs.getString("orderNotes");
    if (notesJson != null) {
      Map<String, String> orderNotes =
          Map<String, String>.from(json.decode(notesJson));
      return orderNotes[orderId.toString()]; // إعادة الملاحظة للطلب
    }

    return null; // لا توجد ملاحظة للطلب
  }

  @override
  Widget build(BuildContext context) {
    double? startingPrice =
        _calculatePriceWithVariation(item: widget.cart.item);
    double? endingPrice = _calculatePriceWithVariation(
        item: widget.cart.item, isStartingPrice: false);
    String? variationText = _setupVariationText(cart: widget.cart);
    String addOnText = _setupAddonsText(cart: widget.cart) ?? '';

    double? discount = widget.cart.item!.storeDiscount == 0
        ? widget.cart.item!.discount
        : widget.cart.item!.storeDiscount;
    String? discountType = widget.cart.item!.storeDiscount == 0
        ? widget.cart.item!.discountType
        : 'percent';

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (context) {
                Get.find<CartController>()
                    .removeFromCart(widget.cartIndex, item: widget.cart.item);
              },
              backgroundColor: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(
                      Get.find<LocalizationController>().isLtr
                          ? Dimensions.radiusDefault
                          : 0),
                  left: Radius.circular(Get.find<LocalizationController>().isLtr
                      ? 0
                      : Dimensions.radiusDefault)),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: !ResponsiveHelper.isMobile(context)
                ? [const BoxShadow()]
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 1,
                    )
                  ],
          ),
          child: CustomInkWell(
            onTap: () {
              ResponsiveHelper.isMobile(context)
                  ? showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (con) => ItemBottomSheet(
                          item: widget.cart.item,
                          cartIndex: widget.cartIndex,
                          cart: widget.cart),
                    )
                  : showDialog(
                      context: context,
                      builder: (con) => Dialog(
                            child: ItemBottomSheet(
                                item: widget.cart.item,
                                cartIndex: widget.cartIndex,
                                cart: widget.cart),
                          ));
            },
            radius: Dimensions.radiusDefault,
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeExtraSmall,
                horizontal: Dimensions.paddingSizeSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImage(
                          image:
                              '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${widget.cart.item!.image}',
                          height: ResponsiveHelper.isDesktop(context) ? 90 : 70,
                          width: ResponsiveHelper.isDesktop(context) ? 90 : 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      widget.isAvailable
                          ? const SizedBox()
                          : Positioned(
                              top: 0,
                              left: 0,
                              bottom: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                    color: Colors.black.withOpacity(0.6)),
                                child: Text('not_available_now_break'.tr,
                                    textAlign: TextAlign.center,
                                    style: robotoRegular.copyWith(
                                      color: Colors.white,
                                      fontSize: 8,
                                    )),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(children: [
                            Flexible(
                              child: Text(
                                widget.cart.item!.name!,
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            ((Get.find<SplashController>()
                                            .configModel!
                                            .moduleConfig!
                                            .module!
                                            .unit! &&
                                        widget.cart.item!.unitType != null &&
                                        !Get.find<SplashController>()
                                            .getModuleConfig(
                                                widget.cart.item!.moduleType)
                                            .newVariation!) ||
                                    (Get.find<SplashController>()
                                            .configModel!
                                            .moduleConfig!
                                            .module!
                                            .vegNonVeg! &&
                                        Get.find<SplashController>()
                                            .configModel!
                                            .toggleVegNonVeg!))
                                ? !Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .unit!
                                    ? CustomAssetImageWidget(
                                        widget.cart.item!.veg == 0
                                            ? Images.nonVegImage
                                            : Images.vegImage,
                                        height: 11,
                                        width: 11,
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall,
                                            horizontal:
                                                Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1),
                                        ),
                                        child: Text(
                                          widget.cart.item!.unitType ?? '',
                                          style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeExtraSmall,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      )
                                : const SizedBox(),
                            SizedBox(
                                width: widget.cart.item!.isStoreHalalActive! &&
                                        widget.cart.item!.isHalalItem!
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0),
                            widget.cart.item!.isStoreHalalActive! &&
                                    widget.cart.item!.isHalalItem!
                                ? const CustomAssetImageWidget(Images.halalTag,
                                    height: 13, width: 13)
                                : const SizedBox(),
                          ]),
                          const SizedBox(height: 2),
                          RatingBar(
                              rating: widget.cart.item!.avgRating,
                              size: 12,
                              ratingCount: widget.cart.item!.ratingCount),
                          const SizedBox(height: 5),
                          Wrap(children: [
                            Row(
                              children: [
                                Text(
                                  '${PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType)}'
                                  '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: discount, discountType: discountType)}' : ''}',
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                            SizedBox(
                                width: discount! > 0
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0),
                            discount > 0
                                ? Text(
                                    '${PriceConverter.convertPrice(startingPrice)}'
                                    '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                                    textDirection: TextDirection.ltr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).disabledColor,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                    ),
                                  )
                                : const SizedBox(),
                          ]),
                          widget.cart.item!.isPrescriptionRequired!
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          ResponsiveHelper.isDesktop(context)
                                              ? Dimensions.paddingSizeExtraSmall
                                              : 2),
                                  child: Text(
                                    '* ${'prescription_required'.tr}',
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                                )
                              : const SizedBox(),
                          ResponsiveHelper.isDesktop(context)
                              ? (Get.find<SplashController>()
                                          .configModel!
                                          .moduleConfig!
                                          .module!
                                          .addOn! &&
                                      addOnText.isNotEmpty)
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top:
                                              Dimensions.paddingSizeExtraSmall),
                                      child: Row(children: [
                                        Text('${'addons'.tr}: ',
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall)),
                                        Flexible(
                                            child: Text(
                                          addOnText,
                                          style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .disabledColor),
                                        )),
                                      ]),
                                    )
                                  : const SizedBox()
                              : const SizedBox(),
                          ResponsiveHelper.isDesktop(context)
                              ? variationText!.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top:
                                              Dimensions.paddingSizeExtraSmall),
                                      child: Row(children: [
                                        Text('${'variations'.tr}: ',
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall)),
                                        Flexible(
                                            child: Text(
                                          variationText,
                                          style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .disabledColor),
                                        )),
                                      ]),
                                    )
                                  : const SizedBox()
                              : const SizedBox(),
                        ]),
                  ),
                  GetBuilder<CartController>(builder: (cartController) {
                    return Row(children: [
                      QuantityButton(
                        onTap: cartController.isLoading
                            ? null
                            : () {
                                if (widget.cart.quantity! > 1) {
                                  Get.find<CartController>().setQuantity(
                                      false,
                                      widget.cartIndex,
                                      widget.cart.stock,
                                      widget.cart.quantityLimit);
                                } else {
                                  Get.find<CartController>().removeFromCart(
                                      widget.cartIndex,
                                      item: widget.cart.item);
                                }
                              },
                        isIncrement: false,
                        showRemoveIcon: widget.cart.quantity! == 1,
                      ),
                      Text(
                        widget.cart.quantity.toString(),
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge),
                      ),
                      QuantityButton(
                        onTap: cartController.isLoading
                            ? null
                            : () {
                                Get.find<CartController>().forcefullySetModule(
                                    Get.find<CartController>()
                                        .cartList[0]
                                        .item!
                                        .moduleId!);
                                Get.find<CartController>().setQuantity(
                                    true,
                                    widget.cartIndex,
                                    widget.cart.stock,
                                    widget.cart.quantityLimit);
                              },
                        isIncrement: true,
                        color: cartController.isLoading
                            ? Theme.of(context).disabledColor
                            : null,
                      ),
                    ]);
                  }),
                ]),
                !ResponsiveHelper.isDesktop(context)
                    ? (Get.find<SplashController>()
                                .configModel!
                                .moduleConfig!
                                .module!
                                .addOn! &&
                            addOnText.isNotEmpty)
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeExtraSmall),
                            child: Row(children: [
                              SizedBox(
                                  width: ResponsiveHelper.isDesktop(context)
                                      ? 100
                                      : 80),
                              Text('${'addons'.tr}: ',
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall)),
                              Flexible(
                                  child: Text(
                                addOnText,
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor),
                              )),
                            ]),
                          )
                        : const SizedBox()
                    : const SizedBox(),
                Text(widget.cart.note.toString(),
                    style: TextStyle(color: Colors.black87)),
                !ResponsiveHelper.isDesktop(context)
                    ? variationText!.isNotEmpty
                        ? // الجزء الخاص بـ FutureBuilder لعرض الملاحظة
                        Padding(
                            padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeExtraSmall),
                            child: Flexible(
                              child: FutureBuilder<String?>(
                                future: getNoteForOrder(widget.cart.item!.id!
                                    .toInt()), // استدعاء الملاحظة بناءً على الطلب
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator(); // مؤشر تحميل أثناء الانتظار
                                  } else if (snapshot.hasError) {
                                    return Text("يوجد مشكله في حفظ الملاحظات ",
                                        style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context)
                                                .disabledColor));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data == null ||
                                      snapshot.data!.isEmpty) {
                                    return const SizedBox
                                        .shrink(); // لا توجد ملاحظة
                                  } else {
                                    return Row(children: [
                                      SizedBox(
                                          width: ResponsiveHelper.isDesktop(
                                                  context)
                                              ? 100
                                              : 80),
                                      Text(
                                          ResponsiveHelper.isDesktop(context)
                                              ? ''
                                              : '${'hint'.tr}: ',
                                          style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall)),
                                      Text(snapshot.data!,
                                          style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .disabledColor)),
                                    ]);
                                  }
                                },
                              ),
                            ),
                          )
                        : const SizedBox()
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double? _calculatePriceWithVariation(
      {required Item? item, bool isStartingPrice = true}) {
    double? startingPrice;
    double? endingPrice;

    if (item!.variations!.isNotEmpty) {
      List<double?> priceList = [];
      for (var variation in item.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if (priceList[0]! < priceList[priceList.length - 1]!) {
        endingPrice = priceList[priceList.length - 1];
      }
    } else {
      startingPrice = item.price;
    }
    if (isStartingPrice) {
      return startingPrice;
    } else {
      return endingPrice;
    }
  }

  String? _setupVariationText({required CartModel cart}) {
    String? variationText = '';

    if (Get.find<SplashController>()
        .getModuleConfig(cart.item!.moduleType)
        .newVariation!) {
      if (cart.foodVariations!.isNotEmpty) {
        for (int index = 0; index < cart.foodVariations!.length; index++) {
          if (cart.foodVariations![index].contains(true)) {
            variationText =
                '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${cart.item!.foodVariations![index].name} (';
            for (int i = 0; i < cart.foodVariations![index].length; i++) {
              if (cart.foodVariations![index][i]!) {
                variationText =
                    '${variationText!}${variationText.endsWith('(') ? '' : ', '}${cart.item!.foodVariations![index].variationValues![i].level}';
              }
            }
            variationText = '${variationText!})';
          }
        }
      }
    } else {
      if (cart.variation!.isNotEmpty) {
        List<String> variationTypes = cart.variation![0].type!.split('-');
        if (variationTypes.length == cart.item!.choiceOptions!.length) {
          int index0 = 0;
          for (var choice in cart.item!.choiceOptions!) {
            variationText =
                '${variationText!}${(index0 == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index0]}';
            index0 = index0 + 1;
          }
        } else {
          variationText = cart.item!.variations![0].type;
        }
      }
    }
    return variationText;
  }

  String? _setupAddonsText({required CartModel cart}) {
    String addOnText = '';
    int index0 = 0;
    List<int?> ids = [];
    List<int?> qtys = [];
    for (var addOn in cart.addOnIds!) {
      ids.add(addOn.id);
      qtys.add(addOn.quantity);
    }
    for (var addOn in cart.item!.addOns!) {
      if (ids.contains(addOn.id)) {
        addOnText =
            '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
        index0 = index0 + 1;
      }
    }
    return addOnText;
  }
}
