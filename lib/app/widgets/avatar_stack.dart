import 'package:flutter/material.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/models/project.dart';

class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.members,
    this.maxVisible = 4,
    this.size = 36,
  });

  final List<Member> members;
  final int maxVisible;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return _AvatarCircle(size: size, label: '?');
    }

    final visible = members.take(maxVisible).toList();
    final hasOverflow = members.length > visible.length;
    final overlap = size * 0.35;

    return SizedBox(
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: _AvatarCircle(size: size, member: visible[i]),
            ),
          if (hasOverflow)
            Positioned(
              left: visible.length * (size - overlap),
              child: _AvatarCircle(
                size: size,
                label: '+${members.length - visible.length}',
                isOverflow: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.size,
    this.member,
    this.label,
    this.isOverflow = false,
  });

  final double size;
  final Member? member;
  final String? label;
  final bool isOverflow;

  static const _gradient = LinearGradient(
    colors: [AppColors.secondary, AppColors.primary],
    begin: AlignmentDirectional(1.0, 0.34),
    end: AlignmentDirectional(-1.0, -0.34),
  );

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? _initialFor(member);
    final imageUrl = !isOverflow ? member?.avatarUrl : null;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: imageUrl == null ? _gradient : null,
          border: Border.all(color: AppColors.secondaryBackground, width: 2),
        ),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _InitialsLabel(label: displayLabel),
              )
            : _InitialsLabel(label: displayLabel),
      ),
    );
  }

  static String _initialFor(Member? member) {
    if (member == null) return '?';
    final trimmed = member.name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _InitialsLabel extends StatelessWidget {
  const _InitialsLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
