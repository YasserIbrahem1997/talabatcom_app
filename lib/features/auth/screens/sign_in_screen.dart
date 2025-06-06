import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:talabatcom/features/cart/controllers/cart_controller.dart';
import 'package:talabatcom/features/language/controllers/language_controller.dart';
import 'package:talabatcom/features/location/controllers/location_controller.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/features/auth/controllers/auth_controller.dart';
import 'package:talabatcom/features/auth/screens/sign_up_screen.dart';
import 'package:talabatcom/features/auth/widgets/condition_check_box_widget.dart';
import 'package:talabatcom/features/auth/widgets/guest_button_widget.dart';
import 'package:talabatcom/features/auth/widgets/social_login_widget.dart';
import 'package:talabatcom/features/taxi_booking/booking_checkout_screen/widgets/custom_text.dart';
import 'package:talabatcom/helper/custom_validator.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/helper/route_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/images.dart';
import 'package:talabatcom/util/styles.dart';
import 'package:talabatcom/common/widgets/custom_button.dart';
import 'package:talabatcom/common/widgets/custom_snackbar.dart';
import 'package:talabatcom/common/widgets/custom_text_field.dart';
import 'package:talabatcom/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;

  const SignInScreen(
      {super.key, required this.exitFromApp, required this.backFromThis});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _countryDialCode;
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();

    _countryDialCode =
        Get.find<AuthController>().getUserCountryCode().isNotEmpty
            ? Get.find<AuthController>().getUserCountryCode()
            : CountryCode.fromCountryCode(
                    Get.find<SplashController>().configModel!.country!)
                .dialCode;
    _phoneController.text = Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (value) async {
        if (widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr,
                  style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: ResponsiveHelper.isDesktop(context)
            ? Colors.transparent
            : Theme.of(context).cardColor,
        appBar: (ResponsiveHelper.isDesktop(context)
            ? null
            : !widget.exitFromApp
                ? AppBar(
                    leading: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back_ios_rounded,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    actions: const [SizedBox()],
                  )
                : null),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: SafeArea(
            child: Center(
          child: Container(
            height: ResponsiveHelper.isDesktop(context) ? 690 : null,
            width: context.width > 700 ? 500 : context.width,
            padding: context.width > 700
                ? const EdgeInsets.symmetric(horizontal: 0)
                : const EdgeInsets.all(Dimensions.paddingSizeExtremeLarge),
            decoration: context.width > 700
                ? BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: ResponsiveHelper.isDesktop(context)
                        ? null
                        : [
                            BoxShadow(
                                color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                blurRadius: 5,
                                spreadRadius: 1)
                          ],
                  )
                : null,
            child: GetBuilder<AuthController>(builder: (authController) {
              return Center(
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      ResponsiveHelper.isDesktop(context)
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => Get.back(),
                                  icon: const Icon(Icons.clear),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      Padding(
                        padding: ResponsiveHelper.isDesktop(context)
                            ? const EdgeInsets.all(40)
                            : EdgeInsets.zero,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(Images.logo, width: 125),
                              // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                              // Center(child: Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge),

                              Align(
                                alignment:
                                    Get.find<LocalizationController>().isLtr
                                        ? Alignment.topLeft
                                        : Alignment.topRight,
                                child: Text('sign_in'.tr,
                                    style: robotoBold.copyWith(
                                        fontSize:
                                            Dimensions.fontSizeExtraLarge)),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),

                              CustomTextField(
                                titleText: ResponsiveHelper.isDesktop(context)
                                    ? 'phone'.tr
                                    : 'enter_phone_number'.tr,
                                hintText: '',
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                nextFocus: _passwordFocus,
                                inputType: TextInputType.phone,
                                isPhone: true,
                                showTitle: ResponsiveHelper.isDesktop(context),
                                onCountryChanged: (CountryCode countryCode) {
                                  _countryDialCode = countryCode.dialCode;
                                },
                                countryDialCode: _countryDialCode ??
                                    Get.find<LocalizationController>()
                                        .locale
                                        .countryCode,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge),

                              CustomTextField(
                                titleText: ResponsiveHelper.isDesktop(context)
                                    ? 'password'.tr
                                    : 'enter_your_password'.tr,
                                hintText: 'enter_your_password'.tr,
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                inputAction: TextInputAction.done,
                                inputType: TextInputType.visiblePassword,
                                prefixIcon: Icons.lock,
                                isPassword: true,
                                showTitle: ResponsiveHelper.isDesktop(context),
                                onSubmit: (text) => (GetPlatform.isWeb)
                                    ? _login(authController, _countryDialCode!)
                                    : null,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),

                              Row(children: [
                                Expanded(
                                  child: ListTile(
                                    onTap: () =>
                                        authController.toggleRememberMe(),
                                    leading: Checkbox(
                                      visualDensity: const VisualDensity(
                                          horizontal: -4, vertical: -4),
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      value: authController.isActiveRememberMe,
                                      onChanged: (bool? isChecked) =>
                                          authController.toggleRememberMe(),
                                    ),
                                    title: Text('remember_me'.tr),
                                    contentPadding: EdgeInsets.zero,
                                    visualDensity: const VisualDensity(
                                        horizontal: 0, vertical: -4),
                                    dense: true,
                                    horizontalTitleGap: 0,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Get.toNamed(
                                      RouteHelper.getForgotPassRoute(
                                          false, null)),
                                  child: Text('${'forgot_password'.tr}?',
                                      style: robotoRegular.copyWith(
                                          color:
                                              Theme.of(context).primaryColor)),
                                ),
                              ]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),

                              const Align(
                                alignment: Alignment.center,
                                child: ConditionCheckBoxWidget(
                                    forDeliveryMan: false),
                              ),

                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),

                              CustomButton(
                                height: ResponsiveHelper.isDesktop(context)
                                    ? 45
                                    : null,
                                width: ResponsiveHelper.isDesktop(context)
                                    ? 180
                                    : null,
                                buttonText: ResponsiveHelper.isDesktop(context)
                                    ? 'login'.tr
                                    : 'sign_in'.tr,
                                onPressed: () =>
                                    _login(authController, _countryDialCode!),
                                isLoading: authController.isLoading,
                                radius: ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.radiusSmall
                                    : Dimensions.radiusDefault,
                                isBold: !ResponsiveHelper.isDesktop(context),
                                fontSize: ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.fontSizeExtraSmall
                                    : null,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge),

                              ResponsiveHelper.isDesktop(context)
                                  ? const SizedBox()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          Text('do_not_have_account'.tr,
                                              style: robotoRegular.copyWith(
                                                  color: Theme.of(context)
                                                      .hintColor)),
                                          InkWell(
                                            onTap: () {
                                              if (ResponsiveHelper.isDesktop(
                                                  context)) {
                                                Get.back();
                                                Get.dialog(
                                                    const SignUpScreen());
                                              } else {
                                                Get.toNamed(RouteHelper
                                                    .getSignUpRoute());
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  Dimensions
                                                      .paddingSizeExtraSmall),
                                              child: Text('sign_up'.tr,
                                                  style: robotoMedium.copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColor)),
                                            ),
                                          ),
                                        ]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              Divider(),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              const SocialLoginWidget(),

                              ResponsiveHelper.isDesktop(context)
                                  ? const SizedBox()
                                  : const GuestButtonWidget(),

                              ResponsiveHelper.isDesktop(context)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          Text('do_not_have_account'.tr,
                                              style: robotoRegular.copyWith(
                                                  color: Theme.of(context)
                                                      .hintColor)),
                                          InkWell(
                                            onTap: () {
                                              if (ResponsiveHelper.isDesktop(
                                                  context)) {
                                                Get.back();
                                                Get.dialog(
                                                    const SignUpScreen());
                                              } else {
                                                Get.toNamed(RouteHelper
                                                    .getSignUpRoute());
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  Dimensions
                                                      .paddingSizeExtraSmall),
                                              child: Text('sign_up'.tr,
                                                  style: robotoMedium.copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColor)),
                                            ),
                                          ),
                                        ])
                                  : const SizedBox(),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              Divider(),
                              SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),
                              Container(
                                width: double.infinity,
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(0.15),
                                    border: Border.all(
                                        width: 0.5, color: Colors.black12),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 15.0),
                                          child: Text(
                                            "في حالة مواجهة صعوبه في \n التسجيل قم بالتواصل معانا من خلال ",
                                          style: TextStyle(
                                            fontSize: 13
                                          ),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                _launchURL(
                                                    "https://wa.me/+201070812048");
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: Dimensions
                                                            .paddingSizeSmall),
                                                child: Image.asset(
                                                  Images.whatsappNew,
                                                  width: 25,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: Dimensions
                                                  .paddingSizeDefault,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                _launchURL("tel://01070812048");
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color:
                                                        Colors.green.shade400,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                width: 25,
                                                height: 25,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Image.asset(
                                                  Images.call,
                                                  height: 50,
                                                  width: 50,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ]),
                      )
                    ],
                  ),
                ),
              );
            }),
          ),
        )),
      ),
    );
  }

  void _login(AuthController authController, String countryDialCode) async {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String numberWithCountryCode = countryDialCode + phone;
    PhoneValid phoneValid =
        await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    } else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    } else {
      authController
          .login(numberWithCountryCode, password)
          .then((status) async {
        if (status.isSuccess) {
          Get.find<CartController>().getCartDataOnline();
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPasswordSharedPref(
                phone, password, countryDialCode);
          } else {
            authController.clearUserNumberAndPassword();
          }
          String token = status.message!.substring(1, status.message!.length);
          if (Get.find<SplashController>().configModel!.customerVerification! &&
              int.parse(status.message![0]) == 0) {
            List<int> encoded = utf8.encode(password);
            String data = base64Encode(encoded);
            Get.toNamed(RouteHelper.getVerificationRoute(
                numberWithCountryCode, token, RouteHelper.signUp, data));
          } else {
            if (widget.backFromThis) {
              if (ResponsiveHelper.isDesktop(context)) {
                Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
              } else {
                Get.back();
              }
            } else {
              Get.find<LocationController>()
                  .navigateToLocationScreen('sign-in', offNamed: true);
            }
          }
        } else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
