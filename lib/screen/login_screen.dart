import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_contact_list_app/config/app_constraints.dart';
import 'package:simple_contact_list_app/config/assets.dart';
import 'package:simple_contact_list_app/network/client/auth_client.dart';
import 'package:simple_contact_list_app/persistence/app_persistence.dart';
import 'package:simple_contact_list_app/screen/contact_list_screen.dart';
import 'package:simple_contact_list_app/screen/create_account_screen.dart';
import 'package:simple_contact_list_app/style/app_style.dart';
import 'package:simple_contact_list_app/widget/set_server_ip_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthClient _authClient = Get.put(AuthClient());
  final TextEditingController _emailController = Get.put(TextEditingController(), tag: "emailController")..text = "user@gmail.com";
  final TextEditingController _passController = Get.put(TextEditingController(), tag: "passController")..text = "123456";
  bool _networking = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(seconds: 2)).then((value) async {
        AppPersistence appPersistence = AppPersistence();
        String? serverIP = await appPersistence.getServerIP();
        if (serverIP == null && mounted) _setServerIP();
      });
    });
    super.initState();
  }

  void _setServerIP() {
    showDialog<String>(context: context, builder: (context) => const SetServerIPDialog()).then((value) async {
      if (value?.isNotEmpty ?? false) {
        var persistence = AppPersistence();
        persistence.setServerIP(value!);
      }
    });
  }

  void _navigateToCreateAccountScreen() {
    Get.to(const CreateAccountScreen())?.then((result) {
      if (result == true) _login();
    });
  }

  bool _validateLoginForm() {
    String email = _emailController.text;
    String pass = _passController.text;

    String? formError;
    if (email.isEmpty) {
      formError = "enter_email".tr;
    } else if (pass.isEmpty) {
      formError = "enter_password".tr;
    } else if (pass.length < 6) {
      formError = "password_min_lenght_6".tr;
    }

    if (formError != null) {
      Get.snackbar("Oops...", formError, snackStyle: SnackStyle.FLOATING, overlayBlur: snackbarOverlayBlur);
    }

    return formError == null;
  }

  void _login() {
    if (_networking || !_validateLoginForm()) return;
    setState(() => _networking = true);
    _authClient.auth(email: _emailController.text, pass: _passController.text).then((response) {
      if (!mounted) return;
      Get.offAll(() => const ContactListScreen());
    }).catchError((e) {
      if (!mounted) return;
      String message = "error_unknow".tr;
      if (e is DioError) {
        DioError error = e;
        switch (error.type) {
          case DioErrorType.connectTimeout:
          case DioErrorType.sendTimeout:
          case DioErrorType.other:
          case DioErrorType.receiveTimeout:
            message = "error_conexao".tr;
            break;
          case DioErrorType.response:
            message = "access_denied".tr;
            break;
          case DioErrorType.cancel:
            break;
        }
      } else {
        message = "unkow_error".tr;
      }
      Get.snackbar("Oops...", message, overlayBlur: snackbarOverlayBlur);
    }).whenComplete(() {
      if (!mounted) return;
      setState(() => _networking = false);
    });
  }

  @override
  Widget build(context) => Scaffold(
        body: Container(
          decoration: gradientBox,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverSafeArea(
                sliver: SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 2),
                        FractionallySizedBox(
                          widthFactor: 0.4,
                          child: Image.asset(Assets.imageNotebook, fit: BoxFit.fitWidth),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Simple Contact List",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                        const Spacer(flex: 1),
                        TextField(
                          controller: _emailController,
                          enabled: !_networking,
                          minLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(hintText: "enter_email".tr),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passController,
                          enabled: !_networking,
                          minLines: 1,
                          obscureText: true,
                          textInputAction: TextInputAction.go,
                          decoration: InputDecoration(hintText: "enter_password".tr),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(onPressed: _networking ? null : _login, child: Text("login".tr)),
                        SizedBox(
                          height: 2,
                          child: Visibility(
                            visible: _networking,
                            child: const LinearProgressIndicator(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(onPressed: _networking ? null : _navigateToCreateAccountScreen, child: Text("create_account".tr)),
                        const SizedBox(height: 16),
                        TextButton(onPressed: _networking ? null : _setServerIP, child: Text("set_server_ip".tr)),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
