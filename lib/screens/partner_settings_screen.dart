import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../core/network/relationship_dto.dart';
import '../core/auth/auth_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/flexible_theme_system.dart';

/// Provider for partner relationships
final partnerRelationshipsProvider = FutureProvider<List<RelationshipDto>>((ref) async {
  final userId = AuthService.instance.getCurrentUserId();
  if (userId == null) return [];
  
  return await PartnerService.instance.getUserRelationships(userId);
});

/// Provider for current invite code
final inviteCodeProvider = StateProvider<String?>((ref) => null);

class PartnerSettingsScreen extends ConsumerStatefulWidget {
  const PartnerSettingsScreen({super.key});

  @override
  ConsumerState<PartnerSettingsScreen> createState() => _PartnerSettingsScreenState();
}

class _PartnerSettingsScreenState extends ConsumerState<PartnerSettingsScreen> {
  final Logger _logger = Logger();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
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

  Future<void> _linkPartner() async {
    final code = _inviteCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showSnackBar('Please enter an invite code', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final result = await PartnerService.instance.linkPartner(code);
      
      if (result.success) {
        _inviteCodeController.clear();
        _showSnackBar('Successfully linked to partner!', Colors.green);
        // Refresh relationships
        ref.invalidate(partnerRelationshipsProvider);
      } else {
        _showSnackBar(result.error ?? 'Failed to link partner', Colors.red);
      }
    } catch (e) {
      _logger.e('Error linking partner', error: e);
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
        title: const Text('Partner Settings'),
        backgroundColor: colors.draculaBackground,
        foregroundColor: colors.draculaForeground,
      ),
      backgroundColor: colors.backgroundDark,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        Text(
                          'Current Partners',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.draculaForeground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    relationships.when(
                      data: (partners) {
                        if (partners.isEmpty) {
                          return Text(
                            'No partners linked yet',
                            style: TextStyle(
                              color: colors.draculaComment,
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        }
                        
                        return Column(
                          children: partners.map((partner) => Card(
                            color: colors.backgroundDark,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(Icons.person, color: colors.completedBackground),
                              title: Text(
                                'Partner ${partner.partnerId?.substring(0, 8) ?? 'Unknown'}',
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
                          )).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text(
                        'Error loading partners: $error',
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Create Invite Code Section
            Card(
              color: colors.cardBackgroundDark,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.share, color: colors.primaryPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Share Invite Code',
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
                      'Create an invite code to share with someone you want to partner with.',
                      style: TextStyle(color: colors.draculaComment),
                    ),
                    const SizedBox(height: 16),
                    
                    if (currentInviteCode != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.primaryPurple.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentInviteCode,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primaryPurple,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _copyInviteCode(currentInviteCode),
                              icon: Icon(Icons.copy, color: colors.primaryPurple),
                              tooltip: 'Copy to clipboard',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createInviteCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: _isLoading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.add),
                      label: Text(_isLoading ? 'Creating...' : 'Create Invite Code'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Join Partner Section
            Card(
              color: colors.cardBackgroundDark,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, color: colors.completedBackground),
                        const SizedBox(width: 8),
                        Text(
                          'Join Partner',
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
                      'Enter an invite code from someone you want to partner with.',
                      style: TextStyle(color: colors.draculaComment),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _inviteCodeController,
                      style: TextStyle(color: colors.draculaForeground),
                      decoration: InputDecoration(
                        labelText: 'Invite Code',
                        labelStyle: TextStyle(color: colors.draculaComment),
                        hintText: 'Enter 6-character code',
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
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _linkPartner,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}