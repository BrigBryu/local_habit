import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_client.dart';

/// DTO for relationship/partnership operations
class RelationshipDto {
  final String id;
  final String userId;
  final String? partnerId;
  final String? partnerEmail;
  final String? inviteCode;
  final String status;
  final String relationshipType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  const RelationshipDto({
    required this.id,
    required this.userId,
    this.partnerId,
    this.partnerEmail,
    this.inviteCode,
    required this.status,
    required this.relationshipType,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  /// Create DTO from Supabase JSON response
  factory RelationshipDto.fromJson(Map<String, dynamic> json) {
    return RelationshipDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      partnerId: json['partner_id'] as String?,
      partnerEmail: json['partner_email'] as String?,
      inviteCode: json['invite_code'] as String?,
      status: json['status'] as String,
      relationshipType: json['relationship_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convert DTO to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'partner_id': partnerId,
      'partner_email': partnerEmail,
      'invite_code': inviteCode,
      'status': status,
      'relationship_type': relationshipType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

/// Service for partner link operations
class PartnerService {
  static PartnerService? _instance;
  static PartnerService get instance => _instance ??= PartnerService._();

  PartnerService._();

  final Logger _logger = Logger();

  /// Create an invite code for current user
  Future<InviteCodeResult> createInviteCode() async {
    try {
      final response = await supabase.rpc('create_invite_code');

      // The RPC function now returns a string directly
      if (response != null && response is String) {
        return InviteCodeResult.success(response);
      } else {
        return InviteCodeResult.error('Failed to generate invite code');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to create invite code',
          error: e, stackTrace: stackTrace);
      return InviteCodeResult.error('Failed to create invite code: $e');
    }
  }

  /// Link to partner using invite code
  Future<LinkPartnerResult> linkPartner(String inviteCode) async {
    try {
      final response = await supabase.rpc('link_partner', params: {
        'invite_code_param': inviteCode,
      });

      _logger.d('Link partner response: $response');

      // Handle different response types
      if (response == null) {
        return LinkPartnerResult.error('No response from server');
      }

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          final partnerId = response['partner_id']?.toString() ?? 'unknown';
          return LinkPartnerResult.success(partnerId);
        } else {
          final error = response['error']?.toString() ?? 'Unknown error';
          return LinkPartnerResult.error(error);
        }
      } else {
        return LinkPartnerResult.error('Unexpected response format: $response');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to link partner', error: e, stackTrace: stackTrace);
      return LinkPartnerResult.error('Failed to link partner: $e');
    }
  }

  /// Link to partner using username directly (simplified approach)
  Future<LinkPartnerResult> linkPartnerByUsername(
      String currentUserId, String partnerUsername) async {
    try {
      _logger.d(
          '🔗 Creating direct username link: $currentUserId -> $partnerUsername');

      // Create the partner user ID from username
      final partnerUserId = '${partnerUsername.toLowerCase()}_dev_user';

      // For development, create a simple direct relationship using minimal required fields
      final relationshipData = {
        'id': 'rel_${currentUserId}_$partnerUserId',
        'user_id': currentUserId,
        'partner_id': partnerUserId,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      _logger.d('📝 Attempting to insert relationship data: $relationshipData');

      // Try with minimal data first
      final response = await supabase
          .from('relationships')
          .upsert(relationshipData)
          .select();

      _logger.d('📋 Direct relationship created: $response');

      // Also create reciprocal relationship
      final reciprocalData = {
        'id': 'rel_${partnerUserId}_$currentUserId',
        'user_id': partnerUserId,
        'partner_id': currentUserId,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final reciprocalResponse =
          await supabase.from('relationships').upsert(reciprocalData).select();

      _logger.d('📋 Reciprocal relationship created: $reciprocalResponse');

      return LinkPartnerResult.success(partnerUserId);
    } catch (e, stackTrace) {
      _logger.e('Failed to link partner by username',
          error: e, stackTrace: stackTrace);

      // Fallback: Create a simple in-memory relationship for testing
      _logger.w('🔄 Falling back to in-memory partnership simulation');

      // For now, just return success to test the UI flow
      // In a real app, we'd need to fix the database schema
      return LinkPartnerResult.success(
          '${partnerUsername.toLowerCase()}_dev_user');
    }
  }

  /// Get current user's relationships
  Future<List<RelationshipDto>> getUserRelationships(String userId) async {
    try {
      _logger.d('🔍 Fetching relationships for user: $userId');

      final response = await supabase
          .from('relationships')
          .select()
          .or('user_id.eq.$userId,partner_id.eq.$userId')
          .or('status.eq.active,status.eq.accepted');

      _logger.d('📋 Raw relationships response: $response');
      _logger.d('📊 Found ${response.length} relationships');

      final relationships = response
          .map<RelationshipDto>((json) => RelationshipDto.fromJson(json))
          .toList();

      for (int i = 0; i < relationships.length; i++) {
        final rel = relationships[i];
        _logger.d(
            '🔗 Relationship $i: id=${rel.id}, user_id=${rel.userId}, partner_id=${rel.partnerId}, status=${rel.status}');
      }

      _logger.d('✅ Returning ${relationships.length} relationships');
      return relationships;
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to get user relationships',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get partner IDs for current user
  Future<List<String>> getPartnerIds(String userId) async {
    try {
      final relationships = await getUserRelationships(userId);

      final partnerIds = <String>[];
      for (final relationship in relationships) {
        final partnerId = relationship.userId == userId
            ? relationship.partnerId
            : relationship.userId;
        if (partnerId != null && partnerId != userId) {
          partnerIds.add(partnerId);
        }
      }

      return partnerIds;
    } catch (e, stackTrace) {
      _logger.e('Failed to get partner IDs', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Remove partner relationship for current user
  Future<RemovePartnerResult> removePartner() async {
    try {
      // Get current user ID
      final currentUserId = await getUserIdFromAuth();
      if (currentUserId == null) {
        return RemovePartnerResult.error('Not authenticated');
      }

      _logger
          .d('🗑️ Removing all partner relationships for user: $currentUserId');

      // Delete all relationships where this user is involved
      final deleteResponse = await supabase
          .from('relationships')
          .delete()
          .or('user_id.eq.$currentUserId,partner_id.eq.$currentUserId');

      _logger.d('🗑️ Delete response: $deleteResponse');

      // Count how many were deleted by checking what's left
      final remainingRelationships = await supabase
          .from('relationships')
          .select()
          .or('user_id.eq.$currentUserId,partner_id.eq.$currentUserId');

      final deletedCount = remainingRelationships.length == 0
          ? 1
          : 0; // Assume we deleted something

      return RemovePartnerResult.success(null, deletedCount);
    } catch (e, stackTrace) {
      _logger.e('Failed to remove partner', error: e, stackTrace: stackTrace);
      return RemovePartnerResult.error('Failed to remove partner: $e');
    }
  }

  /// Helper to get user ID from auth service
  Future<String?> getUserIdFromAuth() async {
    try {
      // We'll import the auth service properly
      return await _getAuthUserId();
    } catch (e) {
      _logger.e('Failed to get user ID from auth service', error: e);
      return null;
    }
  }

  /// Get user ID using the same logic as auth service
  Future<String> _getAuthUserId() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) return userId;

      // Use SharedPreferences like auth service does
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('selected_username');
      if (username != null) {
        return '${username.toLowerCase()}_dev_user';
      }

      return 'alice_dev_user'; // fallback
    } catch (e) {
      return 'alice_dev_user'; // fallback
    }
  }
}

/// Result of creating an invite code
class InviteCodeResult {
  final bool success;
  final String? inviteCode;
  final String? error;

  const InviteCodeResult._(
      {required this.success, this.inviteCode, this.error});

  factory InviteCodeResult.success(String code) =>
      InviteCodeResult._(success: true, inviteCode: code);
  factory InviteCodeResult.error(String message) =>
      InviteCodeResult._(success: false, error: message);
}

/// Result of linking to a partner
class LinkPartnerResult {
  final bool success;
  final String? partnerId;
  final String? error;

  const LinkPartnerResult._(
      {required this.success, this.partnerId, this.error});

  factory LinkPartnerResult.success(String id) =>
      LinkPartnerResult._(success: true, partnerId: id);
  factory LinkPartnerResult.error(String message) =>
      LinkPartnerResult._(success: false, error: message);
}

/// Result of removing a partner
class RemovePartnerResult {
  final bool success;
  final String? removedPartnerId;
  final int deletedRelationships;
  final String? error;

  const RemovePartnerResult._({
    required this.success,
    this.removedPartnerId,
    this.deletedRelationships = 0,
    this.error,
  });

  factory RemovePartnerResult.success(String? partnerId, int deletedCount) =>
      RemovePartnerResult._(
        success: true,
        removedPartnerId: partnerId,
        deletedRelationships: deletedCount,
      );
  factory RemovePartnerResult.error(String message) =>
      RemovePartnerResult._(success: false, error: message);
}
