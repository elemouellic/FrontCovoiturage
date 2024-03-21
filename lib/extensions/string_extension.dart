// lib/extensions/string_extension.dart

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String capitalizeEachWord() {
    return split(' ')
        .map((word) => word.capitalize())
        .join(' ');
  }
}