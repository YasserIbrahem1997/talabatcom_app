import 'package:image_picker/image_picker.dart';
import 'package:talabatcom/features/auth/domain/models/store_body_model.dart';
import 'package:talabatcom/interfaces/repository_interface.dart';

abstract class StoreRegistrationRepositoryInterface extends RepositoryInterface{
  Future<bool> registerStore(StoreBodyModel store, XFile? logo, XFile? cover);
}