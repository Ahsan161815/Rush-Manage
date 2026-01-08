import 'package:myapp/models/industry.dart';

enum PlanQuotaType { projects, documents }

class PlanPackage {
  const PlanPackage({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.priceLabel,
    required this.highlights,
    this.maxProjects,
    this.maxDocuments,
    this.industry,
    this.isFree = false,
  });

  final String id;
  final String name;
  final String subtitle;
  final String priceLabel;
  final List<String> highlights;
  final int? maxProjects;
  final int? maxDocuments;
  final IndustryKey? industry;
  final bool isFree;

  bool get unlimitedProjects => maxProjects == null;
  bool get unlimitedDocuments => maxDocuments == null;
}

class PlanCatalog {
  static PlanPackage get generalFree => PlanPackage(
    id: 'general-free',
    name: 'Free workspace',
    subtitle: 'Test projects with core tools',
    priceLabel: 'Free',
    highlights: const [
      'Up to 2 active projects',
      'Up to 5 quotes + invoices',
      'Access to all generic features',
    ],
    maxProjects: 2,
    maxDocuments: 5,
    isFree: true,
  );

  static PlanPackage get generalPro => PlanPackage(
    id: 'general-pro',
    name: 'Pro workspace',
    subtitle: 'Unlimited growth for general teams',
    priceLabel: '9,99€ / month',
    highlights: const [
      'Unlimited projects',
      'Unlimited quotes + invoices',
      'Priority roadmap access',
    ],
  );

  static PlanPackage get catererPro => PlanPackage(
    id: 'caterer-pro',
    name: 'Caterer workspace',
    subtitle: 'Menus, tastings & kitchen coordination',
    priceLabel: '14,99€ / month',
    highlights: const [
      'Menu builder templates',
      'Guest + allergy tracking',
      'Kitchen & service workflows',
    ],
    industry: IndustryKey.caterer,
  );

  static List<PlanPackage> get generalPackages => [generalFree, generalPro];

  static List<PlanPackage> get addOnPackages => [catererPro];
}
