import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../core/network/relationship_dto.dart';
import '../core/auth/auth_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/flexible_theme_system.dart';
import 'username_selection_screen.dart';

/// Provider for partner relationships
final partnerRelationshipsProvider = FutureProvider<List<RelationshipDto>>((ref) async {
  final logger = Logger();
  final userId = await AuthService.instance.getCurrentUserIdAsync();
  logger.d('🔑 Current user ID (async): $userId');
  
  // For testing: Create a hardcoded relationship between frank_dev_user and bob_dev_user
  if (userId == 'frank_dev_user') {
    logger.d('🎭 Test mode: Frank has Bob as partner');
    return [
      RelationshipDto(
        id: 'test_relationship_frank_bob',
        userId: 'frank_dev_user',
        partnerId: 'bob_dev_user',
        status: 'active',
        relationshipType: 'partner',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    ];
  } else if (userId == 'bob_dev_user') {
    logger.d('🎭 Test mode: Bob has Frank as partner');
    return [
      RelationshipDto(
        id: 'test_relationship_bob_frank',
        userId: 'bob_dev_user',
        partnerId: 'frank_dev_user',
        status: 'active',
        relationshipType: 'partner',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    ];
  }
  
  // Fallback to actual database lookup for other users
  logger.d('🚀 Fetching relationships for user: $userId');
  final allRelationships = await PartnerService.instance.getUserRelationships(userId);
  
  // Filter out relationships where the user is both user_id and partner_id (self-relationships)
  final validPartners = allRelationships.where((rel) {
    final isValidPartner = rel.partnerId != null && rel.partnerId != userId;
    logger.d('🔍 Checking relationship: ${rel.id}, user_id: ${rel.userId}, partner_id: ${rel.partnerId}, valid: $isValidPartner');
    return isValidPartner;
  }).toList();
  
  logger.d('📦 Provider returning ${validPartners.length} valid partners (filtered from ${allRelationships.length} total)');
  
  return validPartners;
});

/// Provider for current invite code
final inviteCodeProvider = StateProvider<String?>((ref) => null);

/// Provider for current username
final currentUsernameProvider = FutureProvider<String>((ref) async {
  return await AuthService.instance.getCurrentUserDisplayName();
});

class PartnerSettingsScreen extends ConsumerStatefulWidget {
  const PartnerSettingsScreen({super.key});

  @override
  ConsumerState<PartnerSettingsScreen> createState() => _PartnerSettingsScreenState();
}

class _PartnerSettingsScreenState extends ConsumerState<PartnerSettingsScreen> {
  final Logger _logger = Logger();
  final _partnerUsernameController = TextEditingController();
  bool _isLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Set up periodic refresh to catch updates from other devices
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _logger.d('🔄 Periodic refresh of partner relationships');
      ref.invalidate(partnerRelationshipsProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _partnerUsernameController.dispose();
    super.dispose();
  }

  Future<void> _showUsernameSelection() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const UsernameSelectionScreen(),
      ),
    );
    
    if (result != null) {
      // Refresh the username provider
      ref.invalidate(currentUsernameProvider);
      // Also refresh relationships in case the user ID changed
      ref.invalidate(partnerRelationshipsProvider);
      _showSnackBar('Username set to: $result', Colors.green);
    }
  }

  Future<void> _createInviteCode() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await PartnerService.instance.createInviteCode();
      
      if (result.success && result.inviteCode != null) {
        ref.read(inviteCodeProvider.notifier).state = result.inviteCode;
        _showSnackBar('Invite code created: ${result.inviteCode}', Colors.green);
      } else {
        _showSnackBar(result.error ?? 'Failed to create invite code', Colors.red);
      }
    } catch (e) {
      _logger.e('Error creating invite code', error: e);
      _showSnackBar('Error creating invite code', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _linkPartnerByUsername() async {
    final partnerUsername = _partnerUsernameController.text.trim();
    if (partnerUsername.isEmpty) {
      _showSnackBar('Please enter a partner username', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      _logger.d('🔗 Attempting to link partner with username: $partnerUsername');
      
      // Get current user info
      final currentUserId = await AuthService.instance.getCurrentUserIdAsync();
      final currentUsername = await AuthService.instance.getStoredUsername();
      
      if (currentUsername == null) {
        _showSnackBar('Please set your username first', Colors.orange);
        setState(() => _isLoading = false);
        return;
      }
      
      if (partnerUsername.toLowerCase() == currentUsername.toLowerCase()) {
        _showSnackBar('Cannot link to yourself', Colors.orange);
        setState(() => _isLoading = false);
        return;
      }
      
      // Check if user already has a partner (one-partner limit)
      final existingRelationships = await PartnerService.instance.getUserRelationships(currentUserId);
      final validPartners = existingRelationships.where((rel) => 
        rel.partnerId != null && rel.partnerId != currentUserId
      ).toList();
      
      if (validPartners.isNotEmpty) {
        final existingPartnerName = validPartners.first.partnerId!
            .replaceAll('_dev_user', '')
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
        _showSnackBar('You can only have one partner. Currently linked to: $existingPartnerName', Colors.orange);
        setState(() => _isLoading = false);
        return;
      }
      
      // Create the partner relationship directly
      final result = await PartnerService.instance.linkPartnerByUsername(currentUserId, partnerUsername);
      
      if (result.success) {
        _logger.d('✅ Partner linking successful! Partner: $partnerUsername');
        _partnerUsernameController.clear();
        _showSnackBar('Successfully linked to $partnerUsername!', Colors.green);
        
        // Force refresh relationships
        _logger.d('🔄 Invalidating partnerRelationshipsProvider to refresh UI');
        ref.invalidate(partnerRelationshipsProvider);
        
        // Wait a moment then check if relationships loaded
        await Future.delayed(Duration(seconds: 2));
        final newRelationships = await PartnerService.instance.getUserRelationships(currentUserId);
        final newValidPartners = newRelationships.where((rel) => 
          rel.partnerId != null && rel.partnerId != currentUserId
        ).toList();
        _logger.d('🔍 After link check: Found ${newValidPartners.length} valid partners');
        
        if (newValidPartners.isEmpty) {
          _logger.w('⚠️ WARNING: No partners found after successful link!');
          _showSnackBar('Link successful but UI not updating - check logs', Colors.orange);
        } else {
          _logger.d('✅ Partners found after link, UI should update');
        }
      } else {
        _logger.e('❌ Partner linking failed: ${result.error}');
        _showSnackBar(result.error ?? 'Failed to link partner', Colors.red);
      }
    } catch (e) {
      _logger.e('💥 Error linking partner', error: e);
      _showSnackBar('Error linking partner', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRemovePartnerDialog(RelationshipDto partner) {
    final colors = ref.read(flexibleColorsProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.cardBackgroundDark,
        title: Text(
          'Remove Partner',
          style: TextStyle(color: colors.draculaForeground),
        ),
        content: Text(
          'Are you sure you want to remove this partner? This will disconnect your habit tracking.',
          style: TextStyle(color: colors.draculaComment),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.draculaComment),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removePartner();
            },
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _removePartner() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await PartnerService.instance.removePartner();
      
      if (result.success) {
        _showSnackBar('Partner removed successfully', Colors.green);
        // Refresh relationships
        ref.invalidate(partnerRelationshipsProvider);
      } else {
        _showSnackBar(result.error ?? 'Failed to remove partner', Colors.red);
      }
    } catch (e) {
      _logger.e('Error removing partner', error: e);
      _showSnackBar('Error removing partner', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    _showSnackBar('Invite code copied to clipboard', Colors.blue);
  }

  @override
  Widget build(BuildContext context) {
    final relationships = ref.watch(partnerRelationshipsProvider);
    final currentInviteCode = ref.watch(inviteCodeProvider);
    final colors = ref.watchColors;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Partner Settings'),
            Consumer(
              builder: (context, ref, child) {
                final usernameAsync = ref.watch(currentUsernameProvider);
                return usernameAsync.when(
                  data: (username) => Row(
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.draculaComment,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showUsernameSelection,
                        child: Icon(
                          Icons.edit,
                          size: 14,
                          color: colors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                  loading: () => Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.draculaComment,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  error: (error, stack) => GestureDetector(
                    onTap: _showUsernameSelection,
                    child: Text(
                      'Set Username',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.primaryPurple,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: colors.draculaBackground,
        foregroundColor: colors.draculaForeground,
      ),
      backgroundColor: colors.backgroundDark,
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: () async {
          _logger.d('🔄 Pull-to-refresh triggered');
          ref.invalidate(partnerRelationshipsProvider);
          // Wait a bit for the refresh to complete
          await Future.delayed(Duration(seconds: 1));
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Current Partners Section
            Card(
              color: colors.cardBackgroundDark,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, color: colors.completedBackground),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Current Partners',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.draculaForeground,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _logger.d('🔄 Manual refresh triggered');
                            ref.invalidate(partnerRelationshipsProvider);
                          },
                          icon: Icon(Icons.refresh, color: colors.primaryPurple),
                          tooltip: 'Refresh partners',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    relationships.when(
                      data: (partners) {
                        _logger.d('🎨 UI rendering ${partners.length} partners');
                        
                        if (partners.isEmpty) {
                          _logger.d('📝 UI showing "No partners linked yet" message');
                          return Text(
                            'No partners linked yet (check auth)',
                            style: TextStyle(
                              color: colors.draculaComment,
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        }
                        
                        _logger.d('📝 UI rendering partner list with ${partners.length} items');
                        return Column(
                          children: partners.map((partner) {
                            _logger.d('🎨 Rendering partner: ${partner.id} (${partner.status})');
                            
                            // Extract username from partner ID
                            String partnerDisplayName = 'Unknown Partner';
                            if (partner.partnerId != null) {
                              if (partner.partnerId!.endsWith('_dev_user')) {
                                // Extract username from dev user ID
                                partnerDisplayName = partner.partnerId!
                                    .replaceAll('_dev_user', '')
                                    .split('_')
                                    .map((word) => word[0].toUpperCase() + word.substring(1))
                                    .join(' ');
                              } else {
                                partnerDisplayName = partner.partnerId!.substring(0, 8);
                              }
                            }
                            
                            return Card(
                              color: colors.backgroundDark,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(Icons.person, color: colors.completedBackground),
                                title: Text(
                                  partnerDisplayName,
                                  style: TextStyle(color: colors.draculaForeground),
                                ),
                                subtitle: Text(
                                  'Status: ${partner.status}',
                                  style: TextStyle(color: colors.draculaComment),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Chip(
                                      label: Text(partner.relationshipType),
                                      backgroundColor: colors.completedBackground.withOpacity(0.2),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _showRemovePartnerDialog(partner),
                                      icon: const Icon(Icons.remove_circle),
                                      color: Colors.red,
                                      tooltip: 'Remove Partner',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () {
                        _logger.d('⏳ UI showing loading indicator');
                        return const Center(child: CircularProgressIndicator());
                      },
                      error: (error, stack) {
                        _logger.e('💥 UI showing error: $error');
                        return Text(
                          'Error loading partners: $error',
                          style: TextStyle(color: colors.error),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Link Partner by Username Section
            Card(
              color: colors.cardBackgroundDark,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_add, color: colors.completedBackground),
                        const SizedBox(width: 8),
                        Text(
                          'Link Partner',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.draculaForeground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter the username of someone you want to partner with.',
                      style: TextStyle(color: colors.draculaComment),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _partnerUsernameController,
                      style: TextStyle(color: colors.draculaForeground),
                      decoration: InputDecoration(
                        labelText: 'Partner Username',
                        labelStyle: TextStyle(color: colors.draculaComment),
                        hintText: 'e.g. Alice, Bob, Charlie',
                        hintStyle: TextStyle(color: colors.draculaComment.withOpacity(0.7)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colors.draculaComment),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colors.completedBackground),
                        ),
                        filled: true,
                        fillColor: colors.backgroundDark,
                      ),
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty && !_isLoading) {
                          _linkPartnerByUsername();
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _linkPartnerByUsername,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.completedBackground,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: _isLoading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.link),
                      label: Text(_isLoading ? 'Linking...' : 'Link Partner'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.primaryPurple.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 How it works:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.primaryPurple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Simply enter your partner\'s username (like "Alice" or "Bob") to connect. Both of you will see each other in your partner lists.',
                            style: TextStyle(color: colors.draculaComment),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}