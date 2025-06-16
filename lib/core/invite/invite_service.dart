import 'dart:math';
import 'package:logger/logger.dart';
import '../network/supabase_client.dart';
import '../auth/auth_service.dart';

/// Service for managing partner invite codes
class InviteService {
  static InviteService? _instance;
  static InviteService get instance => _instance ??= InviteService._();

  InviteService._();

  final Logger _logger = Logger();

  /// Generate a 6-character alphanumeric invite code
  String generateInviteCode() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  /// Create a new invite code for the current user
  Future<InviteResult> createInviteCode() async {
    try {
      final userId = await AuthService.instance.getCurrentUserIdAsync();
      if (userId == null) {
        return InviteResult.error('Not authenticated');
      }

      // Generate unique code (retry if collision)
      String inviteCode;
      bool isUnique = false;
      int attempts = 0;

      do {
        inviteCode = generateInviteCode();
        attempts++;

        // Check if code already exists
        final existing = await supabase
            .from('invite_codes')
            .select('id')
            .eq('code', inviteCode)
            .limit(1);

        isUnique = existing.isEmpty;

        if (attempts > 10) {
          return InviteResult.error('Failed to generate unique invite code');
        }
      } while (!isUnique);

      // Insert new invite code
      final response = await supabase
          .from('invite_codes')
          .insert({
            'code': inviteCode,
            'created_by': userId,
            'expires_at':
                DateTime.now().add(const Duration(days: 7)).toIso8601String(),
            'is_used': false,
          })
          .select()
          .single();

      _logger.i('Created invite code: $inviteCode for user: $userId');
      return InviteResult.success(inviteCode);
    } catch (e, stackTrace) {
      _logger.e('Failed to create invite code',
          error: e, stackTrace: stackTrace);
      return InviteResult.error('Failed to create invite code: $e');
    }
  }

  /// Accept an invite code and create partnership
  Future<AcceptInviteResult> acceptInviteCode(String inviteCode) async {
    try {
      final userId = await AuthService.instance.getCurrentUserIdAsync();
      if (userId == null) {
        return AcceptInviteResult.error('Not authenticated');
      }

      // Validate invite code format
      if (inviteCode.length != 6 ||
          !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(inviteCode)) {
        return AcceptInviteResult.error('Invalid invite code format');
      }

      // Find the invite code
      final inviteResponse = await supabase
          .from('invite_codes')
          .select('id, code, created_by, expires_at, is_used')
          .eq('code', inviteCode.toUpperCase())
          .eq('is_used', false)
          .limit(1);

      if (inviteResponse.isEmpty) {
        return AcceptInviteResult.error(
            'Invite code not found or already used');
      }

      final invite = inviteResponse.first;
      final inviteCreator = invite['created_by'] as String;
      final expiresAt = DateTime.parse(invite['expires_at'] as String);

      // Check if expired
      if (DateTime.now().isAfter(expiresAt)) {
        return AcceptInviteResult.error('Invite code has expired');
      }

      // Check if trying to accept own invite
      if (inviteCreator == userId) {
        return AcceptInviteResult.error('Cannot accept your own invite code');
      }

      // Check if users are already partners
      final existingRelationship = await supabase
          .from('relationships')
          .select('id')
          .or('user_id_1.eq.$userId,user_id_2.eq.$userId')
          .or('user_id_1.eq.$inviteCreator,user_id_2.eq.$inviteCreator')
          .limit(1);

      if (existingRelationship.isNotEmpty) {
        return AcceptInviteResult.error(
            'You are already partners with this user');
      }

      // Create the partnership
      final relationshipData = {
        'user_id_1': userId,
        'user_id_2': inviteCreator,
        'status': 'active',
        'relationship_type': 'partner',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('relationships').insert(relationshipData);

      // Mark invite code as used
      await supabase.from('invite_codes').update({
        'is_used': true,
        'used_by': userId,
        'used_at': DateTime.now().toIso8601String()
      }).eq('id', invite['id']);

      _logger.i(
          'Successfully accepted invite code: $inviteCode, partnership created between $userId and $inviteCreator');
      return AcceptInviteResult.success(inviteCreator);
    } catch (e, stackTrace) {
      _logger.e('Failed to accept invite code',
          error: e, stackTrace: stackTrace);
      return AcceptInviteResult.error('Failed to accept invite: $e');
    }
  }

  /// Get current user's active invite codes
  Future<List<InviteCodeInfo>> getUserInviteCodes() async {
    try {
      final userId = await AuthService.instance.getCurrentUserIdAsync();
      if (userId == null) {
        return [];
      }

      final response = await supabase
          .from('invite_codes')
          .select('code, created_at, expires_at, is_used, used_at, used_by')
          .eq('created_by', userId)
          .order('created_at', ascending: false);

      return response
          .map<InviteCodeInfo>((json) => InviteCodeInfo.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get user invite codes',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Delete expired invite codes (cleanup)
  Future<void> cleanupExpiredInvites() async {
    try {
      await supabase
          .from('invite_codes')
          .delete()
          .lt('expires_at', DateTime.now().toIso8601String());

      _logger.d('Cleaned up expired invite codes');
    } catch (e, stackTrace) {
      _logger.e('Failed to cleanup expired invites',
          error: e, stackTrace: stackTrace);
    }
  }
}

/// Information about an invite code
class InviteCodeInfo {
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;
  final DateTime? usedAt;
  final String? usedBy;

  const InviteCodeInfo({
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    required this.isUsed,
    this.usedAt,
    this.usedBy,
  });

  factory InviteCodeInfo.fromJson(Map<String, dynamic> json) {
    return InviteCodeInfo(
      code: json['code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isUsed: json['is_used'] as bool,
      usedAt: json['used_at'] != null
          ? DateTime.parse(json['used_at'] as String)
          : null,
      usedBy: json['used_by'] as String?,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isUsed && !isExpired;
}

/// Result of creating an invite code
class InviteResult {
  final bool isSuccess;
  final String? inviteCode;
  final String? error;

  const InviteResult._(this.isSuccess, this.inviteCode, this.error);

  factory InviteResult.success(String code) => InviteResult._(true, code, null);
  factory InviteResult.error(String message) =>
      InviteResult._(false, null, message);
}

/// Result of accepting an invite code
class AcceptInviteResult {
  final bool isSuccess;
  final String? partnerId;
  final String? error;

  const AcceptInviteResult._(this.isSuccess, this.partnerId, this.error);

  factory AcceptInviteResult.success(String partnerId) =>
      AcceptInviteResult._(true, partnerId, null);
  factory AcceptInviteResult.error(String message) =>
      AcceptInviteResult._(false, null, message);
}
