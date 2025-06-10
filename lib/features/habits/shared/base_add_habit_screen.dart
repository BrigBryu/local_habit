import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/flexible_theme_system.dart';

/// Base class for all add habit screens providing common functionality
/// for name/description fields, validation, and UI patterns
abstract class BaseAddHabitScreen extends ConsumerStatefulWidget {
  const BaseAddHabitScreen({super.key});
}

abstract class BaseAddHabitScreenState<T extends BaseAddHabitScreen> extends ConsumerState<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  /// Override this to provide the app bar title
  String get screenTitle;

  /// Override this to provide custom validation for the name field
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a habit name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    return null;
  }

  /// Override this to provide custom validation for the description field
  String? validateDescription(String? value) {
    if (value != null && value.length > 200) {
      return 'Description cannot exceed 200 characters';
    }
    return null;
  }

  /// Override this to provide the name field label
  String get nameFieldLabel => 'Habit Name';

  /// Override this to provide the name field hint
  String get nameFieldHint => 'Enter habit name';

  /// Override this to provide the description field label
  String get descriptionFieldLabel => 'Description (Optional)';

  /// Override this to provide the description field hint
  String get descriptionFieldHint => 'Why is this habit important to you?';

  /// Override this to provide the save button text
  String get saveButtonText => 'Add Habit';

  /// Override this to provide the current habit type for the dropdown
  HabitType get currentHabitType;

  /// Override this to provide the current route for the dropdown
  String get currentRoute;

  /// Override this to customize whether to show the habit type selector
  bool get showHabitTypeSelector => true;

  /// Override this to provide custom content between name/description and save button
  Widget buildCustomContent(BuildContext context) {
    return const SizedBox.shrink();
  }

  /// Override this to provide tips or help content at the bottom
  Widget buildTipsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            ref.watchColors.draculaCurrentLine.withOpacity(0.6),
            ref.watchColors.draculaCurrentLine.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: ref.watchColors.draculaYellow.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: ref.watchColors.draculaYellow),
                const SizedBox(width: 8),
                Text(
                  'Tips for Great Habits',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ref.watchColors.draculaYellow,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Be specific: "Read 10 pages" vs "Read more"\n'
              '• Start small: Build consistency before intensity\n'
              '• Make it enjoyable: Choose habits you actually want to do',
              style: TextStyle(
                fontSize: 14,
                color: ref.watchColors.draculaForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Override this to implement the save logic
  Future<void> performSave();

  /// Override this to provide custom success message
  String getSuccessMessage() {
    return 'Added habit: ${nameController.text.trim()}';
  }

  /// Handle habit type selection and navigation
  void _onHabitTypeChanged(String? newRoute) {
    if (newRoute == null || newRoute == currentRoute) return;
    navigateToHabitType(newRoute);
  }
  
  /// Navigate to habit type - override this in concrete implementations to handle routing
  void navigateToHabitType(String route) {
    // Default implementation - each concrete screen should override this
    // to navigate to the correct screen type
    _showComingSoon('Navigation');
  }

  /// Show coming soon dialog for unimplemented habit types
  void _showComingSoon(String habitTypeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$habitTypeName Coming Soon'),
        content: Text('$habitTypeName creation will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Build the habit type selector dropdown
  Widget _buildHabitTypeDropdown(BuildContext context) {
    final colors = ref.watchColors;
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: '/add-basic-habit', child: Text('Basic')),
      const DropdownMenuItem(value: '/add-bundle-habit', child: Text('Bundle')),
      const DropdownMenuItem(value: '/add-avoidance-habit', child: Text('Avoidance')),
      // 🚧 add more here when new types arrive
    ];

    return DropdownButtonFormField<String>(
      value: currentRoute,
      items: items,
      onChanged: _onHabitTypeChanged,
      style: TextStyle(color: colors.draculaPurple),
      dropdownColor: colors.draculaCurrentLine,
      decoration: InputDecoration(
        labelText: 'Habit type',
        labelStyle: TextStyle(color: colors.basicHabit),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colors.basicHabit, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.basicHabit, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.draculaPink, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        backgroundColor: ref.watchColors.draculaCurrentLine,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header text
                      Text(
                        'Create a new habit to track daily',
                        style: TextStyle(
                          fontSize: 16,
                          color: ref.watchColors.formFieldLabel,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Form fields container with outline
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ref.watchColors.formFieldBorder.withOpacity(0.3),
                            width: 2,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              ref.watchColors.draculaCurrentLine.withOpacity(0.2),
                              ref.watchColors.draculaCurrentLine.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Habit type selector
                            if (showHabitTypeSelector) ...[
                              _buildHabitTypeDropdown(context),
                              const SizedBox(height: 16),
                              Divider(color: ref.watchColors.draculaComment.withOpacity(0.3)),
                              const SizedBox(height: 16),
                            ],

                            // Name field
                            TextFormField(
                              controller: nameController,
                              style: TextStyle(color: ref.watchColors.draculaPurple),
                              decoration: InputDecoration(
                                labelText: nameFieldLabel,
                                labelStyle: TextStyle(color: ref.watchColors.formFieldLabel),
                                hintText: nameFieldHint,
                                hintStyle: TextStyle(color: ref.watchColors.draculaComment),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: ref.watchColors.formFieldBorder, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ref.watchColors.formFieldBorder, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ref.watchColors.draculaPink, width: 2),
                                ),
                                prefixIcon: Icon(Icons.check_circle_outline, color: ref.watchColors.formFieldBorder),
                              ),
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.sentences,
                              validator: validateName,
                              enabled: !isLoading,
                              onChanged: (_) => setState(() {}), // For dynamic validation
                            ),
                            const SizedBox(height: 16),

                            // Description field
                            TextFormField(
                              controller: descriptionController,
                              style: TextStyle(color: ref.watchColors.draculaPurple),
                              decoration: InputDecoration(
                                labelText: descriptionFieldLabel,
                                labelStyle: TextStyle(color: ref.watchColors.formFieldLabel),
                                hintText: descriptionFieldHint,
                                hintStyle: TextStyle(color: ref.watchColors.draculaComment),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: ref.watchColors.formFieldBorder, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ref.watchColors.formFieldBorder, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ref.watchColors.draculaPink, width: 2),
                                ),
                                prefixIcon: Icon(Icons.description_outlined, color: ref.watchColors.formFieldBorder),
                              ),
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 3,
                              maxLength: 200,
                              validator: validateDescription,
                              enabled: !isLoading,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Custom content (for specific habit types)
                      buildCustomContent(context),

                      const SizedBox(height: 24),

                      // Tips section
                      buildTipsSection(context),
                    ],
                  ),
                ),
              ),

              // Action buttons at bottom
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ref.watchColors.draculaComment),
                        foregroundColor: ref.watchColors.draculaComment,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading || !canSave() ? null : _saveHabit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ref.watchColors.draculaPink,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: ref.watchColors.draculaComment,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(saveButtonText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Override this to provide custom save validation
  bool canSave() {
    return nameController.text.trim().isNotEmpty;
  }

  Future<void> _saveHabit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await performSave();

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getSuccessMessage()),
            backgroundColor: ref.read(flexibleColorsProvider).success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ref.read(flexibleColorsProvider).error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}