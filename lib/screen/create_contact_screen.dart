import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_contact_list_app/config/app_constraints.dart';
import 'package:simple_contact_list_app/config/assets.dart';
import 'package:simple_contact_list_app/model/contact_dto.dart';
import 'package:simple_contact_list_app/model/contact_form.dart';
import 'package:simple_contact_list_app/network/client/contact_client.dart';
import 'package:simple_contact_list_app/network/dto/client_response.dart';
import 'package:simple_contact_list_app/style/app_style.dart';
import 'package:simple_contact_list_app/widget/full_error_widget.dart';
import 'package:simple_contact_list_app/widget/full_loading_widget.dart';
import 'package:simple_contact_list_app/widget/my_circle_avatar_widget.dart';
import 'package:simple_contact_list_app/widget/phone_dialog.dart';
import 'package:simple_contact_list_app/widget/select_image_source_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateContactScreen extends StatefulWidget {
  final int? contactId;

  const CreateContactScreen({Key? key, this.contactId}) : super(key: key);

  @override
  State<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {
  final ContactClient _client = ContactClient();
  final ImagePicker _imagePicker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();
  final TextEditingController _nameController = Get.put(TextEditingController(), tag: "contactNameController");
  final TextEditingController _emailController = Get.put(TextEditingController(), tag: "contactEmailController");
  final TextEditingController _addressController = Get.put(TextEditingController(), tag: "contactAddressController");
  final List<String> _phones = [];
  String? _tempImagePath;
  String? _pictureUrl;
  _ScreenState _state = _ScreenState.ready;
  late _Mode _mode;

  @override
  void initState() {
    _mode = widget.contactId == null ? _Mode.create : _Mode.update;
    if (_mode == _Mode.update) _load();
    super.initState();
  }

  void _selectImageSource() {
    showDialog<ImageSource?>(context: context, builder: (context) => const SelectImageSourceDialog()).then((source) {
      if (source != null) _getImage(source);
    });
  }

  Future<void> _getImage(ImageSource source) async {
    var xFile = await _imagePicker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (xFile != null) _cropImage(xFile.path);
  }

  Future<void> _cropImage(String path) async {
    File? croppedFile = await _imageCropper.cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 540,
      maxWidth: 540,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      cropStyle: CropStyle.circle,
    );

    if (croppedFile != null) setState(() => _tempImagePath = croppedFile.path);
  }

  void _callContact(int index) {
    launch("tel:${_phones[index]}");
  }

  void _addPhone() {
    FocusScope.of(context).unfocus();
    Get.dialog(const PhoneDialog()).then((result) {
      if (result?.isNotEmpty ?? false) setState(() => _phones.add(result!));
    });
  }

  void _load() {
    if (_state == _ScreenState.loading) return;
    setState(() => _state = _ScreenState.loading);
    _client.get(contactId: widget.contactId!).then((response) {
      var dto = ContactDto.fromJson(jsonDecode(response.wrappedResponse.data))!;
      _nameController.text = dto.name;
      _emailController.text = dto.email ?? "";
      _addressController.text = dto.address ?? "";
      _phones.addAll(dto.phones ?? []);
      _pictureUrl = dto.pictureUrl;
      setState(() => _state = _ScreenState.ready);
    }).catchError((e) {
      setState(() => _state = _ScreenState.error);
    });
  }

  bool _validateForm() {
    String name = _nameController.text;
    String? formError;
    if (name.isEmpty) {
      formError = "enter_name".tr;
    } else if (name.length < contactNameMinLenght) {
      formError = "error_name_min_lenght".tr;
    }

    if (formError != null) {
      Get.snackbar("Oops...", formError, snackStyle: SnackStyle.FLOATING, overlayBlur: snackbarOverlayBlur);
    }
    return formError == null;
  }

  void _save() {
    if (_state == _ScreenState.saving || !_validateForm()) return;
    setState(() => _state = _ScreenState.saving);
    if (_mode == _Mode.create) {
      _handleSaveUpdateFutureResponse(
        _client.create(
          form: ContactForm(
            name: _nameController.text,
            email: _emailController.text,
            address: _addressController.text,
            phones: _phones,
          ),
          filePath: _tempImagePath,
        ),
      );
    } else {
      _handleSaveUpdateFutureResponse(
        _client.update(
          contactId: widget.contactId!,
          form: ContactForm(
            name: _nameController.text,
            email: _emailController.text,
            address: _addressController.text,
            phones: _phones,
          ),
          filePath: _tempImagePath,
        ),
      );
    }
  }

  void _handleSaveUpdateFutureResponse(Future<ClientResponse> future) {
    future.then((r) async {
      if (!mounted) return;
      Get.back(result: true);
    }).catchError((e) {
      String message = "error_unknow".tr;
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.connectTimeout:
          case DioErrorType.sendTimeout:
          case DioErrorType.receiveTimeout:
            message = "error_conexao".tr;
            break;
          case DioErrorType.response:
            if (e.response?.data?.toString().contains("propertyPath=name") ?? false) {
              message = "error_name_min_lenght".tr;
            } else if (e.response?.data?.toString().contains("propertyPath=email") ?? false) {
              message = "error_email_invalid".tr;
            }
            break;
          case DioErrorType.cancel:
            break;
          case DioErrorType.other:
            break;
        }
      }
      Get.snackbar("Oops...", message, overlayBlur: snackbarOverlayBlur);
    }).whenComplete(() => setState(() => _state = _ScreenState.ready));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientBox,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _appBar(context),
            SliverVisibility(
              visible: _state == _ScreenState.ready || _state == _ScreenState.saving,
              sliver: _formWidget(context),
              replacementSliver: SliverFillRemaining(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _errorWidget(context),
                    ),
                    Positioned.fill(
                      child: _loadingWidget(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return SliverAppBar(
      title: Text(_mode == _Mode.create ? "create_contact".tr : "update_contact".tr),
      floating: true,
      snap: true,
      actions: [
        _state == _ScreenState.ready
            ? IconButton(onPressed: _save, icon: const Icon(Icons.check))
            : _state == _ScreenState.saving
                ? const IconButton(onPressed: null, icon: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1))))
                : Container()
      ],
    );
  }

  Widget _formWidget(BuildContext context) {
    return SliverFillRemaining(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            FractionallySizedBox(
              widthFactor: 0.35,
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    MyCircleAvatarWidget(
                      imageUrl: _pictureUrl ?? "",
                      placeholderAsset: Assets.imageContact,
                      localStorageTempImagePath: _tempImagePath,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withOpacity(0.7),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _selectImageSource,
                          color: Colors.white,
                          iconSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(hintText: "enter_name".tr),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(hintText: "enter_email".tr),
                  ),
                  const SizedBox(height: 16),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    child: TextField(
                      controller: _addressController,
                      minLines: 1,
                      maxLines: 3,
                      keyboardType: TextInputType.streetAddress,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(hintText: "enter_address".tr),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            ListTile(
              leading: const IconButton(
                icon: Icon(Icons.add, color: Colors.transparent),
                onPressed: null,
              ),
              title: Text("phones".tr, textAlign: TextAlign.center),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addPhone,
              ),
            ),
            ListView.separated(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _phones.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                String phone = _phones[index];
                return Dismissible(
                  key: UniqueKey(),
                  // direction: DismissDirection.startToEnd,
                  child: ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () => _callContact(index),
                    ),
                    title: Text(phone),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      return true;
                    } else {
                      _callContact(index);
                      return false;
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      setState(() => _phones.removeAt(index));
                    }
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    color: Colors.red.withOpacity(0.2),
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 16),
                        Text("remove".tr),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.blue.withOpacity(0.2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("call".tr),
                        const SizedBox(width: 16),
                        Icon(Icons.call, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 68),
          ],
        ),
      ),
    );
  }

  Widget _loadingWidget(BuildContext context) {
    return Visibility(
      visible: _state == _ScreenState.loading,
      child: const FullLoadingWidget(),
    );
  }

  Widget _errorWidget(BuildContext context) {
    return Visibility(
      visible: _state == _ScreenState.error,
      child: FullErrorWidget(
        text: "error_unknow".tr,
        tryAgain: _load,
      ),
    );
  }
}

enum _ScreenState { loading, error, ready, saving }

enum _Mode { create, update }
