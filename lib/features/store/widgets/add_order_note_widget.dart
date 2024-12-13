import 'package:flutter/material.dart';
import 'package:talabatcom/features/coupon/domain/models/coupon_model.dart';

class AddOrderNoteWidget extends StatelessWidget {
  Store store;
   AddOrderNoteWidget({super.key,required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(store.name.toString()),
      ),
    );
  }
}
