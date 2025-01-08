import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talabatcom/features/banner/controllers/banner_controller.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/common/widgets/custom_image.dart';

class PromotionalBannerView extends StatelessWidget {
  const PromotionalBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {
      return bannerController.promotionalBanner != null ? bannerController.promotionalBanner!.bottomSectionBanner != null ? Container(
        height: 90, width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          child: CustomImage(
            image: '${bannerController.promotionalBanner!.promotionalBannerUrl}/${bannerController.promotionalBanner!.bottomSectionBanner}',
            fit: BoxFit.cover, height: 80, width: double.infinity,
          ),
        ),
      ) : const SizedBox() : const PromotionalBannerShimmerView();
    });
  }
}

class PromotionalBannerShimmerView extends StatelessWidget {
  const PromotionalBannerShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      enabled: true,
      highlightColor: Colors.white.withAlpha(1),
      baseColor: Colors.grey.withOpacity(0.5),
      period: const Duration(seconds: 2),
      child: Container(
        height: 90, width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
      ),
    );
  }
}