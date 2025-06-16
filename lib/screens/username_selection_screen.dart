import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/flexible_theme_system.dart';

class UsernameSelectionScreen extends ConsumerStatefulWidget {
  const UsernameSelectionScreen({super.key});

  @override
  ConsumerState<UsernameSelectionScreen> createState() =>
      _UsernameSelectionScreenState();
}

class _UsernameSelectionScreenState
    extends ConsumerState<UsernameSelectionScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  final List<String> _presetUsernames = [
    'Alice',
    'Bob',
    'Charlie',
    'Diana',
    'Eve',
    'Frank',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveUsername(String username) async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_username', username);

      if (mounted) {
        Navigator.of(context).pop(username);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving username: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watchColors;

    return Scaffold(
      backgroundColor: colors.backgroundDark,
      appBar: AppBar(
        title: const Text('Choose Your Username'),
        backgroundColor: colors.draculaBackground,
        foregroundColor: colors.draculaForeground,
        automaticallyImplyLeading: false, // No back button
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a username for testing:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.draculaForeground,
                ),
              ),

              const SizedBox(height: 20),

              // Preset username buttons
              Text(
                'Quick Select:',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.draculaComment,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetUsernames
                    .map((username) => ElevatedButton(
                          onPressed:
                              _isLoading ? null : () => _saveUsername(username),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primaryPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(username),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 32),

              // Custom username input
              Text(
                'Or enter custom username:',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.draculaComment,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _controller,
                style: TextStyle(color: colors.draculaForeground),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: colors.draculaComment),
                  hintText: 'Enter your username',
                  hintStyle:
                      TextStyle(color: colors.draculaComment.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors.draculaComment),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors.primaryPurple),
                  ),
                  filled: true,
                  fillColor: colors.cardBackgroundDark,
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _saveUsername(value.trim());
                  }
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _controller.text.trim().isEmpty
                      ? null
                      : () => _saveUsername(_controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.completedBackground,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('Save Username'),
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: colors.primaryPurple.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Testing Tip:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose different usernames on each device to test partner linking between Alice & Bob, or any other combination.',
                      style: TextStyle(color: colors.draculaComment),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
