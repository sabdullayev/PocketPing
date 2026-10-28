import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../collections/presentation/widgets/save_to_collection_dialog.dart';
import '../../../environments/domain/entities/environment_variable.dart';
import '../../../environments/presentation/bloc/environments_bloc.dart';
import '../../../environments/presentation/bloc/environments_state.dart';
import '../../../environments/presentation/widgets/environment_selector_widget.dart';
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
  final FocusNode _urlFocusNode = FocusNode();

  String? _activeVariableQuery;
  bool _isDoubleBrace = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _requestTabController = TabController(length: 4, vsync: this);
    final initialUrl = context.read<RequestBuilderBloc>().state.request.url;
    _urlController = TextEditingController(text: initialUrl);
    _urlFocusNode.addListener(() {
      if (!_urlFocusNode.hasFocus && _showSuggestions) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  @override
  void dispose() {
    _requestTabController.dispose();
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _checkVariableTrigger(String text) {
    final selection = _urlController.selection;
    final cursorPosition = selection.baseOffset >= 0 ? selection.baseOffset : text.length;
    final textBefore = text.substring(0, cursorPosition);

    final match = RegExp(r'\{(\{)?([a-zA-Z0-9_]*)$').firstMatch(textBefore);
    if (match != null) {
      final isDouble = match.group(1) != null;
      final query = match.group(2) ?? '';
      setState(() {
        _isDoubleBrace = isDouble;
        _activeVariableQuery = query;
        _showSuggestions = true;
      });
    } else {
      if (_showSuggestions) {
        setState(() {
          _showSuggestions = false;
          _activeVariableQuery = null;
        });
      }
    }
  }

  void _insertVariableSuggestion(String varKey) {
    final text = _urlController.text;
    final selection = _urlController.selection;
    final cursorPosition = selection.baseOffset >= 0 ? selection.baseOffset : text.length;
    final textBefore = text.substring(0, cursorPosition);
    final textAfter = text.substring(cursorPosition);

    final match = RegExp(r'\{(\{)?([a-zA-Z0-9_]*)$').firstMatch(textBefore);
    if (match != null) {
      final startIndex = match.start;
      final inserted = _isDoubleBrace ? '{{$varKey}}' : '{$varKey}';
      final newText = textBefore.substring(0, startIndex) + inserted + textAfter;
      final newCursorPosition = startIndex + inserted.length;

      _urlController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );
      context.read<RequestBuilderBloc>().add(ChangeUrlEvent(newText));
      setState(() {
        _showSuggestions = false;
        _activeVariableQuery = null;
      });
    }
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
    final isKeyboardOpen = View.of(context).viewInsets.bottom > 0;

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
                // Environment Selector Sub-Bar
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
                        child: TextField(
                          controller: _urlController,
                          focusNode: _urlFocusNode,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                            bloc.add(const SendRequestEvent());
                          },
                          onChanged: (val) {
                            _checkVariableTrigger(val);
                            bloc.add(ChangeUrlEvent(val));
                          },
                          style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: '{base_url}/todos/1',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Text(
                                    '{}',
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  tooltip: 'Insert variable',
                                  onPressed: () {
                                    final text = _urlController.text;
                                    final selection = _urlController.selection;
                                    final cursor = selection.baseOffset >= 0 ? selection.baseOffset : text.length;
                                    final newText = '${text.substring(0, cursor)}{${text.substring(cursor)}';
                                    _urlController.value = TextEditingValue(
                                      text: newText,
                                      selection: TextSelection.collapsed(offset: cursor + 1),
                                    );
                                    _urlFocusNode.requestFocus();
                                    _checkVariableTrigger(newText);
                                  },
                                ),
                                if (_urlController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                                    onPressed: () {
                                      _urlController.clear();
                                      bloc.add(const ChangeUrlEvent(''));
                                      setState(() {
                                        _showSuggestions = false;
                                        _activeVariableQuery = null;
                                      });
                                    },
                                  ),
                              ],
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
                                FocusScope.of(context).unfocus();
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

                // Variable autocomplete suggestions dropdown (IntelliSense)
                if (_showSuggestions && _urlFocusNode.hasFocus)
                  _buildVariableSuggestionsPanel(context),

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
                // If keyboard is open, give full available space to Request tab so inputs aren't squished!
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

                // 4. Response Section (Hidden when typing with keyboard, visible when keyboard is down)
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

  Widget _buildVariableSuggestionsPanel(BuildContext context) {
    final envState = context.watch<EnvironmentsBloc>().state;
    List<EnvironmentVariable> availableVars = [];
    if (envState is EnvironmentsLoadedState && envState.selectedEnvironment != null) {
      availableVars = envState.selectedEnvironment!.variables
          .where((v) => v.isEnabled && v.key.trim().isNotEmpty)
          .toList();
    }

    final query = _activeVariableQuery ?? '';
    final matching = availableVars.where((v) {
      if (query.isEmpty) return true;
      return v.key.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
                const SizedBox(width: 6),
                const Text(
                  'VARIABLES AUTOCOMPLETE',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Tap to insert',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (matching.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                availableVars.isEmpty
                    ? 'No variables defined in active environment'
                    : 'No variables matching "$query"',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: matching.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final v = matching[index];
                  return InkWell(
                    onTap: () => _insertVariableSuggestion(v.key),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _isDoubleBrace ? '{{${v.key}}}' : '{${v.key}}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              v.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_return, size: 14, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
