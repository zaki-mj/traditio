import 'package:flutter/material.dart';

/// A polished search + filter bar for admin list pages.
///
/// Usage:
///   AdminSearchBar(
///     hintText: 'Search places...',
///     onChanged: (q) => ...,
///     filters: [
///       AdminFilterChip(label: 'Hotel', value: 'hotel', selected: ..., onTap: ...),
///     ],
///     trailing: [...],   // optional extra buttons (e.g. sort)
///   )

class AdminSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final List<AdminFilterChip> filters;
  final List<Widget> trailing;
  final String initialValue;

  const AdminSearchBar({super.key, required this.hintText, required this.onChanged, this.filters = const [], this.trailing = const [], this.initialValue = ''});

  @override
  State<AdminSearchBar> createState() => _AdminSearchBarState();
}

class _AdminSearchBarState extends State<AdminSearchBar> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animCtrl;
  late Animation<double> _clearFade;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = widget.initialValue.isNotEmpty;
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _clearFade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    if (_hasText) _animCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final has = v.isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
      has ? _animCtrl.forward() : _animCtrl.reverse();
    }
    widget.onChanged(v);
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = isDark ? colorScheme.surfaceContainerHighest.withOpacity(0.6) : colorScheme.surfaceContainerLowest;

    final borderColor = _hasFocus ? colorScheme.primary.withOpacity(0.6) : colorScheme.outline.withOpacity(0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search input ───────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: _hasFocus ? 1.5 : 1),
            boxShadow: _hasFocus ? [BoxShadow(color: colorScheme.primary.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))] : [],
          ),
          child: Focus(
            onFocusChange: (f) => setState(() => _hasFocus = f),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.38)),
                prefixIcon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.search_rounded, size: 20, color: _hasFocus ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.45)),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _clearFade,
                      child: _hasText
                          ? GestureDetector(
                              onTap: _clear,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.cancel_rounded, size: 18, color: colorScheme.onSurface.withOpacity(0.4)),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    ...widget.trailing.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // ── Filter chips ───────────────────────────────────────────────────
        if (widget.filters.isNotEmpty) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(children: widget.filters.map((chip) => _buildChip(context, chip)).toList()),
          ),
        ],
      ],
    );
  }

  Widget _buildChip(BuildContext context, AdminFilterChip chip) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = chip.selected;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected ? (chip.activeColor ?? colorScheme.primary) : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? (chip.activeColor ?? colorScheme.primary) : colorScheme.outline.withOpacity(0.25), width: selected ? 0 : 1),
        ),
        child: InkWell(
          onTap: chip.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (chip.icon != null) ...[Icon(chip.icon, size: 14, color: selected ? Colors.white : colorScheme.onSurface.withOpacity(0.6)), const SizedBox(width: 5)],
                Text(
                  chip.label,
                  style: theme.textTheme.labelSmall?.copyWith(color: selected ? Colors.white : colorScheme.onSurface.withOpacity(0.75), fontWeight: selected ? FontWeight.w600 : FontWeight.w500, letterSpacing: 0.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for a single filter chip in [AdminSearchBar].
class AdminFilterChip {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? activeColor;

  const AdminFilterChip({required this.label, required this.value, required this.selected, required this.onTap, this.icon, this.activeColor});
}
