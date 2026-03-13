import 'package:flutter/material.dart';
import 'package:uangku/core/theme/app_theme.dart';

/// Represents an item that can be picked in the [SearchablePickerSheet].
class PickerItem<T> {
  final T id;
  final String name;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const PickerItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.subtitle,
  });
}

/// A generic searchable picker sheet for categories, wallets, etc.
class SearchablePickerSheet<T> extends StatefulWidget {
  final String title;
  final List<PickerItem<T>> items;
  final List<PickerItem<T>>? recentItems;
  final T? selectedId;
  final String? addNewLabel;
  final void Function(String query)? onAddNew;
  final String searchPlaceholder;

  const SearchablePickerSheet({
    super.key,
    required this.title,
    required this.items,
    this.recentItems,
    this.selectedId,
    this.addNewLabel,
    this.onAddNew,
    this.searchPlaceholder = 'Search...',
  });

  /// Shows the picker sheet as a modal bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<PickerItem<T>> items,
    List<PickerItem<T>>? recentItems,
    T? selectedId,
    String? addNewLabel,
    void Function(String query)? onAddNew,
    String searchPlaceholder = 'Search...',
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SearchablePickerSheet<T>(
          title: title,
          items: items,
          recentItems: recentItems,
          selectedId: selectedId,
          addNewLabel: addNewLabel,
          onAddNew: onAddNew,
          searchPlaceholder: searchPlaceholder,
        ),
      ),
    );
  }

  @override
  State<SearchablePickerSheet<T>> createState() => _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<SearchablePickerSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PickerItem<T>> get _filteredItems {
    if (_query.isEmpty) return widget.items;
    return widget.items
        .where((item) => item.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredItems;
    final showRecent = _query.isEmpty && widget.recentItems != null && widget.recentItems!.isNotEmpty;

    return Column(
      children: [
        // ── Handle bar ───────────────────────────────────────
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // ── Header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),

        // ── Search Bar ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (val) => setState(() => _query = val),
            decoration: InputDecoration(
              hintText: widget.searchPlaceholder,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // ── List ────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              if (showRecent) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    'Recent',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...widget.recentItems!.map((item) => _buildItemTile(item)),
                const Divider(height: 24, indent: 8, endIndent: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    'All Items',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              
              if (filtered.isEmpty) 
                _buildEmptyState(theme)
              else
                ...filtered.map((item) => _buildItemTile(item)),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_query"',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.addNewLabel != null && widget.onAddNew != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onAddNew!(_query);
              },
              icon: const Icon(Icons.add),
              label: Text('${widget.addNewLabel}: "$_query"'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemTile(PickerItem<T> item) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedId == item.id;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, color: item.color, size: 20),
      ),
      title: _HighlightedText(
        text: item.name,
        query: _query,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        ),
        highlightStyle: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: OceanFlowColors.primary,
        ),
      ),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      trailing: isSelected ? const Icon(Icons.check, color: OceanFlowColors.primary) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () => Navigator.pop(context, item.id),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;

  const _HighlightedText({
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(text, style: style);
    }

    final matches = query.toLowerCase().allMatches(text.toLowerCase());
    if (matches.isEmpty) return Text(text, style: style);

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: style));
      }
      spans.add(TextSpan(text: text.substring(match.start, match.end), style: highlightStyle));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }

    return Text.rich(TextSpan(children: spans));
  }
}
