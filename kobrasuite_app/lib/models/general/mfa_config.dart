// lib/models/general/mfa_config.dart

class MFAConfig {
  final int id;
  final int userId;
  final bool mfaEnabled;
  final String? mfaType;
  final String? secretKey;

  MFAConfig({
    required this.id,
    required this.userId,
    required this.mfaEnabled,
    this.mfaType,
    this.secretKey,
  });

  factory MFAConfig.fromJson(Map<String, dynamic> json) {
    return MFAConfig(
      id: json['id'],
      userId: json['user'],
      mfaEnabled: json['mfa_enabled'],
      mfaType: json['mfa_type'],
      secretKey: json['secret_key'],
    );
  }
}