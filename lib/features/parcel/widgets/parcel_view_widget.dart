import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:talabatcom/common/widgets/address_widget.dart';
import 'package:talabatcom/features/location/controllers/location_controller.dart';
import 'package:talabatcom/features/address/controllers/address_controller.dart';
import 'package:talabatcom/features/address/domain/models/address_model.dart';
import 'package:talabatcom/features/location/domain/models/zone_response_model.dart';
import 'package:talabatcom/features/parcel/controllers/parcel_controller.dart';
import 'package:talabatcom/helper/address_helper.dart';
import 'package:talabatcom/helper/auth_helper.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/helper/route_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/styles.dart';
import 'package:talabatcom/common/widgets/custom_dropdown.dart';
import 'package:talabatcom/common/widgets/custom_text_field.dart';
import 'package:talabatcom/common/widgets/footer_view.dart';
import 'package:talabatcom/features/location/screens/pick_map_screen.dart';
import 'package:http/http.dart' as http;

import '../../checkout/domain/repositories/checkout_repository.dart';

class ParcelViewWidget extends StatefulWidget {
  final bool isSender;

  final Widget bottomButton;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final String? countryCode;

   ParcelViewWidget(
      {super.key,
      required this.isSender,
      required this.nameController,
      required this.phoneController,
      required this.streetController,
      required this.houseController,
      required this.floorController,
      required this.bottomButton,
      required this.countryCode,
      });

  @override
  State<ParcelViewWidget> createState() => _ParcelViewWidgetState();
}

class _ParcelViewWidgetState extends State<ParcelViewWidget> {
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();
  final FocusNode nameNode = FocusNode();
  final FocusNode phoneNode = FocusNode();
  String? _countryCode;
  String? _addressCountryCode;
  String? selectedCity; // Default selected city
  final shippingController = Get.put(ShippingController());

