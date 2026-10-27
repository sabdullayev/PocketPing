import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../collections/presentation/widgets/save_to_collection_dialog.dart';
import '../../../response_viewer/presentation/widgets/metrics_bar_widget.dart';
import '../../../response_viewer/presentation/widgets/response_body_view.dart';
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
    super.dispose();
  }

  Future<void> _importCurlFromClipboard() async {
    final clipData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipData?.text?.trim() ?? '';
    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clipboard is empty!'),
            backgroundColor: AppColors.statusClientError,
          ),
        );
      }
      return;
    }

    if (mounted) {
      context.read<RequestBuilderBloc>().add(ImportCurlEvent(text));
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ),
          );
        }

        if (state.infoMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.infoMessage!),
              backgroundColor: AppColors.statusSuccess,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<RequestBuilderBloc>();
        final request = state.request;

        return Scaffold(
          appBar: AppBar(
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
              // Killer feature: 1-tap cURL import
              TextButton.icon(
                onPressed: _importCurlFromClipboard,
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
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 1. Top URL & Method & Send Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      MethodSelectorWidget(
                        currentMethod: request.method,
                        onMethodChanged: (method) => bloc.add(ChangeMethodEvent(method)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (_) => bloc.add(const SendRequestEvent()),
                          onChanged: (val) => bloc.add(ChangeUrlEvent(val)),
                          style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: 'https://api.example.com/v1/resource',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            suffixIcon: _urlController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                                    onPressed: () {
                                      _urlController.clear();
                                      bloc.add(const ChangeUrlEvent(''));
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send Button
                      ElevatedButton(
                        onPressed: state.isLoading ? null : () => bloc.add(const SendRequestEvent()),
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

                // 3. Request Configuration Tab Body (Collapsible / Flexible)
                Expanded(
                  flex: 3,
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

                const Divider(height: 1, color: AppColors.border),

                // 4. Response Section Header & Body
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
                                  size: 48,
                                  color: AppColors.textMuted.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Ready to ping',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Enter URL or tap "cURL" to import and test',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              MetricsBarWidget(response: state.response!),
                              Expanded(
                                child: ResponseBodyView(response: state.response!),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
