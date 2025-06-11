import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../core/network/relationship_dto.dart';
import '../core/auth/auth_service.dart';
import '../core/theme/app_colors.dart';

/// Provider for partner relationships
final partnerRelationshipsProvider = FutureProvider<List<RelationshipDto>>((ref) async {
  final userId = AuthService.instance.getCurrentUserId();
  if (userId == null) return [];
  
  return await PartnerService.instance.getUserRelationships(userId);
});

/// Provider for current invite code
final inviteCodeProvider = StateProvider<String?>((ref) => null);

class PartnerSettingsScreen extends ConsumerStatefulWidget {
  const PartnerSettingsScreen({Key? key}) : super(key: key);

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
      ),
    );
  }

  Future<void> _copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    _showSnackBar('Invite code copied to clipboard', Colors.blue);
  }

  @override
  Widget build(BuildContext context) {
    final relationships = ref.watch(partnerRelationshipsProvider);
    final currentInviteCode = ref.watch(inviteCodeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Settings'),
        backgroundColor: AppColors.draculaBackground,
        foregroundColor: AppColors.draculaForeground,
      ),
      backgroundColor: AppColors.backgroundDark,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Partners Section
            Card(
              color: AppColors.cardBackgroundDark,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, color: AppColors.completedBackground),
                        const SizedBox(width: 8),
                        Text(
                          'Current Partners',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.draculaForeground,
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
                              color: AppColors.draculaComment,
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        }
                        
                        return Column(
                          children: partners.map((partner) => ListTile(
                            leading: Icon(Icons.person, color: AppColors.completedBackground),
                            title: Text(
                              'Partner ${partner.partnerId?.substring(0, 8) ?? 'Unknown'}',
                              style: TextStyle(color: AppColors.draculaForeground),
                            ),
                            subtitle: Text(
                              'Status: ${partner.status}',
                              style: TextStyle(color: AppColors.draculaComment),
                            ),
                            trailing: Chip(
                              label: Text(partner.relationshipType),
                              backgroundColor: AppColors.completedBackground.withOpacity(0.2),
                            ),
                          )).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text(
                        'Error loading partners: $error',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Create Invite Code Section
            Card(
              color: AppColors.cardBackgroundDark,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.share, color: AppColors.primaryPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Share Invite Code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.draculaForeground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create an invite code to share with someone you want to partner with.',
                      style: TextStyle(color: AppColors.draculaComment),
                    ),
                    const SizedBox(height: 16),
                    
                    if (currentInviteCode != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentInviteCode,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryPurple,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _copyInviteCode(currentInviteCode),
                              icon: Icon(Icons.copy, color: AppColors.primaryPurple),
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
                        backgroundColor: AppColors.primaryPurple,
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
              color: AppColors.cardBackgroundDark,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, color: AppColors.completedBackground),
                        const SizedBox(width: 8),
                        Text(
                          'Join Partner',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.draculaForeground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter an invite code from someone you want to partner with.',
                      style: TextStyle(color: AppColors.draculaComment),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _inviteCodeController,
                      style: TextStyle(color: AppColors.draculaForeground),
                      decoration: InputDecoration(
                        labelText: 'Invite Code',
                        labelStyle: TextStyle(color: AppColors.draculaComment),
                        hintText: 'Enter 6-character code',
                        hintStyle: TextStyle(color: AppColors.draculaComment.withOpacity(0.7)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.draculaComment),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.completedBackground),
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundDark,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _linkPartner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.completedBackground,
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