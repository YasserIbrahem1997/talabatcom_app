import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:talabatcom/common/widgets/address_widget.dart';
import 'package:talabatcom/features/address/domain/models/address_model.dart';
import 'package:talabatcom/features/checkout/controllers/checkout_controller.dart';
import 'package:talabatcom/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:talabatcom/helper/auth_helper.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/helper/route_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/styles.dart';
import 'package:talabatcom/common/widgets/custom_dropdown.dart';
import 'package:talabatcom/common/widgets/custom_text_field.dart';
import 'package:talabatcom/features/checkout/widgets/guest_delivery_address.dart';

import '../../../helper/address_helper.dart';
import 'package:http/http.dart' as http;

class DeliverySection extends StatefulWidget {
  final CheckoutController checkoutController;
  final List<AddressModel> address;
  final List<DropdownItem<int>> addressList;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final Function(double) onShippingChargeChanged; // Callback to pass the charge to TopSection


  const DeliverySection({
    super.key,
    required this.checkoutController,
    required this.address,
    required this.addressList,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestNumberNode,
    required this.guestEmailController,
    required this.guestEmailNode,
    required this.onShippingChargeChanged, // Callback parameter

  });

  @override
  State<DeliverySection> createState() => _DeliverySectionState();
}

class _DeliverySectionState extends State<DeliverySection> {
  final shippingController = Get.put(ShippingController());

  String? selectedCity; // Default selected city
  // Define the list of areas fetched from API
  List<dynamic> areas = [];
  double? minimumShippingCharge;

