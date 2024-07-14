import 'package:talabatcom/features/home/domain/models/cashback_model.dart';
import 'package:talabatcom/interfaces/repository_interface.dart';

abstract class HomeRepositoryInterface<T> implements RepositoryInterface {
  Future<CashBackModel?> getCashBackData(double amount);
}