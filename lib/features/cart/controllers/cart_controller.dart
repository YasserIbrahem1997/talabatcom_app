import 'package:get/get.dart';
import 'package:talabatcom/features/item/domain/models/item_model.dart';
import 'package:talabatcom/common/models/module_model.dart';
import 'package:talabatcom/features/cart/domain/models/cart_model.dart';
import 'package:talabatcom/features/cart/domain/models/online_cart_model.dart';
import 'package:talabatcom/features/cart/domain/services/cart_service_interface.dart';
import 'package:talabatcom/features/checkout/domain/models/place_order_body_model.dart';
import 'package:talabatcom/features/home/screens/home_screen.dart';
import 'package:talabatcom/features/item/controllers/item_controller.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/helper/auth_helper.dart';
import 'package:talabatcom/helper/date_converter.dart';
import 'package:talabatcom/helper/module_helper.dart';
import 'package:talabatcom/helper/price_converter.dart';

class CartController extends GetxController implements GetxService {
  final CartServiceInterface cartServiceInterface;

  CartController({required this.cartServiceInterface});

  List<CartModel> _cartList = [];
  List<CartModel> get cartList => _cartList;

  double _subTotal = 0;
  double get subTotal => _subTotal;

  double _itemPrice = 0;
  double get itemPrice => _itemPrice;

  double _itemDiscountPrice = 0;
  double get itemDiscountPrice => _itemDiscountPrice;

  double _addOns = 0;
  double get addOns => _addOns;

  double _variationPrice = 0;
  double get variationPrice => _variationPrice;

  List<List<AddOns>> _addOnsList = [];
  List<List<AddOns>> get addOnsList => _addOnsList;

  List<bool> _availableList = [];
  List<bool> get availableList => _availableList;

  List<String> notAvailableList = ['Remove_from_cart', 'I_will_wait_until_it_is_restocked', 'Contact_me_as_soon_as_possible', 'Let_me_know_when_he_returns'];
  bool _addCutlery = false;
  bool get addCutlery => _addCutlery;

  int _notAvailableIndex = -1;
  int get notAvailableIndex => _notAvailableIndex;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _needExtraPackage = true;
  bool get needExtraPackage => _needExtraPackage;

  void toggleExtraPackage({bool willUpdate = true}) {
    _needExtraPackage = !_needExtraPackage;
    if(willUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool willUpdate = true}) {
    _notAvailableIndex = cartServiceInterface.availableSelectedIndex(_notAvailableIndex, index);
    if(willUpdate) {
      update();
    }
  }

  void updateCutlery({bool willUpdate = true}){
    _addCutlery = !_addCutlery;
    if(willUpdate) {
      update();
    }
  }

  Future<void> forcefullySetModule(int moduleId) async {
    ModuleModel? module = cartServiceInterface.forcefullySetModule(Get.find<SplashController>().module, Get.find<SplashController>().moduleList, moduleId);
    if(module != null) {
      await Get.find<SplashController>().setModule(module);
      HomeScreen.loadData(true);
    }
  }

