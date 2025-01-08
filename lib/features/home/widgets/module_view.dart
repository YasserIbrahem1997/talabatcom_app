import 'package:shimmer/shimmer.dart';
import 'package:talabatcom/common/widgets/custom_ink_well.dart';
import 'package:talabatcom/features/banner/controllers/banner_controller.dart';
import 'package:talabatcom/features/home/widgets/views/new_on_mart_view.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/helper/responsive_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/styles.dart';
import 'package:talabatcom/common/widgets/custom_image.dart';
import 'package:talabatcom/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talabatcom/features/home/widgets/banner_view.dart';
import 'package:talabatcom/features/home/widgets/popular_store_view.dart';

class ModuleView extends StatelessWidget {
  final SplashController splashController;

  const ModuleView({super.key, required this.splashController});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      GetBuilder<BannerController>(builder: (bannerController) {
        return const BannerView(isFeatured: true);
      }),
      Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: TitleWidget(title: 'Discover_your_orders_now'.tr),
      ),
      splashController.moduleList != null
          ? splashController.moduleList!.isNotEmpty
              ? SizedBox(
                  width: double.infinity,
                  height: 330,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Only one item per row
                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                      crossAxisSpacing: Dimensions.paddingSizeExtraOverLarge,
                      childAspectRatio: 1.38, // Ensures the item is a square
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemCount: splashController.moduleList!.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    // Makes the GridView scroll horizontally
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 2 -
                            (2 * Dimensions.paddingSizeSmall),
                        // Adjust width to ensure two squares fit in the screen width
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: CustomInkWell(
                          onTap: () =>
                              splashController.switchModule(index, true),
                          radius: Dimensions.radiusDefault,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  child: CustomImage(
                                    image:
                                    '${splashController.configModel!.baseUrls!.moduleImageUrl}/${splashController.moduleList![index].icon}',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    splashController
                                        .moduleList![index].moduleName!,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Padding(
                  padding:
                      const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: Text('no_module_found'.tr),
                ))
          : ModuleShimmer(isEnabled: splashController.moduleList == null),
      const SizedBox(
        height: 10,
      ),
      const PopularStoreView(isPopular: false, isFeatured: true),
      const NewOnMartView(
        isPharmacy: false,
        isShop: false,
        isNewStore: true,
      ),
      const SizedBox(height: 120),
    ]);
  }
}

class ModuleShimmer extends StatelessWidget {
  final bool isEnabled;

  const ModuleShimmer({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        childAspectRatio: (1 / 1),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[Get.isDarkMode ? 700 : 200]!,
                  spreadRadius: 1,
                  blurRadius: 5)
            ],
          ),
          child: Shimmer.fromColors(
            highlightColor: Colors.white.withAlpha(1),
            baseColor: Colors.grey.withOpacity(0.5),
            period: const Duration(seconds: 2),
            enabled: isEnabled,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Colors.grey[300]),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Center(
                  child: Container(
                      height: 15, width: 50, color: Colors.grey[300])),
            ]),
          ),
        );
      },
    );
  }
}

class AddressShimmer extends StatelessWidget {
  final bool isEnabled;

  const AddressShimmer({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall),
          child: TitleWidget(title: 'deliver_to'.tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        SizedBox(
          height: 70,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                padding:
                    const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context)
                      ? Dimensions.paddingSizeDefault
                      : Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                          blurRadius: 5,
                          spreadRadius: 1)
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.location_on,
                      size: ResponsiveHelper.isDesktop(context) ? 50 : 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Shimmer.fromColors(
                        highlightColor: Colors.white.withAlpha(1),
                        baseColor: Colors.grey.withOpacity(0.5),
                        period: const Duration(seconds: 2),
                        enabled: isEnabled,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  height: 15,
                                  width: 100,
                                  color: Colors.grey[300]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              Container(
                                  height: 10,
                                  width: 150,
                                  color: Colors.grey[300]),
                            ]),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


class ModuleViewTow extends StatefulWidget {
  final SplashController splashController;


  const ModuleViewTow({super.key, required this.splashController});

  @override
  State<ModuleViewTow> createState() => _ModuleViewTowState();
}

class _ModuleViewTowState extends State<ModuleViewTow> {
  int? selectedIndex;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          widget.splashController.moduleList != null
              ? widget.splashController.moduleList!.isNotEmpty
              ? SizedBox(
            width: double.infinity,
            height: 70,
            child: ListView.separated(
              // gridDelegate:
              // const SliverGridDelegateWithFixedCrossAxisCount(
              //   crossAxisCount: 2, // Only one item per row
              //   mainAxisSpacing: Dimensions.paddingSizeSmall,
              //   crossAxisSpacing: Dimensions.paddingSizeExtraOverLarge,
              //   childAspectRatio: 1.28, // Ensures the item is a square
              // ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              itemCount: widget.splashController.moduleList!.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              // Makes the GridView scroll horizontally
              itemBuilder: (context, index) {
                bool isSelected = selectedIndex == index;

                return  CustomInkWell(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    widget.splashController.switchModule(index, true);
                  },

                  radius: Dimensions.radiusDefault,
                  child: Container(
                    width: 115,
                    // Adjust width to ensure two squares fit in the screen width
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(Dimensions.radiusDefault),
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                      border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 0.15),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ClipRRect(

                            borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall),
                            child: CustomImage(
                              image:
                              '${widget.splashController.configModel!.baseUrls!.moduleImageUrl}/${widget.splashController.moduleList![index].icon}',
                              fit: BoxFit.cover,
                              height:
                              MediaQuery.of(context).size.height /24,
                              width:
                              MediaQuery.of(context).size.height / 24,
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              widget.splashController
                                  .moduleList![index].moduleName!,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoMedium.copyWith(
                                  color: isSelected ?Colors.white:Colors.black,
                                  fontSize: Dimensions.fontSizeExtraSmall),
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeSmall),
                      ],
                    ),
                  ),
                );
              }, separatorBuilder: (BuildContext context, int index)  => SizedBox(
              width: 15,
            ),
            ),
          )
              : Center(
              child: Padding(
                padding:
                const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                child: Text('no_module_found'.tr),
              ))
              : ModuleShimmer(isEnabled: widget.splashController.moduleList == null),
        ]);
  }
}