  // Define the list of areas fetched from API
  List<dynamic> areas = [];
  double? minimumShippingCharge;
  final ParcelControllerNew parcelControllerNew =
      Get.put(ParcelControllerNew());
  // Function to fetch the data from the API
  Future<void> fetchAreas() async {
    var zone_id = AddressHelper.getUserAddressFromSharedPref()!.zoneId;
    print("this zone " + zone_id.toString());
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
    _addressCountryCode = null;
    _countryCode = _addressCountryCode ?? widget.countryCode;
    fetchAreas(); // Fetch areas when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    _countryCode = _addressCountryCode ?? widget.countryCode;
    String? countryDialCode;

    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: GetBuilder<AddressController>(builder: (addressController) {
        return GetBuilder<ParcelController>(builder: (parcelController) {
          List<DropdownItem<int>> senderAddressList = _getDropdownAddressList(
              context: context,
              addressList: addressController.addressList,
              isSender: true,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);
          List<DropdownItem<int>> receiverAddressList = _getDropdownAddressList(
              context: context,
              addressList: addressController.addressList,
              isSender: false,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);
          List<AddressModel> senderAddress = _getAddressList(
              addressList: addressController.addressList,
              isSender: true,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);
          List<AddressModel> receiverAddress = _getAddressList(
              addressList: addressController.addressList,
              isSender: false,
              pickupAddress: parcelController.pickupAddress,
              destinationAddress: parcelController.destinationAddress);

          return SingleChildScrollView(
            controller: ScrollController(),
            child: Center(
                child: FooterView(
              child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Container(
                        decoration:
                            BoxDecoration(color: Theme.of(context).cardColor),
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(children: [
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    widget.isSender
                                        ? 'pickup_location'.tr
                                        : 'delivery_location'.tr,
                                    style: robotoMedium),

                              ]),
                          SizedBox(
                            height: 20,
                          ),

                          SizedBox(
                            height: 20,
                          ),

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
                                  "Select_country".tr,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                items: areas.isNotEmpty
                                    ? areas.map((area) {
                                        return DropdownMenuItem<String>(
                                          value: area['name'],
                                          child: Text(
                                            area['name'],
                                            style:
                                                TextStyle(color: Colors.black),
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
                                    var minimumCharge = areas.firstWhere(
                                            (area) => area['name'] == newValue)[
                                        'minimum_shipping_charge'];
                                    minimumShippingCharge = minimumCharge is int
                                        ? minimumCharge.toDouble()
                                        : minimumCharge;
                                    shippingController.setMinimumShippingCharge(
                                        minimumShippingCharge!);

                                    shippingController.setMinimumShippingCharge(
                                        minimumShippingCharge!);

                                    AddressHelper.saveArea(
                                        "Area", newValue.toString());
                                    // Print minimumShippingCharge to the terminal
                                    print(
                                        'Selected City: $newValue, Minimum Shipping Charge: $minimumShippingCharge');
                                    var get = AddressHelper.getArea("Area");
                                    print(
                                        'Selected City: $get, Minimum Shipping Charge: $minimumShippingCharge');
                                    parcelControllerNew
                                        .updateLocation(newValue!);
                                    widget.isSender
                                        ? parcelControllerNew.updateSenderPrice(
                                            minimumShippingCharge.toString())
                                        : parcelControllerNew
                                            .updateReceiverPrice(
                                                minimumShippingCharge
                                                    .toString());
                                  });
                                },
                                icon: Icon(
                                  Icons.arrow_drop_down, // Default down arrow
                                  color: Colors.black,
                                ),
                                iconSize: 24,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                                dropdownColor: Colors.white,
                                // Inner dropdown color
                                borderRadius: BorderRadius.circular(
                                    10), // Border radius for dropdown
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          !isDesktop
                              ? CustomTextField(
                                  hintText: ' ',
                                  titleText: 'street_number'.tr,
                                  inputType: TextInputType.streetAddress,
                                  focusNode: streetNode,
                                  nextFocus: houseNode,
                                  controller: widget.streetController,
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
                                      focusNode: streetNode,
                                      nextFocus: houseNode,
                                      controller: widget.streetController,
                                    ),
                                  )
                                : const SizedBox(),
                            SizedBox(
                                width: isDesktop
                                    ? Dimensions.paddingSizeSmall
                                    : 0),

                            Expanded(
                              child: CustomTextField(
                                showTitle: isDesktop,
                                hintText: ' ',
                                titleText: 'house'.tr,
                                inputType: TextInputType.text,
                                focusNode: houseNode,
                                nextFocus: floorNode,
                                controller: widget.houseController,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: CustomTextField(
                                showTitle: isDesktop,
                                hintText: ' ',
                                titleText: 'floor'.tr,
                                inputType: TextInputType.text,
                                focusNode: floorNode,
                                nextFocus: nameNode,
                                controller: widget.floorController,
                              ),
                            ),
                            //const SizedBox(height: Dimensions.paddingSizeLarge),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Row(
                            children: [
                              // زر اختيار اليوم
                              InkWell(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    parcelController.setSelectedDate(pickedDate);
                                  }
                                },
                                child: Container(

                                  width: 175,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(
                                          width: 0.5, color: Colors.black12)),
                                  child: Center(
                                    child: Obx(() =>  Text(
                                      parcelController.selectedDate.value== null
                                          ? 'اختر اليوم'
                                          : '${DateFormat('EEEE').format(parcelController.selectedDate.value!)}',
                                    )),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              // زر اختيار اليوم
                              InkWell(
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    parcelController.setSelectedTime(
                                        pickedTime);
                                  }
                                },
                                child: Container(
                                  width: 175,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(
                                          width: 0.5,
                                          color: Colors.black12)),
                                  child: Center(
                                    child: Obx(() =>
                                        Text(
                                          parcelController.selectedTime
                                              .value == null
                                              ? 'اختر الساعة'
                                              : 'الساعة: ${parcelController
                                              .selectedTime.value!
                                              .hour}:${parcelController
                                              .selectedTime.value!.minute}',
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                        ),
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),

                              Text(
                                  parcelController.isSender
                                      ? 'sender_information'.tr
                                      : 'receiver_information'.tr,
                                  style: robotoMedium),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),

                              CustomTextField(
                                showTitle: isDesktop,
                                hintText: ' ',
                                titleText: parcelController.isSender
                                    ? 'sender_name'.tr
                                    : 'receiver_name'.tr,
                                inputType: TextInputType.name,
                                focusNode: nameNode,
                                nextFocus: phoneNode,
                                controller: widget.nameController,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),


                              CustomTextField(
                                titleText: parcelController.isSender
                                    ? 'sender_phone_number'.tr
                                    : 'receiver_phone_number'.tr,
                                hintText: ' ',
                                controller: widget.phoneController,
                                focusNode: phoneNode,
                                inputType: TextInputType.phone,
                                inputAction: TextInputAction.done,
                                isPhone: true,
                                showTitle: ResponsiveHelper.isDesktop(context),
                                onCountryChanged: (CountryCode countryCode) {
                                  countryDialCode = countryCode.dialCode;
                                  parcelController.setCountryCode(
                                      countryDialCode!,
                                      parcelController.isSender);
                                },
                                countryDialCode:
                                    countryDialCode ?? _countryCode,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                            ]),
                      ),
                      ResponsiveHelper.isDesktop(context)
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: Dimensions.fontSizeSmall),
                              child: widget.bottomButton,
                            )
                          : const SizedBox(),
                    ]),
                  )),
            )),
          );
        });
      }),
    );
  }

  List<DropdownItem<int>> _getDropdownAddressList(
      {required BuildContext context,
      required List<AddressModel>? addressList,
      required bool isSender,
      required AddressModel? pickupAddress,
      required AddressModel? destinationAddress}) {
    List<DropdownItem<int>> dropDownAddressList = [];

    if (isSender) {
      dropDownAddressList.add(DropdownItem<int>(
          value: 0,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth - 50
                : context.width - 50,
            child: AddressWidget(
              address: pickupAddress,
              fromAddress: false,
              fromCheckout: true,
            ),
          )));
    } else {
      dropDownAddressList.add(DropdownItem<int>(
          value: 0,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth - 50
                : context.width - 50,
            child: AddressWidget(
              address: destinationAddress ??
                  AddressHelper.getUserAddressFromSharedPref(),
              fromAddress: false,
              fromCheckout: true,
            ),
          )));
    }

    if (addressList != null && AuthHelper.isLoggedIn()) {
      for (int index = 0; index < addressList.length; index++) {
        dropDownAddressList.add(DropdownItem<int>(
            value: index + 1,
            child: SizedBox(
              width: context.width > Dimensions.webMaxWidth
                  ? Dimensions.webMaxWidth - 50
                  : context.width - 50,
              child: AddressWidget(
                address: addressList[index],
                fromAddress: false,
                fromCheckout: true,
              ),
            )));
      }
    }
    return dropDownAddressList;
  }

  List<AddressModel> _getAddressList(
      {required List<AddressModel>? addressList,
      required bool isSender,
      required AddressModel? pickupAddress,
      required AddressModel? destinationAddress}) {
    List<AddressModel> address = [];

    if (isSender) {
      address.add(pickupAddress!);
    } else if (!isSender) {
      address.add(
          destinationAddress ?? AddressHelper.getUserAddressFromSharedPref()!);
    }

    if (addressList != null && AuthHelper.isLoggedIn()) {
      for (int index = 0; index < addressList.length; index++) {
        address.add(addressList[index]);
      }
    }
    return address;
  }

  Future<void> _splitPhoneNumber(String number) async {
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      _addressCountryCode = '+${phoneNumber.countryCode}';
      widget.phoneController.text =
          phoneNumber.international.substring(_addressCountryCode!.length);
    } catch (e) {
      debugPrint('number can\'t parse : $e');
    }
  }
}
