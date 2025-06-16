import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../core/auth/username_auth_service.dart';
import '../core/network/partner_service.dart';
import '../core/theme/flexible_theme_system.dart';


/// Provider for partner relationships
final partnerRelationshipsProvider =
    FutureProvider<List<PartnerDto>>((ref) async {
  final logger = Logger();
  final userId = UsernameAuthService.instance.getCurrentUserId();
  logger.d('🔑 Current user ID: $userId');

  if (userId == null) {
    logger.w('⚠️ No authenticated user - cannot fetch relationships');
    return [];
  }

  logger.d('🚀 Fetching relationships for user: $userId');
  
  try {
    final partners = await PartnerService.instance.getPartners();
    logger.d('📦 Provider returning ${partners.length} partners');
    return partners;
  } catch (e) {
    logger.e('Error fetching partners', error: e);
    return [];
  }
});

/// Provider for current invite code
final inviteCodeProvider = StateProvider<String?>((ref) => null);

/// Provider for current username
final currentUsernameProvider = FutureProvider<String>((ref) async {
  final username = UsernameAuthService.instance.getCurrentUsername();
  return username ?? 'No username set';
});

class PartnerSettingsScreen extends ConsumerStatefulWidget {
  const PartnerSettingsScreen({super.key});

  @override
  ConsumerState<PartnerSettingsScreen> createState() =>
      _PartnerSettingsScreenState();
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
    // For username auth demo, just show current username info
    final currentUsername = UsernameAuthService.instance.getCurrentUsername();
    _showSnackBar('Current username: ${currentUsername ?? "Not set"}', Colors.blue);
  }

  Future<void> _createInviteCode() async {
    setState(() => _isLoading = true);

    try {
      final inviteCode = await PartnerService.instance.createInviteCode();
      ref.read(inviteCodeProvider.notifier).state = inviteCode;
      _showSnackBar('Invite code created: $inviteCode', Colors.green);
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
      _logger
          .d('🔗 Attempting to link partner with username: $partnerUsername');

      // Get current user info
      final currentUserId = UsernameAuthService.instance.getCurrentUserId();
      final currentUsername = UsernameAuthService.instance.getCurrentUsername();

      if (currentUserId == null || currentUsername == null) {
        _showSnackBar('Please sign in first', Colors.orange);
        setState(() => _isLoading = false);
        return;
      }

      if (partnerUsername.toLowerCase() == currentUsername.toLowerCase()) {
        _showSnackBar('Cannot link to yourself', Colors.orange);
        setState(() => _isLoading = false);
        return;
      }

      // Link partner via PartnerService
      await PartnerService.instance.linkPartner(partnerUsername);
      _partnerUsernameController.clear();
      _showSnackBar('Successfully linked to $partnerUsername!', Colors.green);
      
      // Force refresh relationships
      ref.invalidate(partnerRelationshipsProvider);
    } catch (e) {
      _logger.e('💥 Error linking partner', error: e);
      String errorMessage = 'Error linking partner';
      if (e.toString().contains('Partner username not found')) {
        errorMessage = 'Partner username not found';
      } else if (e.toString().contains('Already linked to this partner')) {
        errorMessage = 'Already linked to this partner';
      }
      _showSnackBar(errorMessage, Colors.red);
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

  void _showRemovePartnerDialog(PartnerDto partner) {
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
              _removePartner(partner.partnerId);
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

  Future<void> _removePartner(String partnerId) async {
    setState(() => _isLoading = true);

    try {
      await PartnerService.instance.removePartner(partnerId);
      _showSnackBar('Partner removed successfully', Colors.green);
      // Refresh relationships
      ref.invalidate(partnerRelationshipsProvider);
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
    ref.watch(inviteCodeProvider); // Keep provider active
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
                            Icon(Icons.people,
                                color: colors.completedBackground),
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
                              icon: Icon(Icons.refresh,
                                  color: colors.primaryPurple),
                              tooltip: 'Refresh partners',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        relationships.when(
                          data: (partners) {
                            _logger.d(
                                '🎨 UI rendering ${partners.length} partners');

                            if (partners.isEmpty) {
                              _logger.d(
                                  '📝 UI showing "No partners linked yet" message');
                              return Text(
                                'No partners linked yet.\nAdd a partner by entering their username below.',
                                style: TextStyle(
                                  color: colors.draculaComment,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }

                            _logger.d(
                                '📝 UI rendering partner list with ${partners.length} items');
                            return Column(
                              children: partners.map((partner) {
                                _logger.d(
                                    '🎨 Rendering partner: ${partner.id}');

                                String partnerDisplayName = partner.partnerUsername;

                                return Card(
                                  color: colors.backgroundDark,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Icon(Icons.person,
                                        color: colors.completedBackground),
                                    title: Text(
                                      partnerDisplayName,
                                      style: TextStyle(
                                          color: colors.draculaForeground),
                                    ),
                                    subtitle: Text(
                                      'Linked on ${partner.createdAt.day}/${partner.createdAt.month}/${partner.createdAt.year}',
                                      style: TextStyle(
                                          color: colors.draculaComment),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              _showRemovePartnerDialog(partner),
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
                            return const Center(
                                child: CircularProgressIndicator());
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
                            Icon(Icons.person_add,
                                color: colors.completedBackground),
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
                            hintStyle: TextStyle(
                                color: colors.draculaComment.withOpacity(0.7)),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: colors.draculaComment),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: colors.completedBackground),
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
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.link),
                          label:
                              Text(_isLoading ? 'Linking...' : 'Link Partner'),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: colors.primaryPurple.withOpacity(0.3)),
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
