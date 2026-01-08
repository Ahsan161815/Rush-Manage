import 'package:equatable/equatable.dart';

typedef JsonMap = Map<String, dynamic>;

enum IndustryKey { core, caterer }

extension IndustryKeyMapper on IndustryKey {
  String get storageValue => switch (this) {
    IndustryKey.core => 'core',
    IndustryKey.caterer => 'caterer',
  };

  static IndustryKey fromStorage(String? value) {
    return IndustryKey.values.firstWhere(
      (entry) => entry.storageValue == value,
      orElse: () => IndustryKey.core,
    );
  }
}

class IndustryProfile extends Equatable {
  const IndustryProfile({
    required this.industry,
    this.isReferenceIndustry = false,
    this.activatedAt,
  });

  const IndustryProfile.core()
    : industry = IndustryKey.core,
      isReferenceIndustry = false,
      activatedAt = null;

  final IndustryKey industry;
  final bool isReferenceIndustry;
  final DateTime? activatedAt;

  IndustryProfile copyWith({
    IndustryKey? industry,
    bool? isReferenceIndustry,
    DateTime? activatedAt,
  }) {
    return IndustryProfile(
      industry: industry ?? this.industry,
      isReferenceIndustry: isReferenceIndustry ?? this.isReferenceIndustry,
      activatedAt: activatedAt ?? this.activatedAt,
    );
  }

  factory IndustryProfile.fromJson(JsonMap json) => IndustryProfile(
    industry: IndustryKeyMapper.fromStorage(json['industry'] as String?),
    isReferenceIndustry: json['is_reference'] as bool? ?? false,
    activatedAt: _parseDate(json['activated_at']),
  );

  JsonMap toJson() => {
    'industry': industry.storageValue,
    'is_reference': isReferenceIndustry,
    'activated_at': activatedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [industry, isReferenceIndustry, activatedAt];
}

abstract class ProjectIndustryExtension extends Equatable {
  const ProjectIndustryExtension();

  IndustryKey get industry;
  bool get hasData;
  JsonMap toJson();
}

class CatererProjectExtension extends ProjectIndustryExtension {
  const CatererProjectExtension({
    this.guestCount,
    this.menuStyle,
    this.allergyNotes,
    this.serviceStyle,
    this.requiresTasting = false,
    this.tastingDate,
    this.requiresOnsiteKitchen = false,
    this.kitchenNotes,
  });

  final int? guestCount;
  final String? menuStyle;
  final String? allergyNotes;
  final String? serviceStyle;
  final bool requiresTasting;
  final DateTime? tastingDate;
  final bool requiresOnsiteKitchen;
  final String? kitchenNotes;

  CatererProjectExtension copyWith({
    int? guestCount,
    String? menuStyle,
    String? allergyNotes,
    String? serviceStyle,
    bool? requiresTasting,
    DateTime? tastingDate,
    bool? requiresOnsiteKitchen,
    String? kitchenNotes,
  }) {
    return CatererProjectExtension(
      guestCount: guestCount ?? this.guestCount,
      menuStyle: menuStyle ?? this.menuStyle,
      allergyNotes: allergyNotes ?? this.allergyNotes,
      serviceStyle: serviceStyle ?? this.serviceStyle,
      requiresTasting: requiresTasting ?? this.requiresTasting,
      tastingDate: tastingDate ?? this.tastingDate,
      requiresOnsiteKitchen:
          requiresOnsiteKitchen ?? this.requiresOnsiteKitchen,
      kitchenNotes: kitchenNotes ?? this.kitchenNotes,
    );
  }

  factory CatererProjectExtension.fromJson(JsonMap json) {
    return CatererProjectExtension(
      guestCount: (json['guest_count'] as num?)?.toInt(),
      menuStyle: json['menu_style'] as String?,
      allergyNotes: json['allergy_notes'] as String?,
      serviceStyle: json['service_style'] as String?,
      requiresTasting: json['requires_tasting'] as bool? ?? false,
      tastingDate: _parseDate(json['tasting_date']),
      requiresOnsiteKitchen: json['requires_onsite_kitchen'] as bool? ?? false,
      kitchenNotes: json['kitchen_notes'] as String?,
    );
  }

  @override
  IndustryKey get industry => IndustryKey.caterer;

  @override
  bool get hasData {
    return guestCount != null ||
        (menuStyle != null && menuStyle!.trim().isNotEmpty) ||
        (allergyNotes != null && allergyNotes!.trim().isNotEmpty) ||
        (serviceStyle != null && serviceStyle!.trim().isNotEmpty) ||
        requiresTasting ||
        tastingDate != null ||
        requiresOnsiteKitchen ||
        (kitchenNotes != null && kitchenNotes!.trim().isNotEmpty);
  }

  @override
  JsonMap toJson() => {
    if (guestCount != null) 'guest_count': guestCount,
    if (menuStyle != null && menuStyle!.trim().isNotEmpty)
      'menu_style': menuStyle,
    if (allergyNotes != null && allergyNotes!.trim().isNotEmpty)
      'allergy_notes': allergyNotes,
    if (serviceStyle != null && serviceStyle!.trim().isNotEmpty)
      'service_style': serviceStyle,
    if (requiresTasting) 'requires_tasting': true,
    if (tastingDate != null) 'tasting_date': tastingDate!.toIso8601String(),
    if (requiresOnsiteKitchen) 'requires_onsite_kitchen': true,
    if (kitchenNotes != null && kitchenNotes!.trim().isNotEmpty)
      'kitchen_notes': kitchenNotes,
  };

  @override
  List<Object?> get props => [
    guestCount,
    menuStyle,
    allergyNotes,
    serviceStyle,
    requiresTasting,
    tastingDate,
    requiresOnsiteKitchen,
    kitchenNotes,
  ];
}

ProjectIndustryExtension? projectExtensionFromRecord(JsonMap record) {
  final payload = record['payload'];
  if (payload is! Map<String, dynamic>) {
    return null;
  }
  final industry = IndustryKeyMapper.fromStorage(record['industry'] as String?);
  switch (industry) {
    case IndustryKey.core:
      return null;
    case IndustryKey.caterer:
      return CatererProjectExtension.fromJson(payload);
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
