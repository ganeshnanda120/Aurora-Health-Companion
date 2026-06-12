import 'package:flutter/services.dart';

class SpecialNameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    int i = 0;
    while (i < text.length) {
      if (text[i] == ' ') {
        buffer.write(' ');
        i++;
      } else {
        final start = i;
        while (i < text.length && text[i] != ' ') {
          i++;
        }
        final word = text.substring(start, i);
        buffer.write(_formatWord(word));
      }
    }
    
    final formatted = buffer.toString();
    
    int selectionIndex = newValue.selection.end;
    if (selectionIndex > formatted.length) {
      selectionIndex = formatted.length;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  static String _formatWord(String word) {
    if (word.isEmpty) return "";
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  // Static helper to format an entire string (e.g. on load or save)
  static String formatName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "";
    
    final buffer = StringBuffer();
    int i = 0;
    while (i < trimmed.length) {
      if (trimmed[i] == ' ') {
        buffer.write(' ');
        i++;
      } else {
        final start = i;
        while (i < trimmed.length && trimmed[i] != ' ') {
          i++;
        }
        final word = trimmed.substring(start, i);
        buffer.write(_formatWord(word));
      }
    }
    return buffer.toString();
  }
}
