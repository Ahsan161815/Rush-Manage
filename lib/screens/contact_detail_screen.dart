import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/models/contact_detail_args.dart';

class ContactDetailScreen extends StatelessWidget {
  const ContactDetailScreen({super.key, required this.args});

  final ContactDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            FeatherIcons.chevronLeft,
            color: AppColors.secondaryText,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Contact detail',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Start chat',
            icon: const Icon(
              FeatherIcons.messageCircle,
              color: AppColors.secondaryText,
            ),
            onPressed: () => context.pushNamed('collaborationChat'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ContactHero(args: args),
              const SizedBox(height: 20),
              _InfoCard(
                title: 'Contact',
                children: [
                  if (args.email != null)
                    _InfoRow(
                      icon: FeatherIcons.mail,
                      label: 'Email',
                      value: args.email!,
                    ),
                  if (args.phone != null)
                    _InfoRow(
                      icon: FeatherIcons.phone,
                      label: 'Phone',
                      value: args.phone!,
                    ),
                  if (args.location != null)
                    _InfoRow(
                      icon: FeatherIcons.mapPin,
                      label: 'Location',
                      value: args.location!,
                    ),
                ],
              ),
              if (args.tags.isNotEmpty) ...[
                const SizedBox(height: 20),
                _InfoCard(
                  title: 'Expertise',
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: args.tags
                          .map((tag) => _TagChip(label: tag))
                          .toList(growable: false),
                    ),
                  ],
                ),
              ],
              if (args.projects.isNotEmpty) ...[
                const SizedBox(height: 20),
                _InfoCard(
                  title: 'Projects together',
                  children: args.projects
                      .map((project) => _ProjectTile(summary: project))
                      .toList(growable: false),
                ),
              ],
              if (args.note != null && args.note!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _InfoCard(
                  title: 'Notes',
                  children: [
                    Text(
                      args.note!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              GradientButton(
                onPressed: () => context.pushNamed('collaborationChat'),
                text: 'Send Message',
                width: double.infinity,
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactHero extends StatelessWidget {
  const _ContactHero({required this.args});

  final ContactDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: AlignmentDirectional(1.0, 0.34),
                end: AlignmentDirectional(-1.0, -0.34),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textfieldBackground,
                border: Border.all(
                  color: AppColors.textfieldBorder.withValues(alpha: 0.4),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                args.initials,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  args.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  args.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: AppColors.secondaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.summary});

  final ContactProjectSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: AlignmentDirectional(1.0, 0.34),
                end: AlignmentDirectional(-1.0, -0.34),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              summary.name.isNotEmpty ? summary.name[0].toUpperCase() : '?',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.role,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (summary.statusLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    summary.statusLabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.hintTextfiled.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            FeatherIcons.chevronRight,
            size: 18,
            color: AppColors.hintTextfiled,
          ),
        ],
      ),
    );
  }
}
