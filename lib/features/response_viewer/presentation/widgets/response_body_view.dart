import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/json_isolate_service.dart';
import '../../domain/entities/http_response_entity.dart';
import 'json_tree_view.dart';
import 'virtualized_code_viewer.dart';

class ResponseBodyView extends StatefulWidget {
  final HttpResponseEntity response;

  const ResponseBodyView({super.key, required this.response});

  @override
  State<ResponseBodyView> createState() => _ResponseBodyViewState();
}

class _ResponseBodyViewState extends State<ResponseBodyView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _formattedJson = '';
  dynamic _parsedJson;
  List<String> _lines = [];
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.response.isJson ? 4 : 3,
      vsync: this,
    );
    _formatContent();
  }

  @override
  void didUpdateWidget(covariant ResponseBodyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.response.bodyString != widget.response.bodyString) {
      if ((oldWidget.response.isJson && !widget.response.isJson) ||
          (!oldWidget.response.isJson && widget.response.isJson)) {
        _tabController.dispose();
        _tabController = TabController(
          length: widget.response.isJson ? 4 : 3,
          vsync: this,
        );
      }
      _formatContent();
    }
  }

  Future<void> _formatContent() async {
    if (widget.response.isJson && widget.response.bodyString.isNotEmpty) {
      setState(() => _isFormatting = true);
      final result = await JsonIsolateService.processJson(widget.response.bodyString);
      if (mounted) {
        setState(() {
          _formattedJson = result.formattedJson;
          _parsedJson = result.parsedJson;
          _lines = result.lines;
          _isFormatting = false;
        });
      }
    } else {
      setState(() {
        _formattedJson = widget.response.bodyString;
        _parsedJson = null;
        _lines = widget.response.bodyString.split('\n');
        _isFormatting = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  String? _getAuthHeader() {
    for (final entry in widget.response.headers.entries) {
      if (entry.key.toLowerCase() == 'www-authenticate') {
        final val = entry.value.join(', ');
        final match = RegExp(r'error_description="([^"]+)"').firstMatch(val);
        if (match != null) {
          return match.group(1);
        }
        return val;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isJson = widget.response.isJson;

    return Column(
      children: [
        // Sub-tabs & Copy Button
        Container(
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                  tabs: [
                    Tab(text: isJson ? 'Pretty' : 'Preview'),
                    const Tab(text: 'Raw'),
                    if (isJson) const Tab(text: 'Tree'),
                    Tab(text: 'Headers (${widget.response.headers.length})'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: AppColors.textSecondary),
                tooltip: 'Copy Body',
                onPressed: () => _copyToClipboard(
                  _formattedJson.isNotEmpty ? _formattedJson : widget.response.bodyString,
                  'Response',
                ),
              ),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPrettyTab(),
              _buildRawTab(),
              if (isJson) _buildTreeTab(),
              _buildHeadersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTreeTab() {
    if (_isFormatting) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (widget.response.bodyString.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              widget.response.statusCode == 401 ? '401 Unauthorized: Empty body' : 'Empty response body',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }
    if (_parsedJson == null) {
      return const Center(
        child: Text('Unable to parse JSON tree', style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return JsonTreeView(data: _parsedJson);
  }

  Widget _buildPrettyTab() {
    if (_isFormatting) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final authHeader = _getAuthHeader();
    if (widget.response.statusCode == 401) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusClientError.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.statusClientError.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock_clock, color: AppColors.statusClientError, size: 18),
                      SizedBox(width: 8),
                      Text(
                        '401 Unauthorized (Auth Failed)',
                        style: TextStyle(
                          color: AppColors.statusClientError,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (authHeader != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      authHeader,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (widget.response.bodyString.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text(
                    'Server returned empty body.\nCheck token expiration or permissions above.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              )
            else
              Expanded(
                child: VirtualizedCodeViewer(
                  content: widget.response.isJson ? _formattedJson : widget.response.bodyString,
                  preSplitLines: _lines,
                  isJson: widget.response.isJson,
                ),
              ),
          ],
        ),
      );
    }

    if (widget.response.bodyString.isEmpty) {
      return const Center(
        child: Text(
          'Empty response body',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
    }

    return VirtualizedCodeViewer(
      content: widget.response.isJson ? _formattedJson : widget.response.bodyString,
      preSplitLines: _lines,
      isJson: widget.response.isJson,
    );
  }

  Widget _buildRawTab() {
    return VirtualizedCodeViewer(
      content: widget.response.bodyString.isEmpty ? '(Empty response)' : widget.response.bodyString,
      isJson: false,
    );
  }

  Widget _buildHeadersTab() {
    if (widget.response.headers.isEmpty) {
      return const Center(
        child: Text(
          'No response headers',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
    }

    final headerEntries = widget.response.headers.entries.toList();
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: headerEntries.length,
      separatorBuilder: (_, _) => const Divider(color: AppColors.border, height: 1),
      itemBuilder: (context, index) {
        final entry = headerEntries[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: SelectableText(
                  entry.value.join(', '),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