  double calculationCart() {
    _addOnsList = [];
    _availableList = [];
    _itemPrice = 0;
    _itemDiscountPrice = 0;
    _addOns = 0;
    _variationPrice = 0;
    bool isFoodVariation = false;
    double variationWithoutDiscountPrice = 0;
    bool haveVariation = false;
    for (var cartModel in cartList) {

      isFoodVariation = ModuleHelper.getModuleConfig(cartModel.item!.moduleType).newVariation!;
      double? discount = cartModel.item!.storeDiscount == 0 ? cartModel.item!.discount : cartModel.item!.storeDiscount;
      String? discountType = cartModel.item!.storeDiscount == 0 ? cartModel.item!.discountType : 'percent';

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      _addOnsList.add(addOnList);
      _availableList.add(DateConverter.isAvailable(cartModel.item!.availableTimeStarts, cartModel.item!.availableTimeEnds));

      _addOns = cartServiceInterface.calculateAddonPrice(_addOns, addOnList, cartModel);

      _variationPrice = cartServiceInterface.calculateVariationPrice(isFoodVariation, cartModel, discount, discountType, _variationPrice);

      variationWithoutDiscountPrice = cartServiceInterface.calculateVariationWithoutDiscountPrice(isFoodVariation, cartModel, variationWithoutDiscountPrice);
      haveVariation = cartServiceInterface.checkVariation(isFoodVariation, cartModel);

      double price = haveVariation ? variationWithoutDiscountPrice : (cartModel.item!.price! * cartModel.quantity!);
      double discountPrice = haveVariation ? (variationWithoutDiscountPrice - _variationPrice)
          : (price - (PriceConverter.convertWithDiscount(cartModel.item!.price!, discount, discountType)! * cartModel.quantity!));

      _itemPrice = _itemPrice + price;
      _itemDiscountPrice = _itemDiscountPrice + discountPrice;

      haveVariation = false;
    }
    if(isFoodVariation){
      _itemDiscountPrice = _itemDiscountPrice + (variationWithoutDiscountPrice - _variationPrice);
      _variationPrice =  variationWithoutDiscountPrice;
      _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns ;
    } else {
      _subTotal = (_itemPrice - _itemDiscountPrice);
    }

    return _subTotal;
  }
  double calculationCartNew() {
    _addOnsList = [];
    _availableList = [];
    _itemPrice = 0;
    _itemDiscountPrice = 0;
    _addOns = 0;
    _variationPrice = 0; // تعيين القيمة الافتراضية للفيريشن إلى صفر.
    bool isFoodVariation = false;
    double variationWithoutDiscountPrice = 0;
    bool haveVariation = false;

    for (int i = 0; i < cartList.length; i++) {
      var cartModel = cartList[i];
      isFoodVariation = ModuleHelper.getModuleConfig(cartModel.item!.moduleType)
          .newVariation!;

      double? discount = cartModel.item!.storeDiscount == 0
          ? cartModel.item!.discount
          : cartModel.item!.storeDiscount;
      String? discountType = cartModel.item!.storeDiscount == 0
          ? cartModel.item!.discountType
          : 'percent';

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      _addOnsList.add(addOnList);
      _availableList.add(DateConverter.isAvailable(
          cartModel.item!.availableTimeStarts,
          cartModel.item!.availableTimeEnds));

      _addOns = cartServiceInterface.calculateAddonPrice(
          _addOns, addOnList, cartModel);

      // هنا نقوم بالتحقق إذا كان هذا هو العنصر الأول
      if (i == 0) {
        // إذا كان الفيريشن الأول، اجعل قيمته صفرًا
        _variationPrice = 0;
      } else {
        // في الحالات الأخرى، قم بحساب الفيريشن
        _variationPrice = cartServiceInterface.calculateVariationPrice(
            isFoodVariation, cartModel, discount, discountType, _variationPrice);
      }

      variationWithoutDiscountPrice =
          cartServiceInterface.calculateVariationWithoutDiscountPrice(
              isFoodVariation, cartModel, variationWithoutDiscountPrice);
      haveVariation =
          cartServiceInterface.checkVariation(isFoodVariation, cartModel);

      double price = haveVariation
          ? variationWithoutDiscountPrice
          : (cartModel.item!.price! * cartModel.quantity!);
      double discountPrice = haveVariation
          ? (variationWithoutDiscountPrice - _variationPrice)
          : (price -
          (PriceConverter.convertWithDiscount(
              cartModel.item!.price!, discount, discountType)! *
              cartModel.quantity!));

      _itemPrice = _itemPrice + price;
      _itemDiscountPrice = _itemDiscountPrice + discountPrice;

      haveVariation = false;
    }

    if (isFoodVariation) {
      _itemDiscountPrice = _itemDiscountPrice +
          (variationWithoutDiscountPrice - _variationPrice);
      _variationPrice = variationWithoutDiscountPrice;
      _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns + _variationPrice;
    } else {
      _subTotal = (_itemPrice - _itemDiscountPrice);
    }

    return _subTotal;
  }


  Future<void> addToCart(CartModel cartModel, int? index) async {
    if(index != null && index != -1) {
      _cartList.replaceRange(index, index+1, [cartModel]);
    }else {
      _cartList.add(cartModel);
    }
    Get.find<ItemController>().setExistInCart(cartModel.item, notify: true);
    await cartServiceInterface.addSharedPrefCartList(_cartList);

    calculationCart();
    update();
  }

  int? getCartId(int cartIndex) {
    return cartServiceInterface.getCartId(cartIndex, _cartList);
  }

