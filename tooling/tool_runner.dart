import 'dart:io';
import 'gradle_patch.dart';

/// Main tool runner that executes various build-related patches and tools
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run tooling/tool_runner.dart <command>');
    print('Available commands:');
    print('  gradle-patch  - Patch Isar gradle files for Android build');
    print('  clean-android - Purge all Android build caches');
    print('  env-check     - Verify repo-local Flutter SDK usage');
    print('  android-build - Build fresh debug & release APKs');
    return;
  }

  final command = args[0];

  switch (command) {
    case 'gradle-patch':
      print('Running gradle patch...');
      await patchIsarGradleFile();
      break;
    case 'clean-android':
      await _cleanAndroid();
      break;
    case 'env-check':
      await _envCheck();
      break;
    case 'android-build':
      await _androidBuild();
      break;
    default:
      print('Unknown command: $command');
      print(
          'Available commands: gradle-patch, clean-android, env-check, android-build');
  }
}

/// Execute clean_android.sh script
Future<void> _cleanAndroid() async {
  print('🧹 Executing clean_android.sh...');

  final result = await Process.run(
    './tooling/clean_android.sh',
    [],
    workingDirectory: Directory.current.path,
  );

  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print('stderr: ${result.stderr}');
  }

  if (result.exitCode != 0) {
    throw Exception(
        'clean_android.sh failed with exit code ${result.exitCode}');
  }
}

/// Check Flutter SDK path and return working Flutter binary
Future<String> _envCheck() async {
  print('🔍 Checking Flutter SDK path...');

  final repoFlutter = '${Directory.current.path}/flutter/bin/flutter';

  // Check if repo-local Flutter exists
  if (File(repoFlutter).existsSync()) {
    print('✅ Using repo-local Flutter SDK: $repoFlutter');
    return repoFlutter;
  } else {
    // Fall back to system Flutter
    final result = await Process.run('which', ['flutter']);
    final systemFlutter = result.stdout.toString().trim();

    if (result.exitCode == 0 && systemFlutter.isNotEmpty) {
      print('⚠️  Using system Flutter: $systemFlutter');
      return systemFlutter;
    } else {
      throw Exception('No Flutter SDK found');
    }
  }
}

/// Build fresh debug and release APKs
Future<void> _androidBuild() async {
  print('🏗️  Building fresh Android APKs...');

  // Run pre-requisites
  final flutterBin = await _envCheck();
  await _cleanAndroid();

  // Update local.properties with correct Flutter SDK path
  print('⚙️  Updating local.properties...');
  final flutterSdkPath = File(flutterBin).parent.parent.path;
  final localPropsContent = '''flutter.sdk=$flutterSdkPath
sdk.dir=/Users/bridger/Library/Android/sdk
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1''';

  await File('android/local.properties').writeAsString(localPropsContent);

  // Get dependencies
  print('📦 Getting dependencies...');
  final pubGetResult = await Process.run(flutterBin, ['pub', 'get']);
  if (pubGetResult.exitCode != 0) {
    throw Exception('pub get failed: ${pubGetResult.stderr}');
  }

  // Build debug APK
  print('🔨 Building debug APK...');
  final debugResult = await Process.run(
    flutterBin,
    ['build', 'apk', '--debug', '--no-pub'],
  );

  print('Debug build output (last 20 lines):');
  final debugLines = debugResult.stdout.toString().split('\n');
  for (final line
      in debugLines.skip(debugLines.length > 20 ? debugLines.length - 20 : 0)) {
    if (line.trim().isNotEmpty) print(line);
  }

  if (debugResult.exitCode != 0) {
    print('❌ Debug build failed: ${debugResult.stderr}');
    throw Exception('Debug build failed');
  }

  // Build release APK
  print('🔨 Building release APK...');
  final releaseResult = await Process.run(
    flutterBin,
    ['build', 'apk', '--release', '--no-pub'],
  );

  print('Release build output (last 20 lines):');
  final releaseLines = releaseResult.stdout.toString().split('\n');
  for (final line in releaseLines
      .skip(releaseLines.length > 20 ? releaseLines.length - 20 : 0)) {
    if (line.trim().isNotEmpty) print(line);
  }

  if (releaseResult.exitCode != 0) {
    print('❌ Release build failed: ${releaseResult.stderr}');
    throw Exception('Release build failed');
  }

  print('✅ Both APKs built successfully');
}
