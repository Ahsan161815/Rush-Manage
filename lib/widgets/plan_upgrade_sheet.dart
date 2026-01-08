import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/plan_package.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';

Future<bool> showPlanUpgradeSheet(
  BuildContext context, {
  required PlanQuotaType quotaType,
}) async {
  final userController = context.read<UserController?>();
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => PlanUpgradeSheet(
      quotaType: quotaType,
      generalPackages: PlanCatalog.generalPackages,
      addOnPackages: PlanCatalog.addOnPackages,
      onTrialPressed: () async {
        await userController?.activateProTrial();
      },
    ),
  );
  return result ?? false;
}

class PlanUpgradeSheet extends StatefulWidget {
  const PlanUpgradeSheet({
    super.key,
    required this.quotaType,
    required this.generalPackages,
    required this.addOnPackages,
    this.onTrialPressed,
  });

  final PlanQuotaType quotaType;
  final List<PlanPackage> generalPackages;
  final List<PlanPackage> addOnPackages;
  final Future<void> Function()? onTrialPressed;

  @override
  State<PlanUpgradeSheet> createState() => _PlanUpgradeSheetState();
}

class _PlanUpgradeSheetState extends State<PlanUpgradeSheet> {
  bool _isProcessing = false;

  String _title(AppLocalizations loc) {
    return switch (widget.quotaType) {
      PlanQuotaType.projects => loc.planUpgradeProjectsTitle,
      PlanQuotaType.documents => loc.planUpgradeDocumentsTitle,
    };
  }

  String _body(AppLocalizations loc) {
    return switch (widget.quotaType) {
      PlanQuotaType.projects => loc.planUpgradeProjectsDescription,
      PlanQuotaType.documents => loc.planUpgradeDocumentsDescription,
    };
  }

  Future<void> _handleTrial() async {
    if (_isProcessing || widget.onTrialPressed == null) {
      return;
    }
    setState(() => _isProcessing = true);
    try {
      await widget.onTrialPressed!.call();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final allPackages = <PlanPackageSection>[
      PlanPackageSection(
        title: loc.planUpgradeGeneralHeading,
        packages: widget.generalPackages,
      ),
      if (widget.addOnPackages.isNotEmpty)
        PlanPackageSection(
          title: loc.planUpgradeAddOnHeading,
          packages: widget.addOnPackages,
        ),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              Text(
                _title(loc),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _body(loc),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              for (final section in allPackages) _PlanSection(section: section),
              const SizedBox(height: 24),
              GradientButton(
                onPressed: _handleTrial,
                text: loc.planUpgradeTrialCta,
                height: 52,
                width: double.infinity,
                isLoading: _isProcessing,
              ),
              const SizedBox(height: 12),
              Text(
                loc.planUpgradeTrialFooter,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlanPackageSection {
  const PlanPackageSection({required this.title, required this.packages});

  final String title;
  final List<PlanPackage> packages;
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({required this.section});

  final PlanPackageSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (final plan in section.packages) _PlanPackageCard(plan: plan),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _PlanPackageCard extends StatelessWidget {
  const _PlanPackageCard({required this.plan});

  final PlanPackage plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.isFree ? AppColors.textfieldBorder : AppColors.secondary,
          width: 1.4,
        ),
        color: AppColors.textfieldBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            plan.priceLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: plan.isFree
                  ? AppColors.secondaryText
                  : AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          for (final highlight in plan.highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
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
