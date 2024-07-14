import 'package:get/get.dart';
import 'package:talabatcom/features/onboard/domain/repository/onboard_repository_interface.dart';
import 'package:talabatcom/features/onboard/domain/service/onboard_service_interface.dart';

class OnboardService implements OnboardServiceInterface {
  final OnboardRepositoryInterface onboardRepositoryInterface;
  OnboardService({required this.onboardRepositoryInterface});

  @override
  Future<Response> getOnBoardingList() async {
    return await onboardRepositoryInterface.getList();
  }

}