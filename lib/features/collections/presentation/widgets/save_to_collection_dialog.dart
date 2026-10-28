import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../request_builder/domain/entities/http_request_entity.dart';
import '../bloc/collections_bloc.dart';
import '../bloc/collections_event.dart';
import '../bloc/collections_state.dart';

class SaveToCollectionDialog extends StatefulWidget {
  final HttpRequestEntity request;

  const SaveToCollectionDialog({super.key, required this.request});

  static Future<void> show(BuildContext context, HttpRequestEntity request) {
    return showDialog(
      context: context,
      builder: (_) => SaveToCollectionDialog(request: request),
    );
  }

  @override
  State<SaveToCollectionDialog> createState() => _SaveToCollectionDialogState();
}

class _SaveToCollectionDialogState extends State<SaveToCollectionDialog> {
  late final TextEditingController _nameController;
  String? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.request.name.isNotEmpty && widget.request.name != 'New Request'
          ? widget.request.name
          : '${widget.request.method.label} ${widget.request.url.split('/').lastOrNull ?? 'Request'}',
    );
    context.read<CollectionsBloc>().add(const LoadCollectionsEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showCreateCollectionDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        backgroundColor: AppColors.card,
        title: const Text('New Folder / Collection'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Auth Service, Shop API'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = titleController.text.trim();
              if (name.isNotEmpty) {
                context.read<CollectionsBloc>().add(CreateCollectionEvent(name: name));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      backgroundColor: AppColors.card,
      title: const Row(
        children: [
          Icon(Icons.folder_special_outlined, color: AppColors.primary, size: 22),
          SizedBox(width: 8),
          Text('Save to Collection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Request Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'e.g. Get User Profile'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Choose Folder', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                TextButton.icon(
                  onPressed: _showCreateCollectionDialog,
                  icon: const Icon(Icons.add, size: 14, color: AppColors.primary),
                  label: const Text('New Folder', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            BlocBuilder<CollectionsBloc, CollectionsState>(
              builder: (context, state) {
                if (state is CollectionsLoadingState) {
                  return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
                }

                if (state is CollectionsLoadedState) {
                  if (state.collections.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'No folders yet. Tap "New Folder" above.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ),
                    );
                  }

                  if (_selectedCollectionId == null && state.collections.isNotEmpty) {
                    _selectedCollectionId = state.collections.first.id;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCollectionId,
                        isExpanded: true,
                        dropdownColor: AppColors.card,
                        items: state.collections.map((col) {
                          return DropdownMenuItem<String>(
                            value: col.id,
                            child: Row(
                              children: [
                                const Icon(Icons.folder, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    col.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (id) => setState(() => _selectedCollectionId = id),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedCollectionId != null) {
              final updatedReq = widget.request.copyWith(name: _nameController.text.trim());
              context.read<CollectionsBloc>().add(
                    AddRequestToCollectionEvent(
                      collectionId: _selectedCollectionId!,
                      request: updatedReq,
                    ),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Request saved to collection!'),
                  backgroundColor: AppColors.statusSuccess,
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
