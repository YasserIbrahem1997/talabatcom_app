import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_image_compression/flutter_image_compression.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:talabatcom/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/features/address/domain/models/address_model.dart';
import 'package:talabatcom/features/cart/domain/models/cart_model.dart';
import 'package:talabatcom/common/models/config_model.dart';
import 'package:talabatcom/features/checkout/controllers/checkout_controller.dart';
import 'package:talabatcom/helper/auth_helper.dart';
import 'package:talabatcom/helper/price_converter.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/styles.dart';
import 'package:talabatcom/common/widgets/custom_dropdown.dart';
import 'package:talabatcom/features/cart/widgets/delivery_option_button_widget.dart';
import 'package:talabatcom/features/checkout/widgets/coupon_section.dart';
import 'package:talabatcom/features/checkout/widgets/delivery_instruction_view.dart';
import 'package:talabatcom/features/checkout/widgets/delivery_section.dart';
import 'package:talabatcom/features/checkout/widgets/deliveryman_tips_section.dart';
import 'package:talabatcom/features/checkout/widgets/partial_pay_view.dart';
import 'package:talabatcom/features/checkout/widgets/payment_section.dart';
import 'package:talabatcom/features/checkout/widgets/time_slot_section.dart';
import 'package:talabatcom/features/checkout/widgets/web_delivery_instruction_view.dart';
import 'package:talabatcom/features/store/widgets/camera_button_sheet_widget.dart';
import 'dart:io';

class TopSection extends StatefulWidget {
  final CheckoutController checkoutController;
  final double charge;
  final double deliveryCharge;
  final List<DropdownItem<int>> addressList;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  final double price;
  final double discount;
  final double addOns;
  final int? storeId;
  final List<AddressModel> address;
  final List<CartModel?>? cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final bool isOfflinePaymentActive;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final JustTheController tooltipController1;
  final JustTheController tooltipController2;
  final JustTheController dmTipsTooltipController;

  const TopSection({
    super.key,
    required this.deliveryCharge,
    required this.charge,
    required this.tomorrowClosed,
    required this.todayClosed,
    required this.price,
    required this.discount,
    required this.addOns,
    required this.addressList,
    required this.checkoutController,
    this.module,
    this.storeId,
    required this.address,
    required this.cartList,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.isOfflinePaymentActive,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestNumberNode,
    required this.guestEmailController,
    required this.guestEmailNode,
    required this.tooltipController1,
    required this.tooltipController2,
    required this.dmTipsTooltipController,
  });

  @override
  State<TopSection> createState() => _TopSectionState();
}

class _TopSectionState extends State<TopSection> {
  double minimumShippingCharge = 0.0;

