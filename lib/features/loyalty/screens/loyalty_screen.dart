import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talabatcom/features/loyalty/controllers/loyalty_controller.dart';
import 'package:talabatcom/features/loyalty/widgets/loyalty_bottom_sheet_widget.dart';
import 'package:talabatcom/features/loyalty/widgets/loyalty_card_widget.dart';
import 'package:talabatcom/features/loyalty/widgets/loyalty_history_widget.dart';
import 'package:talabatcom/features/profile/controllers/profile_controller.dart';
import 'package:talabatcom/helper/auth_helper.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/styles.dart';
import 'package:talabatcom/common/widgets/custom_app_bar.dart';
import 'package:talabatcom/common/widgets/footer_view.dart';
import 'package:talabatcom/common/widgets/menu_drawer.dart';
import 'package:talabatcom/common/widgets/not_logged_in_screen.dart';
import 'package:talabatcom/common/widgets/web_page_title_widget.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final ScrollController scrollController = ScrollController();
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    initCall();

  }

  void initCall(){
    if(AuthHelper.isLoggedIn()){

      Get.find<ProfileController>().getUserInfo();

      Get.find<LoyaltyController>().getLoyaltyTransactionList('1', false);

      Get.find<LoyaltyController>().setOffset(1);

      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent
            && Get.find<LoyaltyController>().transactionList != null
            && !Get.find<LoyaltyController>().isLoading) {
          int pageSize = (Get.find<LoyaltyController>().popularPageSize! / 10).ceil();
          if (Get.find<LoyaltyController>().offset < pageSize) {
            Get.find<LoyaltyController>().setOffset(Get.find<LoyaltyController>().offset + 1);
            if (kDebugMode) {
              print('end of the page');
            }
            Get.find<LoyaltyController>().showBottomLoader();
            Get.find<LoyaltyController>().getLoyaltyTransactionList(Get.find<LoyaltyController>().offset.toString(), false);
          }
        }
      });
    }
  }
  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(title: 'loyalty_points'.tr, backButton: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoggedIn && !ResponsiveHelper.isDesktop(context) ? FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: Text( 'convert_to_wallet_money'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault)),
        onPressed: (){
          Get.dialog(
            Dialog(backgroundColor: Colors.transparent, child: LoyaltyBottomSheetWidget(
                amount: Get.find<ProfileController>().userInfoModel!.loyaltyPoint == null ? '0' : Get.find<ProfileController>().userInfoModel!.loyaltyPoint.toString(),
            )),
          );
        },
      ) : null,
      body: GetBuilder<ProfileController>(
          builder: (profileController) {
            return isLoggedIn ? profileController.userInfoModel != null ? SafeArea(
              child: RefreshIndicator(
                onRefresh: () async{
                  Get.find<LoyaltyController>().getLoyaltyTransactionList('1', true);
                  Get.find<ProfileController>().getUserInfo();
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      WebScreenTitleWidget(title: 'loyalty_points'.tr),
                      FooterView(
                        child: SizedBox(width: Dimensions.webMaxWidth,
                          child: GetBuilder<LoyaltyController>(
                              builder: (loyaltyController) {
                                return ResponsiveHelper.isDesktop(context) ? Padding(
                                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Expanded (flex: 4 , child: Column(children: [
                                          Container(
                                            decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                              color: Theme.of(context).cardColor,
                                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                                            ) : null,
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                            child: LoyaltyCardWidget(tooltipController: tooltipController),
                                          ),
                                        ],
                                      )),
                                      const SizedBox(width: Dimensions.paddingSizeDefault),

                                      Expanded(flex: 6, child: Column(children: [
                                        Container(
                                          decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                                          ) : null,
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                          child: const LoyaltyHistoryWidget(),
                                        ),
                                      ])),
                                    ]),
                                )
                             : Column(children: [

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                  child: LoyaltyCardWidget(tooltipController: tooltipController),
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                  child: LoyaltyHistoryWidget(),
                                )

                              ]);
                            }
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ) : const Center(child: CircularProgressIndicator()) : NotLoggedInScreen(callBack: (value){
              initCall();
              setState(() {});
            });
          }
      ),
    );
  }
}

class WalletShimmer extends StatelessWidget {
  final LoyaltyController loyaltyController;
  const WalletShimmer({super.key, required this.loyaltyController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.1,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
      ),
      physics:  const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount: 10,
      padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Shimmer.fromColors(
            highlightColor: Colors.white.withAlpha(1),
            baseColor: Colors.grey.withOpacity(0.5),
            period: const Duration(seconds: 2),
            enabled: loyaltyController.transactionList == null,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                ],
              ),
              Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge), child: Divider(color: Theme.of(context).disabledColor)),
            ],
            ),
          ),
        );
      },
    );
  }
}