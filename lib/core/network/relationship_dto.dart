import 'package:logger/logger.dart';
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
      
      if (response['success'] == true) {
        return InviteCodeResult.success(response['invite_code'] as String);
      } else {
        return InviteCodeResult.error(response['error'] as String? ?? 'Unknown error');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to create invite code', error: e, stackTrace: stackTrace);
      return InviteCodeResult.error('Failed to create invite code: $e');
    }
  }
  
  /// Link to partner using invite code
  Future<LinkPartnerResult> linkPartner(String inviteCode) async {
    try {
      final response = await supabase.rpc('link_partner', params: {
        'invite_code_param': inviteCode,
      });
      
      if (response['success'] == true) {
        return LinkPartnerResult.success(response['partner_id'] as String);
      } else {
        return LinkPartnerResult.error(response['error'] as String? ?? 'Unknown error');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to link partner', error: e, stackTrace: stackTrace);
      return LinkPartnerResult.error('Failed to link partner: $e');
    }
  }
  
  /// Get current user's relationships
  Future<List<RelationshipDto>> getUserRelationships(String userId) async {
    try {
      final response = await supabase
          .from('relationships')
          .select()
          .or('user_id.eq.$userId,partner_id.eq.$userId')
          .eq('status', 'accepted');
      
      return response.map<RelationshipDto>((json) => RelationshipDto.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get user relationships', error: e, stackTrace: stackTrace);
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
}

/// Result of creating an invite code
class InviteCodeResult {
  final bool success;
  final String? inviteCode;
  final String? error;
  
  const InviteCodeResult._({required this.success, this.inviteCode, this.error});
  
  factory InviteCodeResult.success(String code) => InviteCodeResult._(success: true, inviteCode: code);
  factory InviteCodeResult.error(String message) => InviteCodeResult._(success: false, error: message);
}

/// Result of linking to a partner
class LinkPartnerResult {
  final bool success;
  final String? partnerId;
  final String? error;
  
  const LinkPartnerResult._({required this.success, this.partnerId, this.error});
  
  factory LinkPartnerResult.success(String id) => LinkPartnerResult._(success: true, partnerId: id);
  factory LinkPartnerResult.error(String message) => LinkPartnerResult._(success: false, error: message);
}

