import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/json_isolate_service.dart';
import '../../domain/entities/http_response_entity.dart';

class ResponseBodyView extends StatefulWidget {
  final HttpResponseEntity response;

  const ResponseBodyView({super.key, required this.response});

  @override
  State<ResponseBodyView> createState() => _ResponseBodyViewState();
}

class _ResponseBodyViewState extends State<ResponseBodyView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _formattedJson = '';
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _formatContent();
  }

  @override
  void didUpdateWidget(covariant ResponseBodyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.response.bodyString != widget.response.bodyString) {
      _formatContent();
    }
  }

  Future<void> _formatContent() async {
    if (widget.response.isJson && widget.response.bodyString.isNotEmpty) {
      setState(() => _isFormatting = true);
      final formatted = await JsonIsolateService.formatJson(widget.response.bodyString);
      if (mounted) {
        setState(() {
          _formattedJson = formatted;
          _isFormatting = false;
        });
      }
    } else {
      setState(() {
        _formattedJson = widget.response.bodyString;
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

  @override
  Widget build(BuildContext context) {
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
                  labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                  tabs: [
                    Tab(text: widget.response.isJson ? 'JSON' : 'Preview'),
                    const Tab(text: 'Raw'),
                    Tab(text: 'Headers (${widget.response.headers.length})'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: AppColors.textSecondary),
                tooltip: 'Copy Body',
                onPressed: () => _copyToClipboard(
                  _tabController.index == 0 ? _formattedJson : widget.response.bodyString,
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
              // 1. JSON / Preview Tab
              _buildPreviewTab(),
              // 2. Raw Tab
              _buildRawTab(),
              // 3. Headers Tab
              _buildHeadersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewTab() {
    if (_isFormatting) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: widget.response.isJson
          ? HighlightView(
              _formattedJson,
              language: 'json',
              theme: atomOneDarkTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.4,
              ),
            )
          : SelectableText(
              widget.response.bodyString,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
    );
  }

  Widget _buildRawTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SelectableText(
        widget.response.bodyString.isEmpty ? '(Empty response)' : widget.response.bodyString,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
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
