import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_contact_list_app/config/app_constraints.dart';
import 'package:simple_contact_list_app/model/user_form.dart';
import 'package:simple_contact_list_app/network/client/user_client.dart';
import 'package:simple_contact_list_app/style/app_style.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final UserClient _userClient = Get.put(UserClient());
  final TextEditingController _nameController = Get.put(TextEditingController(), tag: "createAccountnameController");
  final TextEditingController _emailController = Get.find<TextEditingController>(tag: "emailController");
  final TextEditingController _passController = Get.find<TextEditingController>(tag: "passController");
  final TextEditingController _passConfirmationController = Get.put(TextEditingController(), tag: "passConfirmationController");
  final FocusNode _nameFocus = Get.put(FocusNode(), tag: "nameFocusNode");
  final FocusNode _emailFocus = Get.put(FocusNode(), tag: "emailFocusNode");
  final FocusNode _passFocus = Get.put(FocusNode(), tag: "passFocusNode");
  final FocusNode _passConfirmationFocus = Get.put(FocusNode(), tag: "passConfirmationFocusNode");
  bool _networking = false;

  bool _validateForm() {

    String name = _nameController.text;
    String email = _emailController.text;
    String pass = _passController.text;
    String passConfirmation = _passConfirmationController.text;

    String? formError;
    if (name.isEmpty) {
      formError = "enter_name".tr;
      _nameFocus.requestFocus();
    } else if (name.length < userNameMinLenght) {
      formError = "error_name_min_lenght".tr;
      _nameFocus.requestFocus();
    } else if (email.isEmpty) {
      formError = "enter_email".tr;
      _emailFocus.requestFocus();
    } else if (pass.isEmpty) {
      formError = "enter_password".tr;
      _passFocus.requestFocus();
    } else if (passConfirmation.isEmpty) {
      formError = "confirm_password".tr;
      _passConfirmationFocus.requestFocus();
    } else if (pass != passConfirmation) {
      formError = "password_confirmation_failed".tr;
      _passConfirmationFocus.requestFocus();
    } else if (pass.length < 6) {
      formError = "password_min_lenght_6".tr;
      _passConfirmationFocus.requestFocus();
    }

    if (formError != null) {
      Get.snackbar("Oops...", formError, snackStyle: SnackStyle.FLOATING, overlayBlur: snackbarOverlayBlur);
    }
     return formError == null;
  }

  void _createAccount() {
    if (_networking || !_validateForm()) return;
    setState(() => _networking = true);
    _userClient.create(form: UserForm(name: _nameController.text, email: _emailController.text, password: _passController.text)).then((response) {
      if (!mounted) return;
      Get.back(result: true);
    }).catchError((e) {
      if (!mounted) return;
      String message = "error_unknow".tr;
      DioError error = e;
      switch (error.type) {
        case DioErrorType.connectTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.other:
        case DioErrorType.receiveTimeout:
          message = "error_conexao".tr;
          break;
        case DioErrorType.response:
          if (error.response?.data?.toString().contains("violation") ?? false) {
            message = "error_email_exists".tr;
          } else {
            message = "error_conexao".tr;
          }
          break;
        case DioErrorType.cancel:
          break;
      }
      Get.snackbar("Oops...", message, overlayBlur: snackbarOverlayBlur);
    }, test: (e) => e is DioError).catchError((e) {
      if (!mounted) return;
      Get.snackbar("Oops...", "error_unknow".tr, overlayBlur: snackbarOverlayBlur);
    }).whenComplete(() {
      if (!mounted) return;
      setState(() => _networking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: Container(
        decoration: gradientBox,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              Text("create_account".tr, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline1),
              const SizedBox(height: 50),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                enabled: !_networking,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(hintText: "enter_name".tr),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                focusNode: _emailFocus,
                enabled: !_networking,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(hintText: "enter_email".tr),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                focusNode: _passFocus,
                enabled: !_networking,
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: "enter_password".tr),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passConfirmationController,
                focusNode: _passConfirmationFocus,
                enabled: !_networking,
                obscureText: true,
                textInputAction: TextInputAction.go,
                onSubmitted: (text) => _createAccount(),
                decoration: InputDecoration(hintText: "confirm_password".tr),
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _networking ? null : _createAccount, child: Text("create_account".tr)),
              SizedBox(
                height: 2,
                child: Visibility(
                  visible: _networking,
                  child: const LinearProgressIndicator(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
