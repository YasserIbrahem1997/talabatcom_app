import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talabatcom/common/widgets/cart_snackbar.dart';
import 'package:talabatcom/common/widgets/confirmation_dialog.dart';
import 'package:talabatcom/common/widgets/custom_app_bar.dart';
import 'package:talabatcom/common/widgets/custom_button.dart';
import 'package:talabatcom/common/widgets/custom_snackbar.dart';
import 'package:talabatcom/common/widgets/menu_drawer.dart';
import 'package:talabatcom/features/cart/controllers/cart_controller.dart';
import 'package:talabatcom/features/cart/domain/models/cart_model.dart';
import 'package:talabatcom/features/checkout/domain/models/place_order_body_model.dart';
import 'package:talabatcom/features/checkout/screens/checkout_screen.dart';
import 'package:talabatcom/features/item/controllers/item_controller.dart';
import 'package:talabatcom/features/item/domain/models/item_model.dart';
import 'package:talabatcom/features/item/widgets/details_app_bar_widget.dart';
import 'package:talabatcom/features/item/widgets/details_web_view_widget.dart';
import 'package:talabatcom/features/item/widgets/item_image_view_widget.dart';
import 'package:talabatcom/features/item/widgets/item_title_view_widget.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/helper/price_converter.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/helper/route_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/images.dart';
import 'package:talabatcom/util/styles.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Item? item;
  final bool inStorePage;

  const ItemDetailsScreen(
      {super.key, required this.item, required this.inStorePage});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final Size size = Get.size;
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final GlobalKey<DetailsAppBarWidgetState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    Get.find<ItemController>().getProductDetails(widget.item!);
    Get.find<ItemController>().setSelect(0, false);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController textNote = TextEditingController();
    return GetBuilder<CartController>(builder: (cartController) {
      return GetBuilder<ItemController>(
        builder: (itemController) {
          int? stock = 0;
          CartModel? cartModel;
          OnlineCart? cart;
          double priceWithAddons = 0;
          int? cartId = cartController.getCartId(itemController.cartIndex);
          if (itemController.item != null &&
              itemController.variationIndex != null) {
            List<String> variationList = [];
            for (int index = 0;
                index < itemController.item!.choiceOptions!.length;
                index++) {
              variationList.add(itemController.item!.choiceOptions![index]
                  .options![itemController.variationIndex![index]]
                  .replaceAll(' ', ''));
            }
            String variationType = '';
            bool isFirst = true;
            for (var variation in variationList) {
              if (isFirst) {
                variationType = '$variationType$variation';
                isFirst = false;
              } else {
                variationType = '$variationType-$variation';
              }
            }

            double? price = itemController.item!.price;
            Variation? variation;
            stock = itemController.item!.stock ?? 0;
            for (Variation v in itemController.item!.variations!) {
              if (v.type == variationType) {
                price = v.price;
                variation = v;
                stock = v.stock;
                break;
              }
            }

            double? discount =
                (itemController.item!.availableDateStarts != null ||
                        itemController.item!.storeDiscount == 0)
                    ? itemController.item!.discount
                    : itemController.item!.storeDiscount;
            String? discountType =
                (itemController.item!.availableDateStarts != null ||
                        itemController.item!.storeDiscount == 0)
                    ? itemController.item!.discountType
                    : 'percent';
            double priceWithDiscount = PriceConverter.convertWithDiscount(
                price, discount, discountType)!;
            double priceWithQuantity =
                priceWithDiscount * itemController.quantity!;
            double addonsCost = 0;
            List<AddOn> addOnIdList = [];
            List<AddOns> addOnsList = [];
            for (int index = 0;
                index < itemController.item!.addOns!.length;
                index++) {
              if (itemController.addOnActiveList[index]) {
                addonsCost = addonsCost +
                    (itemController.item!.addOns![index].price! *
                        itemController.addOnQtyList[index]!);
                addOnIdList.add(AddOn(
                    id: itemController.item!.addOns![index].id,
                    quantity: itemController.addOnQtyList[index]));
                addOnsList.add(itemController.item!.addOns![index]);
              }
            }

            cartModel = CartModel(
                null,
                price,
                priceWithDiscount,
                variation != null ? [variation] : [],
                [],
                (price! -
                    PriceConverter.convertWithDiscount(
                        price, discount, discountType)!),
                itemController.quantity,
                addOnIdList,
                addOnsList,
                itemController.item!.availableDateStarts != null,
                stock,
                textNote.text.trim(),
                itemController.item,
                itemController.item?.quantityLimit);

            List<int?> listOfAddOnId =
                _getSelectedAddonIds(addOnIdList: addOnIdList);
            List<int?> listOfAddOnQty =
                _getSelectedAddonQtnList(addOnIdList: addOnIdList);

            cart = OnlineCart(
                cartId,
                widget.item!.id,
                null,
                priceWithDiscount.toString(),
                '',
                variation != null ? [variation] : [],
                null,
                itemController.cartIndex != -1
                    ? cartController.cartList[itemController.cartIndex].quantity
                    : itemController.quantity,
                listOfAddOnId,
                addOnsList,
                listOfAddOnQty,
                'Item',
                textNote.text.trim());
            priceWithAddons = priceWithQuantity +
                (Get.find<SplashController>()
                        .configModel!
                        .moduleConfig!
                        .module!
                        .addOn!
                    ? addonsCost
                    : 0);
          }

          return Scaffold(
            key: _globalKey,
            backgroundColor: Theme.of(context).cardColor,
            endDrawer: const MenuDrawer(),
            endDrawerEnableOpenDragGesture: false,
            appBar: ResponsiveHelper.isDesktop(context)
                ? const CustomAppBar(title: '')
                : DetailsAppBarWidget(key: _key),
            body: SafeArea(
                child: (itemController.item != null)
                    ? ResponsiveHelper.isDesktop(context)
                        ? DetailsWebViewWidget(
                            cartModel: cartModel,
                            stock: stock,
                            priceWithAddOns: priceWithAddons,
                            cart: cart,
                          )
                        : Column(children: [
                            // todo : thi details screen
                            Expanded(
                                child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall),
                                    physics: const BouncingScrollPhysics(),
                                    child: Center(
                                        child: SizedBox(
                                            width: Dimensions.webMaxWidth,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ItemImageViewWidget(
                                                    item: itemController.item),
                                                const SizedBox(height: 20),

                                                Builder(builder: (context) {
                                                  return ItemTitleViewWidget(
                                                    item: itemController.item,
                                                    inStorePage:
                                                        widget.inStorePage,
                                                    isCampaign: itemController
                                                            .item!
                                                            .availableDateStarts !=
                                                        null,
                                                    inStock: (Get.find<
                                                                SplashController>()
                                                            .configModel!
                                                            .moduleConfig!
                                                            .module!
                                                            .stock! &&
                                                        stock! <= 0),
                                                  );
                                                }),
                                                const Divider(
                                                    height: 20, thickness: 2),

                                                // Variation
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: itemController
                                                      .item!
                                                      .choiceOptions!
                                                      .length,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              itemController
                                                                  .item!
                                                                  .choiceOptions![
                                                                      index]
                                                                  .title!,
                                                              style: robotoMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeLarge)),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          GridView.builder(
                                                            gridDelegate:
                                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 3,
                                                              crossAxisSpacing:
                                                                  20,
                                                              mainAxisSpacing:
                                                                  10,
                                                              childAspectRatio:
                                                                  (1 / 0.25),
                                                            ),
                                                            shrinkWrap: true,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemCount:
                                                                itemController
                                                                    .item!
                                                                    .choiceOptions![
                                                                        index]
                                                                    .options!
                                                                    .length,
                                                            itemBuilder:
                                                                (context, i) {
                                                              return InkWell(
                                                                onTap: () {
                                                                  itemController
                                                                      .setCartVariationIndex(
                                                                          index,
                                                                          i,
                                                                          itemController
                                                                              .item);
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          Dimensions
                                                                              .paddingSizeExtraSmall),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: itemController.variationIndex![index] !=
                                                                            i
                                                                        ? Theme.of(context)
                                                                            .disabledColor
                                                                        : Theme.of(context)
                                                                            .primaryColor,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: itemController.variationIndex![index] !=
                                                                            i
                                                                        ? Border.all(
                                                                            color:
                                                                                Theme.of(context).disabledColor,
                                                                            width: 2)
                                                                        : null,
                                                                  ),
                                                                  child: Text(
                                                                    itemController
                                                                        .item!
                                                                        .choiceOptions![
                                                                            index]
                                                                        .options![
                                                                            i]
                                                                        .trim(),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: robotoRegular
                                                                        .copyWith(
                                                                      color: itemController.variationIndex![index] != i
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          SizedBox(
                                                              height: index !=
                                                                      itemController
                                                                              .item!
                                                                              .choiceOptions!
                                                                              .length -
                                                                          1
                                                                  ? Dimensions
                                                                      .paddingSizeLarge
                                                                  : 0),
                                                        ]);
                                                  },
                                                ),
                                                // Column(
                                                //   crossAxisAlignment:
                                                //       CrossAxisAlignment.start,
                                                //   children: [
                                                //     ListView.builder(
                                                //       shrinkWrap: true,
                                                //       physics:
                                                //           NeverScrollableScrollPhysics(),
                                                //       itemCount: widget
                                                //           .item!
                                                //           .foodVariations!
                                                //           .length,
                                                //       itemBuilder:
                                                //           (context, index) {
                                                //         return Column(
                                                //           crossAxisAlignment:
                                                //               CrossAxisAlignment
                                                //                   .start,
                                                //           children: [
                                                //             Text(
                                                //               widget
                                                //                       .item!
                                                //                       .foodVariations![
                                                //                           index]
                                                //                       .name ??
                                                //                   '',
                                                //               style: TextStyle(
                                                //                   fontWeight:
                                                //                       FontWeight
                                                //                           .bold),
                                                //             ),
                                                //             ListView.builder(
                                                //               shrinkWrap: true,
                                                //               physics:
                                                //                   NeverScrollableScrollPhysics(),
                                                //               itemCount: widget
                                                //                   .item!
                                                //                   .foodVariations![
                                                //                       index]
                                                //                   .variationValues!
                                                //                   .length,
                                                //               itemBuilder:
                                                //                   (context, i) {
                                                //                 final variation = widget
                                                //                     .item!
                                                //                     .foodVariations![
                                                //                         index]
                                                //                     .variationValues![i];
                                                //                 return ListTile(
                                                //                   onTap: () {
                                                //                     itemController.setNewCartVariationIndex(
                                                //                         index,
                                                //                         i,
                                                //                         widget
                                                //                             .item!);
                                                //                     setState(
                                                //                         () {}); // لتحديث السعر النهائي
                                                //                   },
                                                //                   leading: widget
                                                //                               .item!
                                                //                               .foodVariations![
                                                //                                   index]
                                                //                               .multiSelect ==
                                                //                           true
                                                //                       ? Checkbox(
                                                //                           value:
                                                //                               itemController.selectedVariations[index][i],
                                                //                           onChanged:
                                                //                               (newValue) {
                                                //                             itemController.setNewCartVariationIndex(
                                                //                                 index,
                                                //                                 i,
                                                //                                 widget.item!);
                                                //                             setState(() {});
                                                //                           },
                                                //                         )
                                                //                       : Radio<
                                                //                           int>(
                                                //                           value:
                                                //                               i,
                                                //                           groupValue: (itemController.selectedVariations.length > index)
                                                //                               ? itemController.selectedVariations[index].indexOf(true)
                                                //                               : -1,
                                                //                           onChanged:
                                                //                               (newValue) {
                                                //                             itemController.setNewCartVariationIndex(
                                                //                                 index,
                                                //                                 i,
                                                //                                 widget.item!);
                                                //                             setState(() {});
                                                //                           },
                                                //                         ),
                                                //                   title: Text(
                                                //                       variation
                                                //                               .level ??
                                                //                           ''),
                                                //                   trailing:
                                                //                       variation.optionPrice !=
                                                //                               0
                                                //                           ? Text(
                                                //                               '+${PriceConverter.convertPrice(variation.optionPrice)}',
                                                //                               style: TextStyle(color: Colors.grey[700]),
                                                //                             )
                                                //                           : null,
                                                //                 );
                                                //               },
                                                //             ),
                                                //             const SizedBox(
                                                //                 height: 12),
                                                //           ],
                                                //         );
                                                //       },
                                                //     ),
                                                //     Divider(thickness: 1),
                                                //     const SizedBox(height: 10),
                                                //     Row(
                                                //       mainAxisAlignment:
                                                //           MainAxisAlignment
                                                //               .spaceBetween,
                                                //       children: [
                                                //         // Text(
                                                //         //   '${'total_price'.tr}: ${PriceConverter.convertPrice(itemController.getTotalPrice(widget.item!))}',
                                                //         //   style: TextStyle(
                                                //         //       fontSize: 16,
                                                //         //       fontWeight:
                                                //         //           FontWeight
                                                //         //               .bold),
                                                //         // ),
                                                //       ],
                                                //     )
                                                //   ],
                                                // ),

                                                itemController
                                                        .item!
                                                        .choiceOptions!
                                                        .isNotEmpty
                                                    ? const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge)
                                                    : const SizedBox(),

                                                // Quantity
                                                GetBuilder<CartController>(
                                                    builder: (cartController) {
                                                  return Row(children: [
                                                    Text('quantity'.tr,
                                                        style: robotoMedium.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge)),
                                                    const Expanded(
                                                        child: SizedBox()),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: Row(children: [
                                                        InkWell(
                                                          onTap:
                                                              cartController
                                                                      .isLoading
                                                                  ? null
                                                                  : () {
                                                                      if (itemController
                                                                              .cartIndex !=
                                                                          -1) {
                                                                        if (cartController.cartList[itemController.cartIndex].quantity! >
                                                                            1) {
                                                                          cartController.setQuantity(
                                                                              false,
                                                                              itemController.cartIndex,
                                                                              stock,
                                                                              cartController.cartList[itemController.cartIndex].quantity);
                                                                        }
                                                                      } else {
                                                                        if (itemController.quantity! >
                                                                            1) {
                                                                          itemController.setQuantity(
                                                                              false,
                                                                              stock,
                                                                              itemController.item!.quantityLimit);
                                                                        }
                                                                      }
                                                                    },
                                                          child: const Padding(
                                                            padding: EdgeInsets.symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            child: Icon(
                                                                Icons.remove,
                                                                size: 20),
                                                          ),
                                                        ),
                                                        !cartController
                                                                .isLoading
                                                            ? Text(
                                                                itemController
                                                                            .cartIndex !=
                                                                        -1
                                                                    ? cartController
                                                                        .cartList[itemController
                                                                            .cartIndex]
                                                                        .quantity
                                                                        .toString()
                                                                    : itemController
                                                                        .quantity
                                                                        .toString(),
                                                                style: robotoMedium
                                                                    .copyWith(
                                                                        fontSize:
                                                                            Dimensions.fontSizeExtraLarge),
                                                              )
                                                            : const SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child:
                                                                    CircularProgressIndicator()),
                                                        InkWell(
                                                          onTap: cartController
                                                                  .isLoading
                                                              ? null
                                                              : () => itemController.cartIndex !=
                                                                      -1
                                                                  ? cartController.setQuantity(
                                                                      true,
                                                                      itemController
                                                                          .cartIndex,
                                                                      stock,
                                                                      cartController
                                                                          .cartList[itemController
                                                                              .cartIndex]
                                                                          .quantityLimit)
                                                                  : itemController.setQuantity(
                                                                      true,
                                                                      stock,
                                                                      itemController
                                                                          .item!
                                                                          .quantityLimit),
                                                          child: const Padding(
                                                            padding: EdgeInsets.symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            child: Icon(
                                                                Icons.add,
                                                                size: 20),
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                  ]);
                                                }),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeLarge),

                                                Row(children: [
                                                  Text('${'total_amount'.tr}:',
                                                      style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge)),
                                                  const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall),
                                                  Text(
                                                    PriceConverter.convertPrice(itemController
                                                                .cartIndex !=
                                                            -1
                                                        ? _getItemDetailsDiscountPrice(
                                                            cart: Get.find<
                                                                        CartController>()
                                                                    .cartList[
                                                                itemController
                                                                    .cartIndex])
                                                        : priceWithAddons),
                                                    style: robotoBold.copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: Dimensions
                                                            .fontSizeLarge),
                                                  ),
                                                ]),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraLarge),

                                                (itemController.item!
                                                                .description !=
                                                            null &&
                                                        itemController
                                                            .item!
                                                            .description!
                                                            .isNotEmpty)
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('description'.tr,
                                                              style:
                                                                  robotoMedium),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Text(
                                                              itemController
                                                                  .item!
                                                                  .description!,
                                                              style:
                                                                  robotoRegular),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeLarge),
                                                        ],
                                                      )
                                                    : const SizedBox(),

                                                itemController.item!
                                                        .isPrescriptionRequired!
                                                    ? Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeSmall,
                                                            vertical: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .error
                                                              .withOpacity(0.1),
                                                          borderRadius: BorderRadius
                                                              .circular(Dimensions
                                                                  .radiusSmall),
                                                        ),
                                                        child: Text(
                                                          '* ${'prescription_required'.tr}',
                                                          style: robotoRegular.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .error),
                                                        ),
                                                      )
                                                    : const SizedBox(),

                                                TextFormField(
                                                  controller: textNote,
                                                  maxLines:
                                                      4, // Allows multiple lines (at least 2 as you need)
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "Write_your_notes_here"
                                                            .tr,
                                                    filled:
                                                        true, // Adds a background color
                                                    fillColor: Colors
                                                        .white, // Background color
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.red
                                                              .shade200), // Light red border
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10), // Border radius
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey
                                                              .shade400), // Slightly darker red when focused
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10), // Border radius
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .red.shade200),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                      color: Colors
                                                          .black), // Text color inside the field
                                                )
                                              ],
                                            ))))),

                            // todo : this button add to cart
                            GetBuilder<CartController>(
                                builder: (cartController) {
                              return Container(
                                width: 1170,
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall),
                                child: CustomButton(
                                  isLoading: cartController.isLoading,
                                  buttonText: (Get.find<SplashController>()
                                              .configModel!
                                              .moduleConfig!
                                              .module!
                                              .stock! &&
                                          stock! <= 0)
                                      ? 'out_of_stock'.tr
                                      : itemController
                                                  .item!.availableDateStarts !=
                                              null
                                          ? 'order_now'.tr
                                          : itemController.cartIndex != -1
                                              ? 'update_in_cart'.tr
                                              : 'add_to_cart'.tr,
                                  onPressed: (!Get.find<SplashController>()
                                              .configModel!
                                              .moduleConfig!
                                              .module!
                                              .stock! ||
                                          stock! > 0)
                                      ? () async {
                                          if (!Get.find<SplashController>()
                                                  .configModel!
                                                  .moduleConfig!
                                                  .module!
                                                  .stock! ||
                                              stock! > 0) {
                                            if (itemController.item!
                                                    .availableDateStarts !=
                                                null) {
                                              Get.toNamed(
                                                  RouteHelper.getCheckoutRoute(
                                                      'campaign'),
                                                  arguments: CheckoutScreen(
                                                    storeId: null,
                                                    fromCart: false,
                                                    cartList: [cartModel],
                                                  ));
                                            } else {
                                              if (cartController.existAnotherStoreItem(
                                                  cartModel!.item!.storeId,
                                                  Get.find<SplashController>()
                                                              .module ==
                                                          null
                                                      ? Get.find<
                                                              SplashController>()
                                                          .cacheModule!
                                                          .id
                                                      : Get.find<
                                                              SplashController>()
                                                          .module!
                                                          .id)) {
                                                Get.dialog(
                                                    ConfirmationDialog(
                                                      icon: Images.warning,
                                                      title:
                                                          'are_you_sure_to_reset'
                                                              .tr,
                                                      description: Get.find<
                                                                  SplashController>()
                                                              .configModel!
                                                              .moduleConfig!
                                                              .module!
                                                              .showRestaurantText!
                                                          ? 'if_you_continue'.tr
                                                          : 'if_you_continue_without_another_store'
                                                              .tr,
                                                      onYesPressed: () {
                                                        Get.back();
                                                        cartController
                                                            .clearCartOnline()
                                                            .then(
                                                                (success) async {
                                                          if (success) {
                                                            await cartController
                                                                .addToCartOnline(
                                                                    cart!);
                                                            itemController
                                                                .setExistInCart(
                                                                    widget
                                                                        .item);
                                                            showCartSnackBar();
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    barrierDismissible: false);
                                              } else {
                                                if (itemController.cartIndex ==
                                                    -1) {
                                                  await cartController
                                                      .addToCartOnline(cart!)
                                                      .then((success) {
                                                    if (success) {
                                                      itemController
                                                          .setExistInCart(
                                                              widget.item);
                                                      showCartSnackBar();
                                                      _key.currentState!
                                                          .shake();
                                                    }
                                                  });
                                                } else {
                                                  await cartController
                                                      .updateCartOnline(cart!)
                                                      .then((success) {
                                                    if (success) {
                                                      showCartSnackBar();
                                                      _key.currentState!
                                                          .shake();
                                                    }
                                                  });
                                                }
                                              }
                                            }
                                          }
                                        }
                                      : null,
                                ),
                              );
                            }),
                          ])
                    : const Center(child: CircularProgressIndicator())),
          );
        },
      );
    });
  }

  List<int?> _getSelectedAddonIds({required List<AddOn> addOnIdList}) {
    List<int?> listOfAddOnId = [];
    for (var addOn in addOnIdList) {
      listOfAddOnId.add(addOn.id);
    }
    return listOfAddOnId;
  }

  List<int?> _getSelectedAddonQtnList({required List<AddOn> addOnIdList}) {
    List<int?> listOfAddOnQty = [];
    for (var addOn in addOnIdList) {
      listOfAddOnQty.add(addOn.quantity);
    }
    return listOfAddOnQty;
  }

  double _getItemDetailsDiscountPrice({required CartModel cart}) {
    double discountedPrice = 0;

    double? discount = cart.item!.storeDiscount == 0
        ? cart.item!.discount!
        : cart.item!.storeDiscount!;
    String? discountType =
        (cart.item!.storeDiscount == 0) ? cart.item!.discountType : 'percent';
    String variationType = cart.variation != null && cart.variation!.isNotEmpty
        ? cart.variation![0].type!
        : '';

    if (cart.variation != null && cart.variation!.isNotEmpty) {
      for (Variation variation in cart.item!.variations!) {
        if (variation.type == variationType) {
          discountedPrice = (PriceConverter.convertWithDiscount(
                  variation.price!, discount, discountType)! *
              cart.quantity!);
          break;
        }
      }
    } else {
      discountedPrice = (PriceConverter.convertWithDiscount(
              cart.item!.price!, discount, discountType)! *
          cart.quantity!);
    }

    return discountedPrice;
  }
}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int? quantity;
  final bool isCartWidget;
  final int? stock;
  final bool isExistInCart;
  final int cartIndex;
  final int? quantityLimit;
  final CartController cartController;

  const QuantityButton({
    super.key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.isExistInCart,
    required this.cartIndex,
    this.isCartWidget = false,
    this.quantityLimit,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cartController.isLoading
          ? null
          : () {
              if (isExistInCart) {
                if (!isIncrement && quantity! > 1) {
                  Get.find<CartController>()
                      .setQuantity(false, cartIndex, stock, quantityLimit);
                } else if (isIncrement && quantity! > 0) {
                  if (quantity! < stock! ||
                      !Get.find<SplashController>()
                          .configModel!
                          .moduleConfig!
                          .module!
                          .stock!) {
                    Get.find<CartController>()
                        .setQuantity(true, cartIndex, stock, quantityLimit);
                  } else {
                    showCustomSnackBar('out_of_stock'.tr);
                  }
                }
              } else {
                if (!isIncrement && quantity! > 1) {
                  Get.find<ItemController>()
                      .setQuantity(false, stock, quantityLimit);
                } else if (isIncrement && quantity! > 0) {
                  if (quantity! < stock! ||
                      !Get.find<SplashController>()
                          .configModel!
                          .moduleConfig!
                          .module!
                          .stock!) {
                    Get.find<ItemController>()
                        .setQuantity(true, stock, quantityLimit);
                  } else {
                    showCustomSnackBar('out_of_stock'.tr);
                  }
                }
              }
            },
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (quantity! == 1 && !isIncrement) || cartController.isLoading
              ? Theme.of(context).disabledColor
              : Theme.of(context).primaryColor,
        ),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: isIncrement
                ? Colors.white
                : quantity! == 1
                    ? Colors.black
                    : Colors.white,
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ),
    );
  }
}
