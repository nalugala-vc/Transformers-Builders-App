/// Keep in sync with [version] in pubspec.yaml.
abstract final class AppVersion {
  AppVersion._();

  static const String name = '1.0.0';
  static const String build = '1';

  static String get label => 'Version $name ($build)';
}
