import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talabatcom/features/item/controllers/campaign_controller.dart';
import 'package:talabatcom/features/splash/controllers/splash_controller.dart';
import 'package:talabatcom/helper/route_helper.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/common/widgets/custom_image.dart';

class MiddleSectionMultipleBannerViewWidget extends StatelessWidget {
  const MiddleSectionMultipleBannerViewWidget ({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CampaignController>(builder: (campaignController) {

      return campaignController.basicCampaignList != null ? campaignController.basicCampaignList!.isNotEmpty ? Container(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtremeLarge, bottom: Dimensions.paddingSizeDefault),
        child: GridView.builder(
          itemCount: campaignController.basicCampaignList!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: Dimensions.paddingSizeExtremeLarge,
            mainAxisSpacing: Dimensions.paddingSizeExtremeLarge,
            mainAxisExtent: 230,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              hoverColor: Colors.transparent,
              onTap: () => Get.toNamed(RouteHelper.getBasicCampaignRoute(
                campaignController.basicCampaignList![index],
              )),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                  color: Theme.of(context).cardColor,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                  child: CustomImage(
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl}'
                        '/${campaignController.basicCampaignList![index].image}',
                    fit: BoxFit.cover, height: 230, width: double.infinity,
                  ),
                ),
              ),
            );
          },
        ),
      ) : const SizedBox() : const MiddleSectionMultipleBannerShimmer();
    });
  }
}

class MiddleSectionMultipleBannerShimmer extends StatelessWidget {
  const MiddleSectionMultipleBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: Dimensions.paddingSizeExtremeLarge,
        mainAxisSpacing: Dimensions.paddingSizeExtremeLarge,
        mainAxisExtent: 230,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          enabled: true,
          highlightColor: Colors.white.withAlpha(1),
          baseColor: Colors.grey.withOpacity(0.5),
          period: const Duration(seconds: 2),
          child: Container(
            height: 230, width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              color: Colors.grey[300],
            ),
          ),
        );
      },
    );
  }
}
