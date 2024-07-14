import 'package:talabatcom/interfaces/repository_interface.dart';
import 'package:talabatcom/util/html_type.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(HtmlType htmlType);
}