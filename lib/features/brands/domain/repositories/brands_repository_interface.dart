import 'package:talabatcom/features/item/domain/models/item_model.dart';
import 'package:talabatcom/interfaces/repository_interface.dart';

abstract class BrandsRepositoryInterface extends RepositoryInterface {
  Future<ItemModel?> getBrandItemList({required int brandId, int? offset});
}