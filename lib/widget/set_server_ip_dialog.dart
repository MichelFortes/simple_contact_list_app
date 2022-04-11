import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_contact_list_app/persistence/app_persistence.dart';

class SetServerIPDialog extends StatefulWidget {
  const SetServerIPDialog({Key? key}) : super(key: key);

  @override
  State<SetServerIPDialog> createState() => _SetServerIPDialogState();
}

class _SetServerIPDialogState extends State<SetServerIPDialog> {
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      var serverIP = await AppPersistence().getServerIP();
      if(serverIP != null) _ipController.text = serverIP;
    });
    super.initState();
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("set_server_ip".tr, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline2),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
              decoration: InputDecoration(hintText: "enter_server_ip".tr),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () => Get.back<String>(result: _ipController.text), child: Text("ok".tr)),
          ],
        ),
      ),
    );
  }
}
