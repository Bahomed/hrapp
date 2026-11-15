import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';
import 'package:co.injazathr.injazathr/utils/api_result.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';

/// Final settlement print (`GET my/final-settlements/{taskId}/print?style=`)
/// shown in a web view, as the API reference asks. The HTML is fetched with
/// the login token (AuthInterceptor) and loaded as a string, so the token is
/// never put in a URL. `style`: slip (default) or full.
class SettlementPrintScreen extends StatefulWidget {
  final int taskId;
  final String title;
  const SettlementPrintScreen({super.key, required this.taskId, required this.title});

  @override
  State<SettlementPrintScreen> createState() => _SettlementPrintScreenState();
}

class _SettlementPrintScreenState extends State<SettlementPrintScreen> {
  final WebViewController _web = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted);
  String _style = 'slip';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final base = await Preferences().getWorkspaceUrl();
    final locale = ApiHelper.instance.getCurrentLocale();
    final r = await ApiResult.guard(() => DioClient().dio.get<String>(
          '$base${myFinalSettlementPrintUrl(widget.taskId)}',
          queryParameters: {'style': _style, 'locale': locale},
          options: Options(
            responseType: ResponseType.plain,
            headers: {'Accept': 'text/html, application/json', 'Accept-Language': locale},
          ),
        ));
    if (!mounted) return;
    final html = r.data is String ? r.data as String : (r.data is List<int> ? utf8.decode(r.data as List<int>) : '');
    if (!r.ok || !html.trimLeft().startsWith('<')) {
      setState(() {
        _loading = false;
        _error = r.displayMessage(tr('ap_could_not_open'));
      });
      return;
    }
    await _web.loadHtmlString(html, baseUrl: base);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Scaffold(
      backgroundColor: theme.getPageBackgroundColor(),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'slip', label: Text(tr('fs_print_slip'))),
                ButtonSegment(value: 'full', label: Text(tr('fs_print_full'))),
              ],
              selected: {_style},
              onSelectionChanged: (s) {
                _style = s.first;
                _load();
              },
            ),
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _load, child: Text(tr('retry'))),
                ]),
              ),
            )
          : Stack(children: [
              WebViewWidget(controller: _web),
              if (_loading) const Center(child: CircularProgressIndicator()),
            ]),
    );
  }
}
