import 'package:talabatcom/features/home/domain/models/cashback_model.dart';

abstract class HomeServiceInterface {
  Future<List<CashBackModel>> getCashBackOfferList();
  Future<CashBackModel?> getCashBackData(double amount);
}