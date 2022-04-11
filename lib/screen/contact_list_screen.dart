import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_contact_list_app/config/assets.dart';
import 'package:simple_contact_list_app/model/contact_dto.dart';
import 'package:simple_contact_list_app/network/client/contact_client.dart';
import 'package:simple_contact_list_app/network/dto/pageable.dart';
import 'package:simple_contact_list_app/screen/create_contact_screen.dart';
import 'package:simple_contact_list_app/style/app_style.dart';
import 'package:simple_contact_list_app/util/compute_util.dart';
import 'package:uuid/uuid.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final ScrollController _scrollController = Get.put(ScrollController());
  final ContactClient _client = Get.put(ContactClient());
  final List<ContactDto> _data = [];
  _ScreenStatus _screenStatus = _ScreenStatus.notInit;
  int _page = -1;
  bool _isLastPage = false;
  String? _lastRequestId;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 400) {
          _load();
        }
      });
    });
    _load();
    super.initState();
  }

  void _reset() {
    _page = -1;
    _isLastPage = false;
    _data.clear();
  }

  void _navigateToCreateContactScreen({int? contactId}) {
    Get.to(() => CreateContactScreen(contactId: contactId))?.then((value) {
      if (value == true) {
        _reset();
        _load();
      }
    });
  }

  void _load() async {
    if (_screenStatus == _ScreenStatus.loading || _isLastPage) return;
    setState(() => _screenStatus = _ScreenStatus.loading);
    String requestId = const Uuid().v4();
    _lastRequestId = requestId;
    _client.getPage(requestId: requestId, name: "", page: _page + 1).then((response) async {
      Pageable pageable = response.wrappedResponse;
      List<ContactDto> list = await ComputeUtil.parseContactList(pageable.content);
      if (!mounted || response.requestId != _lastRequestId) return;
      _data.addAll(list);
      _page = pageable.number;
      _isLastPage = pageable.last;
      setState(() => _screenStatus = _ScreenStatus.ready);
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _screenStatus = _ScreenStatus.error);
    }, test: (e) => e == DioError).catchError((_) {
      if (!mounted) return;
      setState(() => _screenStatus = _ScreenStatus.error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientBox,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(title: Text("contacts".tr)),
            _body(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateContactScreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_data.isEmpty && _screenStatus == _ScreenStatus.loading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    } else if (_data.isEmpty && _screenStatus == _ScreenStatus.error) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("error_unknow".tr),
            IconButton(
              onPressed: () {
                _reset();
                _load();
              },
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
      );
    } else if (_data.isEmpty && _screenStatus == _ScreenStatus.ready) {
      return const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text("No Content")));
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            ContactDto dto = _data[index];
            return ListTile(
              leading: CircleAvatar(
                child: ClipOval(
                  clipBehavior: Clip.antiAlias,
                  child: dto.pictureUrl == null
                      ? Image.asset(Assets.imageContact, fit: BoxFit.cover)
                      : FadeInImage.assetNetwork(
                          placeholder: Assets.imageContact,
                          image: dto.pictureUrl!,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, object, trace) => Image.asset(Assets.imageContact),
                        ),
                ),
              ),
              title: Text(dto.name, maxLines: 1),
              onTap: () => _navigateToCreateContactScreen(contactId: dto.id),
            );
          },
          childCount: _data.length,
        ),
      );
    }
  }
}

enum _ScreenStatus { notInit, loading, error, ready }
