import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:myapp/app/app_theme.dart';

class AppFormTextField extends StatelessWidget {
  const AppFormTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.enabled,
  });

  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    final field = Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textfieldBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        textInputAction: textInputAction,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (labelText == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText!,
          style:
              Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ) ??
              const TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.value,
    this.labelBuilder,
    this.compact = false,
  });

  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String hintText;
  final T? value;
  final String Function(T value)? labelBuilder;
  final bool compact;

  String _resolveLabel(T item) => labelBuilder?.call(item) ?? item.toString();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null;
    final displayLabel = hasValue ? _resolveLabel(value as T) : hintText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final menuWidth = availableWidth.isFinite && availableWidth > 0
            ? availableWidth
            : null;

        return PopupMenuButton<T>(
          tooltip: '',
          initialValue: value,
          color: AppColors.secondaryBackground,
          elevation: 6,
          offset: Offset(0, compact ? 6 : 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          constraints: menuWidth != null
              ? BoxConstraints.tightFor(width: menuWidth)
              : const BoxConstraints(minWidth: 200, maxWidth: 340),
          onSelected: onChanged,
          itemBuilder: (context) {
            return items
                .map(
                  (item) => PopupMenuItem<T>(
                    value: item,
                    height: compact ? 36 : 44,
                    child: Text(
                      _resolveLabel(item),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: compact ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasValue
                    ? AppColors.textfieldBorder.withValues(alpha: 0.6)
                    : AppColors.textfieldBorder,
                width: hasValue ? 1.4 : 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasValue
                          ? AppColors.secondaryText
                          : AppColors.hintTextfiled,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  FeatherIcons.chevronDown,
                  color: AppColors.secondaryText,
                  size: compact ? 16 : 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.onTap,
    required this.hasValue,
    this.icon = FeatherIcons.calendar,
    this.leading,
  });

  final String label;
  final VoidCallback onTap;
  final bool hasValue;
  final IconData icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasValue ? AppColors.primary : AppColors.textfieldBorder,
            width: hasValue ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            leading ?? Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: hasValue
                      ? AppColors.secondaryText
                      : AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
