import 'package:flutter/material.dart';
import 'package:simple_contact_list_app/style/app_style.dart';

class FullLoadingWidget extends StatelessWidget {
  const FullLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gradientBox,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 1),
      ),
    );
  }
}