  Future<void> setQuantity(bool isIncrement, int cartIndex, int? stock, int ? quantityLimit) async {
    _isLoading = true;
    update();

    _cartList[cartIndex].quantity = cartServiceInterface.decideItemQuantity(isIncrement, _cartList, cartIndex, stock, quantityLimit, Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!);

    double discountedPrice = cartServiceInterface.calculateDiscountedPrice(_cartList[cartIndex], _cartList[cartIndex].quantity!, ModuleHelper.getModuleConfig(_cartList[cartIndex].item!.moduleType).newVariation!);
    if(ModuleHelper.getModuleConfig(_cartList[cartIndex].item!.moduleType).newVariation!) {
      Get.find<ItemController>().setExistInCart(_cartList[cartIndex].item, notify: true);
    }

    await updateCartQuantityOnline(_cartList[cartIndex].id!, discountedPrice, _cartList[cartIndex].quantity!);

  }

  Future<void> removeFromCart(int index, {Item? item}) async {
    int cartId = _cartList[index].id!;
    _cartList.removeAt(index);
    update();
    Get.find<ItemController>().cartIndexSet();
    await removeCartItemOnline(cartId, item: item);
    if(Get.find<ItemController>().item != null) {
      Get.find<ItemController>().cartIndexSet();
    }

  }

  void clearCartList() {
    _cartList = [];
    if((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) && (ModuleHelper.getModule() != null || ModuleHelper.getCacheModule() != null)) {
      clearCartOnline();
    }
  }

  int isExistInCart(int? itemID, String variationType, bool isUpdate, int? cartIndex) {
    return cartServiceInterface.isExistInCart(_cartList, itemID, variationType, isUpdate, cartIndex);
  }

  bool existAnotherStoreItem(int? storeID, int? moduleId) {
    return cartServiceInterface.existAnotherStoreItem(storeID, moduleId, _cartList);
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  Future<bool> addToCartOnline(OnlineCart cart) async {
    _isLoading = true;
    bool success = false;
    update();
    List<OnlineCartModel>? onlineCartList = await cartServiceInterface.addToCartOnline(cart);
    if(onlineCartList != null) {
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
      calculationCart();
      success = true;
    }
    _isLoading = false;
    update();

    return success;
  }

  Future<bool> updateCartOnline(OnlineCart cart) async {
    _isLoading = true;
    bool success = false;
    update();
    List<OnlineCartModel>? onlineCartList = await cartServiceInterface.updateCartOnline(cart);
    if(onlineCartList != null) {
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
      calculationCart();
      success = true;
    }
    _isLoading = false;
    update();

    return success;
  }

  Future<void> updateCartQuantityOnline(int cartId, double price, int quantity) async {
    _isLoading = true;
    update();
    bool success = await cartServiceInterface.updateCartQuantityOnline(cartId, price, quantity);
    if(success) {
      getCartDataOnline();
      calculationCart();
    }
    _isLoading = false;
    update();
  }

  Future<void> getCartDataOnline() async {
    if(ModuleHelper.getModule() != null || ModuleHelper.getCacheModule() != null) {
      _isLoading = true;
      List<OnlineCartModel>? onlineCartList = await cartServiceInterface.getCartDataOnline();
      if(onlineCartList != null) {
        _cartList = [];
        _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
        calculationCart();
      }
      _isLoading = false;
      update();
    }
  }

  Future<bool> removeCartItemOnline(int cartId, {Item? item}) async {
    _isLoading = true;
    update();
    bool success = await cartServiceInterface.removeCartItemOnline(cartId);
    if(success) {
      await getCartDataOnline();
      if(item != null) {
        Get.find<ItemController>().setExistInCart(item, notify: true);
      }
    }
    _isLoading = false;
    update();
    return success;
  }

  Future<bool> clearCartOnline() async {
    _isLoading = true;
    update();
    bool success = await cartServiceInterface.clearCartOnline();
    if(success) {
      getCartDataOnline();
    }
    _isLoading = false;
    update();
    return success;
  }

  int cartQuantity(int itemId) {
    return cartServiceInterface.cartQuantity(itemId, _cartList);
  }

  String cartVariant(int itemId) {
    return cartServiceInterface.cartVariant(itemId, _cartList);
  }


}