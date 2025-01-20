import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talabatcom/util/dimensions.dart';
import 'package:talabatcom/util/styles.dart';

class PortionWidget extends StatelessWidget {
  final String icon;
  final String title;
  final bool hideDivider;
  final String route;
  final String? suffix;

  const PortionWidget(
      {super.key,
      required this.icon,
      required this.title,
      required this.route,
      this.hideDivider = false,
      this.suffix});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Column(children: [
          Row(children: [
            Image.asset(icon, height: 30, width: 30),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
                child: Text(title,
                    style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault))),
            suffix != null
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall,
                        horizontal: Dimensions.paddingSizeSmall),
                    child: Text(suffix!,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.white),
                       ),
                  )
                : const SizedBox(),
          ]),
          hideDivider ? const SizedBox() : const Divider()
        ]),
      ),
    );
  }
}
