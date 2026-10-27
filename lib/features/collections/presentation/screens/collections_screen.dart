import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../request_builder/presentation/bloc/request_builder_bloc.dart';
import '../../../request_builder/presentation/bloc/request_builder_event.dart';
import '../../domain/entities/collection_entity.dart';
import '../bloc/collections_bloc.dart';
import '../bloc/collections_event.dart';
import '../bloc/collections_state.dart';

class CollectionsScreen extends StatefulWidget {
  final VoidCallback onNavigateToBuilder;

  const CollectionsScreen({super.key, required this.onNavigateToBuilder});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CollectionsBloc>().add(const LoadCollectionsEvent());
  }

  void _showCreateCollectionDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('New Collection Folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Folder name (e.g. Auth API)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: 'Description (optional)'),
            ),
          ],
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
                context.read<CollectionsBloc>().add(
                      CreateCollectionEvent(
                        name: name,
                        description: descController.text.trim(),
                      ),
                    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, color: AppColors.primary),
            tooltip: 'New Collection',
            onPressed: _showCreateCollectionDialog,
          ),
        ],
      ),
      body: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          if (state is CollectionsLoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is CollectionsLoadedState) {
            if (state.collections.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 54,
                      color: AppColors.textMuted.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No collections yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Create folders to organize your requests',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showCreateCollectionDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Create Folder'),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.collections.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final collection = state.collections[index];
                return _CollectionFolderCard(
                  collection: collection,
                  onNavigateToBuilder: widget.onNavigateToBuilder,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CollectionFolderCard extends StatelessWidget {
  final CollectionEntity collection;
  final VoidCallback onNavigateToBuilder;

  const _CollectionFolderCard({
    required this.collection,
    required this.onNavigateToBuilder,
  });

  void _confirmDeleteCollection(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete "${collection.name}"?'),
        content: const Text('This will delete the folder and all saved requests inside it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.methodDelete),
            onPressed: () {
              context.read<CollectionsBloc>().add(DeleteCollectionEvent(collection.id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.folder, color: AppColors.primary, size: 24),
          title: Text(
            collection.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${collection.requests.length} requests${collection.description.isNotEmpty ? ' • ${collection.description}' : ''}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                onPressed: () => _confirmDeleteCollection(context),
              ),
              const Icon(Icons.expand_more, color: AppColors.textSecondary),
            ],
          ),
          children: [
            if (collection.requests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No requests in this collection yet.\nUse "Save to Collection" in Request Builder.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: collection.requests.length,
                separatorBuilder: (_, _) => const Divider(color: AppColors.border, height: 1),
                itemBuilder: (context, idx) {
                  final req = collection.requests[idx];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: req.method.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        req.method.label,
                        style: TextStyle(
                          color: req.method.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    title: Text(
                      req.name.isNotEmpty ? req.name : req.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      req.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 14, color: AppColors.textMuted),
                      onPressed: () {
                        context.read<CollectionsBloc>().add(
                              RemoveRequestFromCollectionEvent(
                                collectionId: collection.id,
                                requestId: req.id,
                              ),
                            );
                      },
                    ),
                    onTap: () {
                      context.read<RequestBuilderBloc>().add(LoadRequestEvent(req));
                      onNavigateToBuilder();
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
