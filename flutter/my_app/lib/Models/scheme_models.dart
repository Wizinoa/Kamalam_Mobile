class SchemeModel {
  final String id;

  /// Display code from the backend, e.g. "SCH-2026-0003".
  final String schemeCode;

  /// Backend `schema_type`: "daily" / "monthly" / "anytime".
  /// Old schemes may have "gold" / "silver" here.
  final String schemaType;

  final String assetType;

  /// "18k" / "22k" / "24k" for gold, null for silver.
  final String? purity;

  final String name;
  final String description;
  final int durationDays;
  final int durationMonths;
  final int minDailyDeposit;
  final int maxDailyDeposit;
  final int minTotalDeposit;
  final int lockInPeriod;
  final bool isActive;
  final bool joined;

  /// Null when the scheme has no maturity date (e.g. Anytime).
  final DateTime? maturityDate;

  SchemeModel({
    required this.id,
    required this.assetType,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.minDailyDeposit,
    required this.maxDailyDeposit,
    required this.minTotalDeposit,
    required this.lockInPeriod,
    required this.isActive,
    required this.joined,
    required this.maturityDate,
    this.schemeCode = '',
    this.schemaType = '',
    this.purity,
    this.durationMonths = 0,
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      id: _readId(json['_id']),
      schemeCode: (json['schemeId'] ?? '').toString(),
      schemaType: (json['schema_type'] ?? json['schemaType'] ?? '').toString(),
      assetType: (json['assetType'] ?? '').toString(),
      purity: json['purity']?.toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      durationDays: _readInt(json['durationDays']),
      durationMonths: _readInt(json['durationMonths']),
      minDailyDeposit: _readInt(json['minDailyDeposit']),
      maxDailyDeposit: _readInt(json['maxDailyDeposit']),
      minTotalDeposit: _readInt(json['minTotalDeposit']),
      lockInPeriod: _readInt(json['lockInPeriod']),
      isActive: json['isActive'] ?? false,
      joined: json['joined'] ?? false,
      maturityDate: _readDate(json['maturityDate']),
    );
  }

  static int _readInt(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  /// Accepts "abc123" or Mongo style {"$oid": "abc123"}.
  static String _readId(dynamic v) {
    if (v is Map) return (v['\$oid'] ?? '').toString();
    return (v ?? '').toString();
  }

  /// Accepts an ISO string or Mongo style {"$date": "..."}; null if missing.
  static DateTime? _readDate(dynamic v) {
    if (v == null) return null;
    final raw = v is Map ? v['\$date'] : v;
    return DateTime.tryParse(raw?.toString() ?? '');
  }
}