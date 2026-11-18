import 'package:flutter/material.dart';

import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';

/// Shared searchable dropdown for the whole app.
///
/// * [showSearchablePicker] — bottom sheet: search box + list, returns the
///   picked item (null when dismissed).
/// * [SearchableDropdownField] — a form field that opens it; drop-in for
///   `DropdownButtonFormField` (value, items, label, validator, loading,
///   the screen's own `InputDecoration`).
///
/// Search ignores case and Arabic spelling variants (أ إ آ → ا, ة → ه,
/// ى → ي, harakat / tatweel removed), and matches anywhere in the text.

/// Normalised text for searching (Arabic + Latin).
String searchNormalize(String s) {
  var t = s.toLowerCase().trim();
  t = t.replaceAll(RegExp('[ً-ْٰـ]'), ''); // harakat, tatweel
  t = t
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي');
  return t.replaceAll(RegExp(r'\s+'), ' ');
}

/// Opens the searchable list. [itemSubtitle] adds a second line (also
/// searched). [isSelected] marks the current value (default `==`).
Future<T?> showSearchablePicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) itemLabel,
  String? Function(T)? itemSubtitle,
  T? selected,
  bool Function(T a, T b)? isSelected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: ThemeService.instance.getSurfaceColor(),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => _PickerSheet<T>(
      title: title,
      items: items,
      itemLabel: itemLabel,
      itemSubtitle: itemSubtitle,
      selected: selected,
      isSelected: isSelected,
    ),
  );
}

class _PickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final String? Function(T)? itemSubtitle;
  final T? selected;
  final bool Function(T a, T b)? isSelected;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    this.itemSubtitle,
    this.selected,
    this.isSelected,
  });

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _isSelected(T item) {
    final sel = widget.selected;
    if (sel == null) return false;
    return widget.isSelected != null ? widget.isSelected!(item, sel) : item == sel;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final q = searchNormalize(_q);
    final list = q.isEmpty
        ? widget.items
        : widget.items.where((i) {
            final text = '${widget.itemLabel(i)} ${widget.itemSubtitle?.call(i) ?? ''}';
            return searchNormalize(text).contains(q);
          }).toList();

    return Padding(
      // keep the list above the keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.getDividerColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(widget.title,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: theme.getTextPrimaryColor())),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _q = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: tr('search'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _q.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _search.clear();
                            _q = '';
                          }),
                        ),
                  isDense: true,
                  filled: true,
                  fillColor: theme.getCardColor(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.getDividerColor()),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.getDividerColor()),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(tr('no_results'),
                          style: TextStyle(color: theme.getTextSecondaryColor())),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final item = list[i];
                        final sub = widget.itemSubtitle?.call(item);
                        final sel = _isSelected(item);
                        return ListTile(
                          title: Text(widget.itemLabel(item),
                              style: TextStyle(
                                  fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                                  color: theme.getTextPrimaryColor())),
                          subtitle: (sub == null || sub.isEmpty)
                              ? null
                              : Text(sub, style: TextStyle(color: theme.getTextSecondaryColor())),
                          trailing: sel ? Icon(Icons.check, color: theme.getPrimaryColor()) : null,
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Form field that opens [showSearchablePicker]. Use instead of
/// `DropdownButtonFormField` anywhere in the app.
class SearchableDropdownField<T> extends FormField<T> {
  SearchableDropdownField({
    super.key,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
    String? title,
    String? hint,
    String? Function(T)? itemSubtitle,
    bool Function(T a, T b)? isSelected,
    InputDecoration? decoration,
    bool isLoading = false,
    bool enabled = true,
    TextStyle? style,
    FormFieldValidator<T>? validator,
    super.autovalidateMode,
  }) : super(
          // validate the value the screen holds (it may be pre-filled or
          // changed in code), not only the last one picked here
          validator: validator == null ? null : (_) => validator(value),
          initialValue: value,
          enabled: enabled && !isLoading,
          builder: (state) {
            final theme = ThemeService.instance;
            final context = state.context;
            // keep the field in sync when the parent changes the value
            final current = value;
            final label = current == null ? null : itemLabel(current);
            final canOpen = enabled && !isLoading && items.isNotEmpty;

            Future<void> open() async {
              final picked = await showSearchablePicker<T>(
                context: context,
                title: title ?? hint ?? tr('select'),
                items: items,
                itemLabel: itemLabel,
                itemSubtitle: itemSubtitle,
                selected: current,
                isSelected: isSelected,
              );
              if (picked != null) {
                state.didChange(picked);
                onChanged(picked);
              }
            }

            final base = (decoration ?? const InputDecoration()).copyWith(
              errorText: state.errorText,
              hintText: decoration?.hintText ?? hint,
              suffixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : (decoration?.suffixIcon ?? const Icon(Icons.arrow_drop_down)),
            );

            return InkWell(
              onTap: canOpen ? open : null,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: base,
                isEmpty: label == null,
                child: label == null
                    ? null
                    : Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style ?? TextStyle(color: theme.getTextPrimaryColor())),
              ),
            );
          },
        );
}