  // Function to fetch the data from the API
  Future<void> fetchAreas() async {
    var zone_id = AddressHelper.getUserAddressFromSharedPref()!.zoneId;
    final response = await http.get(
      Uri.parse(
          'https://talabatcom.net/newupdate/api/v1/vehicle/extra_charge?distance=0&zone_id=$zone_id'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        areas = data['areas'];
      });
    } else {
      // Handle the error
      throw Exception('Failed to load areas');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAreas(); // Fetch areas when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    bool takeAway = (widget.checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Column(children: [
      isGuestLoggedIn
          ? GuestDeliveryAddress(
              checkoutController: widget.checkoutController,
              guestNumberNode: widget.guestNumberNode,
              guestNameTextEditingController:
                  widget.guestNameTextEditingController,
              guestNumberTextEditingController:
                  widget.guestNumberTextEditingController,
              guestEmailController: widget.guestEmailController,
              guestEmailNode: widget.guestEmailNode,
            )
          : !takeAway
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.05),
                          blurRadius: 10)
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('deliver_to'.tr, style: robotoMedium),
                              TextButton.icon(
                                onPressed: () async {
                                  var address = await Get.toNamed(
                                      RouteHelper.getAddAddressRoute(
                                          true,
                                          false,
                                          widget.checkoutController.store!
                                              .zoneId));
                                  if (address != null) {
                                    widget.checkoutController.getDistanceInKM(
                                      LatLng(double.parse(address.latitude),
                                          double.parse(address.longitude)),
                                      LatLng(
                                          double.parse(widget.checkoutController
                                              .store!.latitude!),
                                          double.parse(widget.checkoutController
                                              .store!.longitude!)),
                                    );
                                    widget
                                        .checkoutController
                                        .streetNumberController
                                        .text = address.streetNumber ?? '';
                                    widget.checkoutController.houseController
                                        .text = address.house ?? '';
                                    widget.checkoutController.floorController
                                        .text = address.floor ?? '';
                                  }
                                },
                                icon: const Icon(Icons.add, size: 20),
                                label: Text('add_new'.tr,
                                    style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall)),
                              ),
                            ]),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedCity,
                              hint: Text(
                                "اختر المدينة",
                                style: TextStyle(color: Colors.grey),
                              ),
                              items: areas.isNotEmpty
                                  ? areas.map((area) {
                                      return DropdownMenuItem<String>(
                                        value: area['name'],
                                        child: Text(
                                          area['name'],
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      );
                                    }).toList()
                                  : [
                                      DropdownMenuItem<String>(
                                        value: 'no_areas',
                                        child: Text(
                                          "There_are_no_areas_now".tr,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCity = newValue;

                                  // Safely casting to double
                                  var minimumCharge = areas.firstWhere((area) =>
                                      area['name'] ==
                                      newValue)['minimum_shipping_charge'];
                                  minimumShippingCharge = minimumCharge is int
                                      ? minimumCharge.toDouble()
                                      : minimumCharge;
                                  shippingController.setMinimumShippingCharge(
                                      minimumShippingCharge!);

                                  shippingController.setMinimumShippingCharge(minimumShippingCharge!);

                                  // Call the callback to update minimumShippingCharge in TopSection
                                  widget.onShippingChargeChanged(minimumShippingCharge!);
                                  AddressHelper.saveArea("Area", newValue.toString());
                                  // Print minimumShippingCharge to the terminal
                                  print('Selected City: $newValue, Minimum Shipping Charge: $minimumShippingCharge');
                                  var get = AddressHelper.getArea("Area");
                                  print('Selected City: $get, Minimum Shipping Charge: $minimumShippingCharge');
                                });
                              },
                              icon: Icon(
                                Icons.arrow_drop_down, // Default down arrow
                                color: Colors.black,
                              ),
                              iconSize: 24,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              dropdownColor: Colors.white,
                              // Inner dropdown color
                              borderRadius: BorderRadius.circular(
                                  10), // Border radius for dropdown
                            ),
                          ),
                        ),
                        // isDesktop ?  Stack(children: [
                        //   Container(
                        //     constraints: const BoxConstraints(minHeight:  90),
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        //       color: Theme.of(context).primaryColor.withOpacity(0.1),
                        //     ),
                        //     child: Container(
                        //       height: 45,
                        //       padding: const EdgeInsets.symmetric(
                        //         vertical: Dimensions.paddingSizeExtraSmall,
                        //         horizontal: Dimensions.paddingSizeExtraSmall,
                        //       ),
                        //       child: AddressWidget(
                        //         address: address[checkoutController.addressIndex!],
                        //         fromAddress: false, fromCheckout: true,
                        //       ),
                        //     ),
                        //   ),
                        //
                        //   Positioned.fill(
                        //     child: Align(
                        //       alignment: Alignment.centerRight,
                        //       child: PopupMenuButton(
                        //           position: PopupMenuPosition.under,
                        //           icon: const Icon(Icons.keyboard_arrow_down),
                        //           onSelected: (value) {},
                        //           itemBuilder: (context)  => List.generate(
                        //               address.length, (index) => PopupMenuItem(
                        //             child: InkWell(
                        //               onTap: () {
                        //                 checkoutController.getDistanceInKM(
                        //                   LatLng(
                        //                     double.parse(address[index].latitude!),
                        //                     double.parse(address[index].longitude!),
                        //                   ),
                        //                   LatLng(double.parse(checkoutController.store!.latitude!), double.parse(checkoutController.store!.longitude!)),
                        //                 );
                        //                 checkoutController.setAddressIndex(index);
                        //                 checkoutController.streetNumberController.text = address[checkoutController.addressIndex!].streetNumber ?? '';
                        //                 checkoutController.houseController.text = address[checkoutController.addressIndex!].house ?? '';
                        //                 checkoutController.floorController.text = address[checkoutController.addressIndex!].floor ?? '';
                        //                 Navigator.pop(context);
                        //               },
                        //               child: Row(
                        //                   crossAxisAlignment: CrossAxisAlignment.start,
                        //                   children: [
                        //                     Container(
                        //                       height: 20, width: 20,
                        //                       padding: const EdgeInsets.all(3),
                        //                       decoration: BoxDecoration(
                        //                         shape: BoxShape.circle,
                        //                         border: Border.all(color: checkoutController.addressIndex == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                        //                       ),
                        //                       child: checkoutController.addressIndex == index ? Container(
                        //                         height: 15, width: 15,
                        //                         decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                        //                       ) : const SizedBox(),
                        //                     ),
                        //
                        //                     const SizedBox(width: Dimensions.paddingSizeSmall),
                        //                     Expanded(
                        //                       child: Column(
                        //                         crossAxisAlignment: CrossAxisAlignment.start,
                        //                         children: [
                        //                           Text(address[index].addressType!.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        //                           const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        //
                        //                           Text(
                        //                             address[index].address!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        //                             style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                   ]
                        //               ),
                        //             ),
                        //           )
                        //           )
                        //       ),
                        //     ),
                        //   ),
                        // ]) : Container(
                        //   constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? 90 : 75),
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        //     color: Theme.of(context).primaryColor.withOpacity(0.1),
                        //   ),
                        //   child: CustomDropdown<int>(
                        //
                        //     onChange: (int? value, int index) {
                        //       checkoutController.getDistanceInKM(
                        //         LatLng(
                        //           double.parse(address[index].latitude!),
                        //           double.parse(address[index].longitude!),
                        //         ),
                        //         LatLng(double.parse(checkoutController.store!.latitude!), double.parse(checkoutController.store!.longitude!)),
                        //       );
                        //       checkoutController.setAddressIndex(index);
                        //
                        //       checkoutController.streetNumberController.text = address[checkoutController.addressIndex!].streetNumber ?? '';
                        //       checkoutController.houseController.text = address[checkoutController.addressIndex!].house ?? '';
                        //       checkoutController.floorController.text = address[checkoutController.addressIndex!].floor ?? '';
                        //
                        //     },
                        //     dropdownButtonStyle: DropdownButtonStyle(
                        //       height: 45,
                        //       padding: const EdgeInsets.symmetric(
                        //         vertical: Dimensions.paddingSizeExtraSmall,
                        //         horizontal: Dimensions.paddingSizeExtraSmall,
                        //       ),
                        //       primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
                        //     ),
                        //     dropdownStyle: DropdownStyle(
                        //       elevation: 10,
                        //       borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        //       padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        //     ),
                        //     items: addressList,
                        //     child: AddressWidget(
                        //       address: address[checkoutController.addressIndex!],
                        //       fromAddress: false, fromCheckout: true,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        !isDesktop
                            ? CustomTextField(
                                hintText: ' ',
                                titleText: 'street_number'.tr,
                                inputType: TextInputType.streetAddress,
                                focusNode: widget.checkoutController.streetNode,
                                nextFocus: widget.checkoutController.houseNode,
                                controller: widget
                                    .checkoutController.streetNumberController,
                              )
                            : const SizedBox(),
                        SizedBox(
                            height:
                                !isDesktop ? Dimensions.paddingSizeLarge : 0),

                        Row(children: [
                          isDesktop
                              ? Expanded(
                                  child: CustomTextField(
                                    showTitle: true,
                                    hintText: ' ',
                                    titleText: 'street_number'.tr,
                                    inputType: TextInputType.streetAddress,
                                    focusNode:
                                        widget.checkoutController.streetNode,
                                    nextFocus:
                                        widget.checkoutController.houseNode,
                                    controller: widget.checkoutController
                                        .streetNumberController,
                                  ),
                                )
                              : const SizedBox(),
                          SizedBox(
                              width:
                                  isDesktop ? Dimensions.paddingSizeSmall : 0),

                          Expanded(
                            child: CustomTextField(
                              showTitle: isDesktop,
                              hintText: ' ',
                              titleText: 'house'.tr,
                              inputType: TextInputType.text,
                              focusNode: widget.checkoutController.houseNode,
                              nextFocus: widget.checkoutController.floorNode,
                              controller:
                                  widget.checkoutController.houseController,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(
                            child: CustomTextField(
                              showTitle: isDesktop,
                              hintText: ' ',
                              titleText: 'floor'.tr,
                              inputType: TextInputType.text,
                              focusNode: widget.checkoutController.floorNode,
                              inputAction: TextInputAction.done,
                              controller:
                                  widget.checkoutController.floorController,
                            ),
                          ),
                          //const SizedBox(height: Dimensions.paddingSizeLarge),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ]),
                )
              : const SizedBox(),
    ]);
  }
}
