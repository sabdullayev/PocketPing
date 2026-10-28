import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../collections/presentation/widgets/save_to_collection_dialog.dart';
import '../../../environments/presentation/widgets/environment_selector_widget.dart';
import '../../../response_viewer/presentation/widgets/metrics_bar_widget.dart';
import '../../../response_viewer/presentation/widgets/response_body_view.dart';
import '../../../../core/utils/curl_parser.dart';
import '../../../environments/presentation/widgets/variable_autocomplete_field.dart';
import '../../domain/entities/http_request_entity.dart';
import '../../domain/entities/request_body.dart';
import '../bloc/request_builder_bloc.dart';
import '../bloc/request_builder_event.dart';
import '../bloc/request_builder_state.dart';
import '../widgets/auth_tab_view.dart';
import '../widgets/body_tab_view.dart';
import '../widgets/headers_tab_view.dart';
import '../widgets/method_selector_widget.dart';
import '../widgets/params_tab_view.dart';

class RequestBuilderScreen extends StatefulWidget {
  const RequestBuilderScreen({super.key});

  @override
  State<RequestBuilderScreen> createState() => _RequestBuilderScreenState();
}

class _RequestBuilderScreenState extends State<RequestBuilderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _requestTabController;
  late final TextEditingController _urlController;
  final FocusNode _urlFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _requestTabController = TabController(length: 4, vsync: this);
    final initialUrl = context.read<RequestBuilderBloc>().state.request.url;
    _urlController = TextEditingController(text: initialUrl);
  }

  @override
  void dispose() {
    _requestTabController.dispose();
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleOneTapCurlImport() async {
    final clipData = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = clipData?.text?.trim() ?? '';
    if (raw.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clipboard is empty! Copy cURL or URL first.'),
            backgroundColor: AppColors.statusClientError,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // 1. Direct cURL check
    if (CurlParser.isCurl(raw)) {
      if (!mounted) return;
      context.read<RequestBuilderBloc>().add(ImportCurlEvent(raw));
      return;
    }

    // 2. Direct URL check (e.g. user copied https://api.biznex.uz/...)
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      if (!mounted) return;
      context.read<RequestBuilderBloc>().add(ChangeUrlEvent(raw));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL imported from clipboard!'),
          backgroundColor: AppColors.statusSuccess,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // 3. Embedded cURL inside text/markdown
    final curlIdx = raw.toLowerCase().indexOf('curl ');
    if (curlIdx >= 0) {
      final sub = raw.substring(curlIdx).trim();
      if (CurlParser.isCurl(sub)) {
        if (!mounted) return;
        context.read<RequestBuilderBloc>().add(ImportCurlEvent(sub));
        return;
      }
    }

    // 4. Try parsing anyway
    final parsed = CurlParser.parse(raw);
    if (parsed != null) {
      if (!mounted) return;
      context.read<RequestBuilderBloc>().add(ImportCurlEvent(raw));
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clipboard text is not a valid cURL or URL:\n${raw.length > 50 ? "${raw.substring(0, 50)}..." : raw}'),
          backgroundColor: AppColors.methodDelete,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleCurlExport(HttpRequestEntity request) {
    final cmd = CurlParser.toCurl(request);
    Clipboard.setData(ClipboardData(text: cmd));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request copied as cURL to clipboard!'),
        backgroundColor: AppColors.statusSuccess,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return BlocConsumer<RequestBuilderBloc, RequestBuilderState>(
      listener: (context, state) {
        if (_urlController.text != state.request.url) {
          _urlController.text = state.request.url;
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.methodDelete,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          // Immediately wipe message from state so it never repeats on next clicks
          context.read<RequestBuilderBloc>().add(const ClearMessagesEvent());
        }

        if (state.infoMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.infoMessage!),
              backgroundColor: AppColors.statusSuccess,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          context.read<RequestBuilderBloc>().add(const ClearMessagesEvent());
        }
      },
      builder: (context, state) {
        final bloc = context.read<RequestBuilderBloc>();
        final request = state.request;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: isKeyboardOpen
              ? null
              : AppBar(
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bolt, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text('PocketPing', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    ],
                  ),
                  actions: [
                    // Save to Collection
                    IconButton(
                      icon: const Icon(Icons.bookmark_add_outlined, size: 20, color: AppColors.primary),
                      tooltip: 'Save to Collection',
                      onPressed: () => SaveToCollectionDialog.show(context, state.request),
                    ),
                    // 1-Tap cURL Import & Long-press Export
                    Tooltip(
                      message: 'Tap: Import cURL/URL from clipboard\nLong-press: Copy as cURL',
                      child: TextButton.icon(
                        onPressed: _handleOneTapCurlImport,
                        onLongPress: () => _handleCurlExport(state.request),
                        icon: const Icon(Icons.content_paste_go, size: 16, color: AppColors.primary),
                        label: const Text(
                          'cURL',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
          body: SafeArea(
            child: Column(
              children: [
                // Environment Selector Sub-Bar (Hidden when keyboard is open to maximize editor room)
                if (!isKeyboardOpen)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const EnvironmentSelectorWidget(),
                        const Text(
                          'Variables: {{name}}',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),

                // 1. Top URL & Method & Send Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      MethodSelectorWidget(
                        currentMethod: request.method,
                        onMethodChanged: (method) => bloc.add(ChangeMethodEvent(method)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: VariableAutocompleteField(
                          controller: _urlController,
                          focusNode: _urlFocusNode,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            bloc.add(const SendRequestEvent());
                          },
                          onChanged: (val) {
                            bloc.add(ChangeUrlEvent(val));
                          },
                          style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: '{base_url}/todos/1',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      final text = _urlController.text;
                                      final selection = _urlController.selection;
                                      final cursor = selection.baseOffset >= 0 ? selection.baseOffset : text.length;
                                      final newText = '${text.substring(0, cursor)}{${text.substring(cursor)}';
                                      _urlController.value = TextEditingValue(
                                        text: newText,
                                        selection: TextSelection.collapsed(offset: cursor + 1),
                                      );
                                      _urlFocusNode.requestFocus();
                                    },
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.card,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: const Text(
                                        '{}',
                                        style: TextStyle(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_urlController.text.isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () {
                                        _urlController.clear();
                                        bloc.add(const ChangeUrlEvent(''));
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.close, size: 16, color: AppColors.textMuted),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send Button
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                bloc.add(const SendRequestEvent());
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // 2. Request Configuration Tabs (Params, Auth, Headers, Body)
                Container(
                  color: AppColors.surface,
                  child: TabBar(
                    controller: _requestTabController,
                    tabs: [
                      Tab(text: 'Params (${request.queryParams.length})'),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Auth'),
                            if (request.bearerToken != null && request.bearerToken!.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(text: 'Headers (${request.headers.length})'),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Body'),
                            if (request.body.type != RequestBodyType.none) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Request Configuration Tab Body
                // When keyboard is open, give 100% of available space to the input tab so the editor never gets squished
                Expanded(
                  flex: isKeyboardOpen ? 1 : 3,
                  child: TabBarView(
                    controller: _requestTabController,
                    children: [
                      ParamsTabView(
                        queryParams: request.queryParams,
                        onAddParam: () => bloc.add(const AddQueryParamEvent()),
                        onToggleParam: (id) => bloc.add(ToggleQueryParamEvent(id)),
                        onUpdateParam: (id, k, v) => bloc.add(UpdateQueryParamEvent(id, k, v)),
                        onRemoveParam: (id) => bloc.add(RemoveQueryParamEvent(id)),
                      ),
                      AuthTabView(
                        bearerToken: request.bearerToken,
                        onTokenChanged: (token) => bloc.add(ChangeBearerTokenEvent(token)),
                      ),
                      HeadersTabView(
                        headers: request.headers,
                        onAddHeader: () => bloc.add(const AddHeaderEvent()),
                        onToggleHeader: (id) => bloc.add(ToggleHeaderEvent(id)),
                        onUpdateHeader: (id, k, v) => bloc.add(UpdateHeaderEvent(id, k, v)),
                        onRemoveHeader: (id) => bloc.add(RemoveHeaderEvent(id)),
                      ),
                      BodyTabView(
                        body: request.body,
                        onTypeChanged: (type) => bloc.add(ChangeBodyTypeEvent(type)),
                        onContentChanged: (content) => bloc.add(ChangeBodyContentEvent(content)),
                        onFormatJson: () => bloc.add(const FormatJsonBodyEvent()),
                      ),
                    ],
                  ),
                ),

                // 4. Response Section
                // When keyboard is open, hide response section completely so inputs have full height and never disappear!
                if (!isKeyboardOpen) ...[
                  const Divider(height: 1, color: AppColors.border),
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: AppColors.background,
                      child: state.response == null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.wifi_tethering,
                                    size: 44,
                                    color: AppColors.textMuted.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Ready to ping',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Enter URL or tap "cURL" to import and test',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                MetricsBarWidget(
                                  response: state.response!,
                                  onClose: () => bloc.add(const ClearResponseEvent()),
                                ),
                                Expanded(
                                  child: ResponseBodyView(response: state.response!),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
