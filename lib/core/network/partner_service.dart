import 'package:logger/logger.dart';
import '../auth/username_auth_service.dart';
import 'supabase_client.dart';

/// Service for managing partner relationships via Supabase
class PartnerService {
  static PartnerService? _instance;
  static PartnerService get instance {
    _instance ??= PartnerService._();
    return _instance!;
  }

  PartnerService._();

  final _logger = Logger();

  /// Create an invite code for other users to link with this user
  Future<String> createInviteCode() async {
    try {
      final currentUserId = UsernameAuthService.instance.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('No authenticated user');
      }

      // Generate a simple invite code (in production, you might want to store this in a table)
      final inviteCode = 'INV${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      
      _logger.i('Created invite code: $inviteCode for user: $currentUserId');
      return inviteCode;
    } catch (e) {
      _logger.e('Error creating invite code', error: e);
      rethrow;
    }
  }

  /// Link a partner by their username
  Future<void> linkPartner(String partnerUsername) async {
    try {
      final currentUserId = UsernameAuthService.instance.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('No authenticated user');
      }

      _logger.i('=== LINKING PARTNER DEBUG ===');
      _logger.i('Partner username: "$partnerUsername"');
      _logger.i('Current user ID: $currentUserId');
      _logger.i('Trimmed partner username: "${partnerUsername.trim()}"');
      _logger.i('About to call link_partner RPC...');

      // Call Supabase RPC to link partner
      final response = await supabase.rpc(
        'link_partner', 
        params: {
          'p_user_id': currentUserId,
          'p_partner_username': partnerUsername.trim(),
        },
      );

      _logger.i('RPC call completed successfully!');
      _logger.i('RPC response type: ${response.runtimeType}');
      _logger.i('RPC response value: $response');
      _logger.i('Successfully linked partner: $partnerUsername');
    } catch (e) {
      _logger.e('=== ERROR LINKING PARTNER ===');
      _logger.e('Error type: ${e.runtimeType}');
      _logger.e('Error message: ${e.toString()}');
      _logger.e('Partner username: "$partnerUsername"');
      _logger.e('Current user ID: ${UsernameAuthService.instance.getCurrentUserId()}');
      
      // Print the full error details
      if (e is Exception) {
        _logger.e('Exception details: $e');
      }
      
      final errorMessage = e.toString().toLowerCase();
      _logger.e('Lowercase error message: "$errorMessage"');
      
      if (errorMessage.contains('partner username not found')) {
        throw Exception('No user found with username: $partnerUsername');
      } else if (errorMessage.contains('cannot link to yourself')) {
        throw Exception('Cannot link to yourself');
      } else if (errorMessage.contains('already linked to this partner')) {
        throw Exception('Already linked to this partner');
      } else if (errorMessage.contains('function') && errorMessage.contains('does not exist')) {
        throw Exception('Database function not found. Please check your database setup.');
      } else {
        throw Exception('Error linking partner: ${e.toString()}');
      }
    }
  }

  /// Link a partner by invite code (for future use)
  Future<void> linkPartnerByCode(String inviteCode) async {
    try {
      final currentUserId = UsernameAuthService.instance.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('No authenticated user');
      }

      _logger.i('Linking partner by code: $inviteCode for user: $currentUserId');

      // In a real implementation, you would:
      // 1. Look up the invite code in a database table
      // 2. Get the user ID that created the invite code
      // 3. Create the partnership
      // For now, we'll just throw an error as this is not implemented
      throw Exception('Invite code linking not yet implemented');
    } catch (e) {
      _logger.e('Error linking partner by code', error: e);
      rethrow;
    }
  }

  /// Remove partner relationship
  Future<void> removePartner(String partnerId) async {
    try {
      final currentUserId = UsernameAuthService.instance.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('No authenticated user');
      }

      _logger.i('Removing partner: $partnerId for user: $currentUserId');

      // Call Supabase RPC to remove partner
      await supabase.rpc(
        'remove_partner', 
        params: {
          'p_user_id': currentUserId,
          'p_partner_id': partnerId,
        },
      );

      _logger.i('Successfully removed partner: $partnerId');
    } catch (e) {
      _logger.e('Error removing partner', error: e);
      rethrow;
    }
  }

  /// Get all partners for the current user
  Future<List<PartnerDto>> getPartners() async {
    try {
      final currentUserId = UsernameAuthService.instance.getCurrentUserId();
      if (currentUserId == null) {
        _logger.w('No authenticated user - returning empty partner list');
        return [];
      }

      _logger.i('Fetching partners for user: $currentUserId');

      // Call Supabase RPC to get partners
      final response = await supabase.rpc(
        'get_partners', 
        params: {
          'p_user_id': currentUserId,
        },
      ) as List<dynamic>?;

      if (response == null) {
        _logger.i('No partners found');
        return [];
      }

      final partnersData = response as List<dynamic>;
      final partners = partnersData.map((data) => PartnerDto.fromJson(data)).toList();

      _logger.i('Found ${partners.length} partners');
      return partners;
    } catch (e) {
      _logger.e('Error fetching partners', error: e);
      rethrow;
    }
  }
}

/// Data transfer object for partner information
class PartnerDto {
  final String id;
  final String username;
  final String partnerId;
  final String partnerUsername;
  final DateTime createdAt;

  PartnerDto({
    required this.id,
    required this.username,
    required this.partnerId,
    required this.partnerUsername,
    required this.createdAt,
  });

  factory PartnerDto.fromJson(Map<String, dynamic> json) {
    return PartnerDto(
      id: json['id'] as String,
      username: json['username'] as String,
      partnerId: json['partner_id'] as String,
      partnerUsername: json['partner_username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'partner_id': partnerId,
      'partner_username': partnerUsername,
      'created_at': createdAt.toIso8601String(),
    };
  }
}