  // Function to update the shipping charge
  void updateMinimumShippingCharge(double newCharge) {
    setState(() {
      minimumShippingCharge = newCharge;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool takeAway = (widget.checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    final shippingController = Get.find<ShippingController>();

    return Container(
      decoration: ResponsiveHelper.isDesktop(context)
          ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
              ],
            )
          : null,
      child: Column(children: [
        widget.storeId != null
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        blurRadius: 10)
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('your_prescription'.tr, style: robotoMedium),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: widget.tooltipController1,
                          preferredDirection: AxisDirection.right,
                          tailLength: 14,
                          tailBaseWidth: 20,
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('prescription_tool_tip'.tr,
                                style: robotoRegular.copyWith(
                                    color: Colors.white)),
                          ),
                          child: InkWell(
                            onTap: () =>
                                widget.tooltipController1.showTooltip(),
                            child: const Icon(Icons.info_outline),
                          ),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.checkoutController
                                  .pickedPrescriptions.length +
                              1,
                          itemBuilder: (context, index) {
                            XFile? file = index ==
                                    widget.checkoutController
                                        .pickedPrescriptions.length
                                ? null
                                : widget.checkoutController
                                    .pickedPrescriptions[index];
                            if (index < 5 &&
                                index ==
                                    widget.checkoutController
                                        .pickedPrescriptions.length) {
                              return InkWell(
                                onTap: () {
                                  if (ResponsiveHelper.isDesktop(context)) {
                                    widget.checkoutController
                                        .pickPrescriptionImage(
                                            isRemove: false, isCamera: false);
                                  } else {
                                    Get.bottomSheet(
                                        const CameraButtonSheetWidget());
                                  }
                                },
                                child: DottedBorder(
                                  color: Theme.of(context).primaryColor,
                                  strokeWidth: 1,
                                  strokeCap: StrokeCap.butt,
                                  dashPattern: const [5, 5],
                                  padding: const EdgeInsets.all(0),
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(
                                      Dimensions.radiusDefault),
                                  child: Container(
                                    height: 98,
                                    width: 98,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.cloud_upload,
                                              color: Theme.of(context)
                                                  .disabledColor,
                                              size: 32),
                                          Text(
                                            'upload_your_prescription'.tr,
                                            style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                                fontSize:
                                                    Dimensions.fontSizeSmall),
                                            textAlign: TextAlign.center,
                                          ),
                                        ]),
                                  ),
                                ),
                              );
                            }
                            return file != null
                                ? Container(
                                    margin: const EdgeInsets.only(
                                        right: Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                    ),
                                    child: DottedBorder(
                                      color: Theme.of(context).primaryColor,
                                      strokeWidth: 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: const [5, 5],
                                      padding: const EdgeInsets.all(0),
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(
                                          Dimensions.radiusDefault),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Stack(children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            child: GetPlatform.isWeb
                                                ? Image.network(
                                                    file.path,
                                                    width: 98,
                                                    height: 98,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(file.path),
                                                    width: 98,
                                                    height: 98,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: InkWell(
                                              onTap: () => widget
                                                  .checkoutController
                                                  .removePrescriptionImage(
                                                      index),
                                              child: const Padding(
                                                padding: EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeSmall),
                                                child: Icon(
                                                    Icons.delete_forever,
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          },
                        ),
                      ),
                    ]),
              )
            : const SizedBox(),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // delivery option
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  blurRadius: 10)
            ],
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeSmall),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('delivery_type'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              widget.storeId != null
                  ? DeliveryOptionButtonWidget(
                      value: 'delivery',
                      title: 'home_delivery'.tr,
                      charge: widget.charge,
                      isFree: widget.checkoutController.store!.freeDelivery,
                      fromWeb: true,
                      total: widget.total,
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        Get.find<SplashController>()
                                        .configModel!
                                        .homeDeliveryStatus ==
                                    1 &&
                                widget.checkoutController.store!.delivery!
                            ? DeliveryOptionButtonWidget(
                                value: 'delivery',
                                title: 'home_delivery'.tr,
                                charge: widget.charge,
                                isFree: widget
                                    .checkoutController.store!.freeDelivery,
                                fromWeb: true,
                                total: widget.total,
                              )
                            : const SizedBox(),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Get.find<SplashController>()
                                        .configModel!
                                        .takeawayStatus ==
                                    1 &&
                                widget.checkoutController.store!.takeAway!
                            ? DeliveryOptionButtonWidget(
                                value: 'take_away',
                                title: 'take_away'.tr,
                                charge: widget.deliveryCharge,
                                isFree: true,
                                fromWeb: true,
                                total: widget.total,
                              )
                            : const SizedBox(),
                      ]),
                    ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        ///Delivery_fee
        !takeAway && !isGuestLoggedIn
            ? Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${'delivery_charge'.tr}: '),
                Obx((){
                  return  Text(
                    widget.checkoutController.store!.freeDelivery!
                        ? 'free'.tr
                        : widget.checkoutController.distance != -1
                        ? PriceConverter.convertPrice(
                        shippingController.minimumShippingCharge.value)
                        : 'calculating'.tr,
                    textDirection: TextDirection.rtl,
                  );
                })

              ]))
            : const SizedBox(),
        SizedBox(
            height: !takeAway && !isGuestLoggedIn
                ? Dimensions.paddingSizeLarge
                : 0),

        ///delivery section
        Obx((){
          final shippingCharge = Get.find<ShippingController>().minimumShippingCharge.value;
          return  DeliverySection(
            checkoutController: widget.checkoutController,
            address: widget.address,
            addressList: widget.addressList,
            guestNameTextEditingController: widget.guestNameTextEditingController,
            guestNumberTextEditingController:
            widget.guestNumberTextEditingController,
            guestNumberNode: widget.guestNumberNode,
            guestEmailController: widget.guestEmailController,
            guestEmailNode: widget.guestEmailNode,
            onShippingChargeChanged:
            shippingController.setMinimumShippingCharge, // Pass the callback
          );
        }),


        SizedBox(
            height: !takeAway
                ? isDesktop
                    ? Dimensions.paddingSizeLarge
                    : Dimensions.paddingSizeSmall
                : 0),

        ///delivery instruction
        !takeAway
            ? isDesktop
                ? const WebDeliveryInstructionView()
                : const DeliveryInstructionView()
            : const SizedBox(),

        SizedBox(height: !takeAway ? Dimensions.paddingSizeSmall : 0),

        /// Time Slot
        TimeSlotSection(
          storeId: widget.storeId,
          checkoutController: widget.checkoutController,
          cartList: widget.cartList,
          tooltipController2: widget.tooltipController2,
          tomorrowClosed: widget.tomorrowClosed,
          todayClosed: widget.todayClosed,
          module: widget.module,
        ),

        /// Coupon..
        !isDesktop && !isGuestLoggedIn
            ? CouponSection(
                storeId: widget.storeId,
                checkoutController: widget.checkoutController,
                total: widget.total,
                price: widget.price,
                discount: widget.discount,
                addOns: widget.addOns,
                deliveryCharge: widget.deliveryCharge,
              )
            : const SizedBox(),

        ///DmTips..
        DeliveryManTipsSection(
          takeAway: takeAway,
          tooltipController3: widget.dmTipsTooltipController,
          totalPrice: widget.total,
          onTotalChange: (double price) => widget.total + price,
          storeId: widget.storeId,
        ),

        ///Payment..
        Container(
          decoration: isDesktop
              ? const BoxDecoration()
              : BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        blurRadius: 10)
                  ],
                ),
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeLarge,
              horizontal: Dimensions.paddingSizeLarge),
          child: Column(children: [
            PaymentSection(
              storeId: widget.storeId,
              isCashOnDeliveryActive: widget.isCashOnDeliveryActive,
              isDigitalPaymentActive: widget.isDigitalPaymentActive,
              isWalletActive: widget.isWalletActive,
              total: widget.total,
              checkoutController: widget.checkoutController,
              isOfflinePaymentActive: widget.isOfflinePaymentActive,
            ),
            SizedBox(height: isGuestLoggedIn ? 0 : Dimensions.paddingSizeLarge),
            !isDesktop && !isGuestLoggedIn
                ? PartialPayView(
                    totalPrice: widget.total,
                    isPrescription: widget.storeId != null)
                : const SizedBox(),
          ]),
        ),
        SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),
      ]),
    );
  }
}
