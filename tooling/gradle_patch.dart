import 'dart:io';
import 'package:path/path.dart' as path;

/// Patches the Isar Flutter libs gradle and manifest files to fix Android build issues
/// This fixes the Android build error where namespace is required but missing
/// and removes deprecated package attribute from AndroidManifest.xml
Future<void> patchIsarGradleFile() async {
  try {
    // Find the pub cache directory
    String? homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (homeDir == null) {
      print('Could not determine home directory');
      return;
    }
    
    final pubCacheDir = path.join(homeDir, '.pub-cache', 'hosted', 'pub.dev');
    final pubCacheDirectory = Directory(pubCacheDir);
    
    if (!pubCacheDirectory.existsSync()) {
      print('Pub cache directory not found: $pubCacheDir');
      return;
    }
    
    // Find isar_flutter_libs directories
    final isarDirs = pubCacheDirectory
        .listSync()
        .where((entity) => entity is Directory && entity.path.contains('isar_flutter_libs'))
        .cast<Directory>()
        .toList();
    
    if (isarDirs.isEmpty) {
      print('No isar_flutter_libs directories found in pub cache');
      return;
    }
    
    bool anyPatched = false;
    
    for (final isarDir in isarDirs) {
      final gradleFile = File(path.join(isarDir.path, 'android', 'build.gradle'));
      
      if (!gradleFile.existsSync()) {
        continue;
      }
      
      final content = gradleFile.readAsStringSync();
      
      // Check if already patched
      if (content.contains('namespace "dev.isar.flutter_libs"')) {
        print('Gradle file already patched: ${gradleFile.path}');
        continue;
      }
      
      // Find the android { block and add namespace
      final lines = content.split('\n');
      final patchedLines = <String>[];
      bool foundAndroidBlock = false;
      bool patched = false;
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        patchedLines.add(line);
        
        if (line.trim().startsWith('android {') && !foundAndroidBlock) {
          foundAndroidBlock = true;
          // Add namespace after the android { line
          patchedLines.add('  namespace "dev.isar.flutter_libs"');
          patched = true;
        }
      }
      
      if (patched) {
        gradleFile.writeAsStringSync(patchedLines.join('\n'));
        print('Patched gradle file: ${gradleFile.path}');
        anyPatched = true;
      } else {
        print('Could not find android block in: ${gradleFile.path}');
      }
    }
    
    if (anyPatched) {
      print('Gradle patch completed successfully');
    } else {
      print('No gradle files needed patching');
    }
    
    // Now patch AndroidManifest.xml files
    await patchIsarManifestFiles();
    
  } catch (e, stackTrace) {
    print('Error patching gradle file: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Patches AndroidManifest.xml files to remove deprecated package attribute
Future<void> patchIsarManifestFiles() async {
  try {
    String? homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (homeDir == null) {
      print('Could not determine home directory for manifest patch');
      return;
    }
    
    final pubCacheDir = path.join(homeDir, '.pub-cache', 'hosted', 'pub.dev');
    final pubCacheDirectory = Directory(pubCacheDir);
    
    if (!pubCacheDirectory.existsSync()) {
      print('Pub cache directory not found for manifest patch: $pubCacheDir');
      return;
    }
    
    // Find isar_flutter_libs directories
    final isarDirs = pubCacheDirectory
        .listSync()
        .where((entity) => entity is Directory && entity.path.contains('isar_flutter_libs'))
        .cast<Directory>()
        .toList();
    
    if (isarDirs.isEmpty) {
      print('No isar_flutter_libs directories found for manifest patch');
      return;
    }
    
    bool anyPatched = false;
    
    for (final isarDir in isarDirs) {
      final manifestFile = File(path.join(isarDir.path, 'android', 'src', 'main', 'AndroidManifest.xml'));
      
      if (!manifestFile.existsSync()) {
        continue;
      }
      
      final content = manifestFile.readAsStringSync();
      
      // Check if already patched
      if (!content.contains('package=')) {
        print('Manifest file already patched: ${manifestFile.path}');
        continue;
      }
      
      // Remove package attribute from manifest tag
      final patchedContent = content.replaceAll(RegExp(r'\s*package="[^"]*"'), '');
      
      if (patchedContent != content) {
        manifestFile.writeAsStringSync(patchedContent);
        print('Patched manifest file: ${manifestFile.path}');
        anyPatched = true;
      }
    }
    
    if (anyPatched) {
      print('Manifest patch completed successfully');
    } else {
      print('No manifest files needed patching');
    }
    
  } catch (e, stackTrace) {
    print('Error patching manifest files: $e');
    print('Stack trace: $stackTrace');
  }
}

void main() async {
  await patchIsarGradleFile();
}