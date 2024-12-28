import 'package:get/get.dart';
import 'package:get/get_connect/connect.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talabatcom/api/api_client.dart';
import 'package:talabatcom/features/payment/domain/models/offline_method_model.dart';
import 'package:talabatcom/features/checkout/domain/models/place_order_body_model.dart';
import 'package:talabatcom/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:talabatcom/util/app_constants.dart';

import '../../../location/domain/models/zone_response_model.dart';
import '../../../location/domain/repositories/location_repository.dart';

class CheckoutRepository implements CheckoutRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  final LocationRepository? locationRepository;

  CheckoutRepository(
      {required this.apiClient,
      required this.sharedPreferences,
      this.locationRepository});

  @override
  Future<int> getDmTipMostTapped() async {
    int mostDmTipAmount = 0;
    Response response = await apiClient.getData(AppConstants.mostTipsUri);
    if (response.statusCode == 200) {
      mostDmTipAmount = response.body['most_tips_amount'];
    }
    return mostDmTipAmount;
  }

  @override
  Future<bool> saveSharedPrefDmTipIndex(String index) async {
    return await sharedPreferences.setString(AppConstants.dmTipIndex, index);
  }

  @override
  String getSharedPrefDmTipIndex() {
    return sharedPreferences.getString(AppConstants.dmTipIndex) ?? "";
  }

  @override
  Future<Response> getDistanceInMeter(
      LatLng originLatLng, LatLng destinationLatLng) async {
    return await apiClient.getData(
      '${AppConstants.distanceMatrixUri}?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
      '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}&mode=walking',
      handleError: false,
    );
  }

  @override
  Future<double> getExtraCharge(double? distance) async {
    double extraCharge = 0.0;
    print("Fetching extra charge in checkout repository");
    // Ensure locationRepository is initialized
    if (locationRepository == null) {
      print("locationRepository is null");
      return 0.0; // Return default if locationRepository is not available
    }
    // Example of calling getZone
    ZoneResponseModel zoneResponse =
        await locationRepository!.getZone('lat', 'lng');
    List<int>? zoneIds = zoneResponse.zoneIds;

    // Use zoneIds as needed in your logic
    if (zoneIds != null && zoneIds.isNotEmpty) {
      // Example logic based on zoneIds
      print('Zone IDs: $zoneIds');
    }

    // Fetch vehicle charge based on distance
    Response response = await apiClient.getData(
        '${AppConstants.vehicleChargeUri}?distance=$distance',
        handleError: false);

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');

      // Ensure response.body is convertible to double
      try {
        extraCharge = double.parse(response.body.toString());
      } catch (e) {
        print("Error parsing extra charge: $e");
        extraCharge = 0.0; // Fallback to 0 if parsing fails
      }
    } else {
      print('Error fetching data: ${response.statusCode}');
    }

    return extraCharge;
  }

  @override
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody,
      List<MultipartBody>? orderAttachment) async {
    return await apiClient.postMultipartData(
        AppConstants.placeOrderUri, orderBody.toJson(), orderAttachment ?? [],
        handleError: false);
  }

  @override
  Future<Response> placePrescriptionOrder(
    int? storeId,
    double? distance,
    String address,
    String longitude,
    String latitude,
    String note,
    List<MultipartBody> orderAttachment,
    String dmTips,
    String deliveryInstruction,
    String area,
  ) async {
    Map<String, String> body = {
      'store_id': storeId.toString(),
      'distance': distance.toString(),
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'order_note': note,
      'dm_tips': dmTips,
      'delivery_instruction': deliveryInstruction,
      'area': area,
    };
    return await apiClient.postMultipartData(
        AppConstants.placePrescriptionOrderUri, body, orderAttachment,
        handleError: false);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) async {
    return await _getOfflineMethodList();
  }

  Future<List<OfflineMethodModel>?> _getOfflineMethodList() async {
    List<OfflineMethodModel>? offlineMethodList;
    Response response =
        await apiClient.getData(AppConstants.offlineMethodListUri);
    if (response.statusCode == 200) {
      offlineMethodList = [];
      response.body.forEach((method) =>
          offlineMethodList!.add(OfflineMethodModel.fromJson(method)));
    }
    return offlineMethodList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}

class ShippingController extends GetxController {
  var minimumShippingCharge = 0.0.obs;

  void setMinimumShippingCharge(double value) {
    minimumShippingCharge.value = value;
  }
}
