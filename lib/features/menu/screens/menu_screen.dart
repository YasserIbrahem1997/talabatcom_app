import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talabatcom/features/home/controllers/home_controller.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/features/profile/controllers/profile_controller.dart';
import 'package:talabatcom/features/favourite/controllers/favourite_controller.dart';
import 'package:talabatcom/features/auth/controllers/auth_controller.dart';
import 'package:talabatcom/features/auth/screens/sign_in_screen.dart';
import 'package:talabatcom/helper/auth_helper.dart';
import 'package:talabatcom/helper/date_converter.dart';
import 'package:talabatcom/helper/price_converter.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/helper/route_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/images.dart';
import 'package:talabatcom/util/styles.dart';
import 'package:talabatcom/common/widgets/confirmation_dialog.dart';
import 'package:talabatcom/common/widgets/custom_image.dart';
import 'package:talabatcom/features/menu/widgets/portion_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final bool isLoggedIn = AuthHelper.isLoggedIn();

        return Column(children: [
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeExtremeLarge,
                right: Dimensions.paddingSizeExtremeLarge,
                top: 50,
                bottom: Dimensions.paddingSizeExtremeLarge,
              ),
              child: Row(children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(1),
                  child: ClipOval(
                      child: CustomImage(
                    placeholder: Images.guestIconLight,
                    image:
                        '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                        '/${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.image : ''}',
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  )),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn
                              ? '${profileController.userInfoModel?.fName} ${profileController.userInfoModel?.lName}'
                              : 'guest_user'.tr,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: Theme.of(context).cardColor),
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        isLoggedIn
                            ? Text(
                                profileController.userInfoModel != null
                                    ? DateConverter.containTAndZToUTCFormat(
                                        profileController
                                            .userInfoModel!.createdAt!)
                                    : '',
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).cardColor),
                              )
                            : InkWell(
                                onTap: () async {
                                  if (!ResponsiveHelper.isDesktop(context)) {
                                    await Get.toNamed(
                                        RouteHelper.getSignInRoute(
                                            Get.currentRoute));
                                  } else {
                                    Get.dialog(const SignInScreen(
                                        exitFromApp: true, backFromThis: true));
                                  }
                                },
                                child: Text(
                                  'login_to_view_all_feature'.tr,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).cardColor),
                                ),
                              ),
                      ]),
                ),
              ]),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Ink(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              child: Column(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault),
                    child: Text(
                      'general'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      PortionWidget(
                          icon: Images.userNew,
                          title: 'profile'.tr,
                          route: RouteHelper.getProfileRoute()),
                      PortionWidget(
                          icon: Images.mapAddress,
                          title: 'my_address'.tr,
                          route: RouteHelper.getAddressRoute()),
                      PortionWidget(
                          icon: Images.translate,
                          title: 'language'.tr,
                          hideDivider: true,
                          route: RouteHelper.getLanguageRoute('menu')),
                      Divider(),
                      PortionWidget(
                          icon: Images.favouriteUnselect,
                          title: 'favorite'.tr,
                          hideDivider: true,
                          route: RouteHelper.getFavouriteScreen()),
                    ]),
                  )
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault),
                    child: Text(
                      'promotional_activity'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      PortionWidget(
                        icon: Images.couponNewIcon,
                        title: 'coupon'.tr,
                        route: RouteHelper.getCouponRoute(),
                        hideDivider: Get.find<SplashController>()
                                        .configModel!
                                        .loyaltyPointStatus ==
                                    1 ||
                                Get.find<SplashController>()
                                        .configModel!
                                        .customerWalletStatus ==
                                    1
                            ? false
                            : true,
                      ),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .loyaltyPointStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.pointIcon,
                              title: 'loyalty_points'.tr,
                              route: RouteHelper.getLoyaltyRoute(),
                              hideDivider: Get.find<SplashController>()
                                          .configModel!
                                          .customerWalletStatus ==
                                      1
                                  ? false
                                  : true,
                              suffix: !isLoggedIn
                                  ? null
                                  : '${profileController.userInfoModel?.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}',
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .customerWalletStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.moneyPoint,
                              title: 'my_wallet'.tr,
                              hideDivider: true,
                              route: RouteHelper.getWalletRoute(),
                              suffix: !isLoggedIn
                                  ? null
                                  : PriceConverter.convertPrice(
                                      profileController.userInfoModel != null
                                          ? profileController
                                              .userInfoModel!.walletBalance
                                          : 0),
                            )
                          : const SizedBox(),
                    ]),
                  )
                ]),
                (Get.find<SplashController>().configModel!.refEarningStatus ==
                            1) ||
                        (Get.find<SplashController>()
                                .configModel!
                                .toggleDmRegistration! &&
                            !ResponsiveHelper.isDesktop(context)) ||
                        (Get.find<SplashController>()
                                .configModel!
                                .toggleStoreRegistration! &&
                            !ResponsiveHelper.isDesktop(context))
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: Dimensions.paddingSizeDefault,
                                  right: Dimensions.paddingSizeDefault),
                              child: Text(
                                'earnings'.tr,
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5)),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors
                                          .grey[Get.isDarkMode ? 800 : 200]!,
                                      spreadRadius: 1,
                                      blurRadius: 5)
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeLarge,
                                  vertical: Dimensions.paddingSizeDefault),
                              margin: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault),
                              child: Column(children: [
                                (Get.find<SplashController>()
                                            .configModel!
                                            .refEarningStatus ==
                                        1)
                                    ? PortionWidget(
                                        icon: Images.referIconeNew,
                                        title: 'refer_and_earn'.tr,
                                        route:
                                            RouteHelper.getReferAndEarnRoute(),
                                        hideDivider: (Get.find<
                                                            SplashController>()
                                                        .configModel!
                                                        .toggleDmRegistration! &&
                                                    !ResponsiveHelper.isDesktop(
                                                        context)) ||
                                                (Get.find<SplashController>()
                                                        .configModel!
                                                        .toggleStoreRegistration! &&
                                                    !ResponsiveHelper.isDesktop(
                                                        context))
                                            ? false
                                            : true,
                                      )
                                    : const SizedBox(),
                                (Get.find<SplashController>()
                                            .configModel!
                                            .toggleDmRegistration! &&
                                        !ResponsiveHelper.isDesktop(context))
                                    ? PortionWidget(
                                        icon: Images.joinTeam,
                                        title: 'join_as_a_delivery_man'.tr,
                                        route: RouteHelper
                                            .getDeliverymanRegistrationRoute(),
                                        hideDivider: (Get.find<
                                                        SplashController>()
                                                    .configModel!
                                                    .toggleStoreRegistration! &&
                                                !ResponsiveHelper.isDesktop(
                                                    context))
                                            ? false
                                            : true,
                                      )
                                    : const SizedBox(),
                                (Get.find<SplashController>()
                                            .configModel!
                                            .toggleStoreRegistration! &&
                                        !ResponsiveHelper.isDesktop(context))
                                    ? PortionWidget(
                                        icon: Images.storeIconNew,
                                        title: 'open_store'.tr,
                                        hideDivider: true,
                                        route: RouteHelper
                                            .getRestaurantRegistrationRoute(),
                                      )
                                    : const SizedBox(),
                              ]),
                            )
                          ])
                    : const SizedBox(),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault),
                    child: Text(
                      'help_and_support'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      PortionWidget(
                          icon: Images.chatNew,
                          title: 'live_chat'.tr,
                          route: RouteHelper.getConversationRoute()),
                      PortionWidget(
                          icon: Images.helpIconNew,
                          title: 'help_and_support'.tr,
                          route: RouteHelper.getSupportRoute()),
                      PortionWidget(
                          icon: Images.aboutIconNew,
                          title: 'about_us'.tr,
                          route: RouteHelper.getHtmlRoute('about-us')),
                      PortionWidget(
                          icon: Images.termsIconNew,
                          title: 'terms_conditions'.tr,
                          route:
                              RouteHelper.getHtmlRoute('terms-and-condition')),
                      PortionWidget(
                          icon: Images.privacyIconNew,
                          title: 'privacy_policy'.tr,
                          route: RouteHelper.getHtmlRoute('privacy-policy')),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .refundPolicyStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.refundIconNew,
                              title: 'refund_policy'.tr,
                              route: RouteHelper.getHtmlRoute('refund-policy'),
                              hideDivider: (Get.find<SplashController>()
                                              .configModel!
                                              .cancellationPolicyStatus ==
                                          1) ||
                                      (Get.find<SplashController>()
                                              .configModel!
                                              .shippingPolicyStatus ==
                                          1)
                                  ? false
                                  : true,
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .cancellationPolicyStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.cancelationIcon,
                              title: 'cancellation_policy'.tr,
                              route: RouteHelper.getHtmlRoute(
                                  'cancellation-policy'),
                              hideDivider: (Get.find<SplashController>()
                                          .configModel!
                                          .shippingPolicyStatus ==
                                      1)
                                  ? false
                                  : true,
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .shippingPolicyStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.shippingIcon,
                              title: 'shipping_policy'.tr,
                              hideDivider: true,
                              route:
                                  RouteHelper.getHtmlRoute('shipping-policy'),
                            )
                          : const SizedBox(),
                    ]),
                  )
                ]),
                const SizedBox(height: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault),
                    child: Text(
                      'connect_us'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      InkWell(
                        onTap: () {
                          _launchURL(
                              "https://www.facebook.com/talabatcomghareb?mibextid=ZbWKwL");
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall),
                          child: Column(children: [
                            Row(children: [
                              Image.asset(Images.facebookNew,
                                  height: 30, width: 30),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              Expanded(
                                  child: Text('facebook'.tr,
                                      style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeDefault))),
                            ]),
                          ]),
                        ),
                      ),
                      const Divider(),
                      InkWell(
                        onTap: () {
                          _launchURL("https://wa.me/+201070812048");
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall),
                          child: Column(children: [
                            Row(children: [
                              Image.asset(Images.whatsappNew,
                                  height: 30, width: 30),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              Expanded(
                                  child: Text('whats_app'.tr,
                                      style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeDefault))),
                            ]),
                          ]),
                        ),
                      ),
                    ]),
                  )
                ]),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    if (AuthHelper.isLoggedIn()) {
                      Get.dialog(
                          ConfirmationDialog(
                              icon: Images.support,
                              description: 'are_you_sure_to_logout'.tr,
                              isLogOut: true,
                              onYesPressed: () {
                                Get.find<ProfileController>().clearUserInfo();
                                Get.find<AuthController>().clearSharedData();
                                Get.find<AuthController>().socialLogout();
                                Get.find<FavouriteController>()
                                    .removeFavourite();
                                Get.find<HomeController>()
                                    .forcefullyNullCashBackOffers();
                                if (ResponsiveHelper.isDesktop(context)) {
                                  Get.offAllNamed(
                                      RouteHelper.getInitialRoute());
                                } else {
                                  Get.offAllNamed(RouteHelper.getSignInRoute(
                                      RouteHelper.splash));
                                }
                              }),
                          useSafeArea: false);
                    } else {
                      Get.find<FavouriteController>().removeFavourite();
                      await Get.toNamed(
                          RouteHelper.getSignInRoute(Get.currentRoute));
                      if (AuthHelper.isLoggedIn()) {
                        profileController.getUserInfo();
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeSmall),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            child: Icon(Icons.power_settings_new_sharp,
                                size: 18, color: Theme.of(context).cardColor),
                          ),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          Text(
                              AuthHelper.isLoggedIn()
                                  ? 'logout'.tr
                                  : 'sign_in'.tr,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge))
                        ]),
                  ),
                ),
                SizedBox(
                    height: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeExtremeLarge
                        : 100),
              ]),
            ),
          )),
        ]);
      }),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
