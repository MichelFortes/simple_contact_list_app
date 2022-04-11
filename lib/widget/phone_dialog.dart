import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneDialog extends StatefulWidget {
  final String? phone;

  const PhoneDialog({Key? key, this.phone}) : super(key: key);

  @override
  State<PhoneDialog> createState() => _PhoneDialogState();
}

class _PhoneDialogState extends State<PhoneDialog> {
  final TextEditingController _controller = Get.put(TextEditingController());
  final FocusNode _focus = Get.put(FocusNode());

  void _onDone() {
    Get.back(result: _controller.text);
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("phone".tr),
      contentPadding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _controller..text = widget.phone ?? "",
          focusNode: _focus,
          keyboardType: TextInputType.phone,
          autofocus: true,
          decoration: InputDecoration(hintText: "enter_phone".tr),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _onDone, child: Text("ok".tr)),
      ],
    );
  }
}
