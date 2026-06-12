import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String avatarId;
  final double radius;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    required this.avatarId,
    this.radius = 24.0,
    this.onTap,
  });

  static final Map<String, AvatarData> avatarMap = {
    'avatar1': AvatarData(emoji: '🦊', label: 'Firefox', color: Colors.orangeAccent),
    'avatar2': AvatarData(emoji: '🐼', label: 'Panda', color: Colors.tealAccent),
    'avatar3': AvatarData(emoji: '🐯', label: 'Tiger', color: Colors.amberAccent),
    'avatar4': AvatarData(emoji: '🐨', label: 'Koala', color: Colors.blueAccent),
    'avatar5': AvatarData(emoji: '🦁', label: 'Lion', color: Colors.pinkAccent),
    'avatar6': AvatarData(emoji: '🦄', label: 'Unicorn', color: Colors.purpleAccent),
  };

  @override
  Widget build(BuildContext context) {
    final isCustom = !avatarId.startsWith('avatar');
    
    if (isCustom) {
      Uint8List? bytes;
      try {
        String base64Str = avatarId;
        if (avatarId.contains(',')) {
          base64Str = avatarId.split(',').last;
        }
        bytes = base64Decode(base64Str.trim());
      } catch (e) {
        // Decode failed
      }

      if (bytes != null) {
        Widget avatar = Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.tealAccent.withOpacity(0.6),
              width: 2.0,
            ),
            image: DecorationImage(
              image: MemoryImage(bytes),
              fit: BoxFit.cover,
            ),
          ),
        );

        if (onTap != null) {
          return GestureDetector(
            onTap: onTap,
            child: avatar,
          );
        }
        return avatar;
      }
    }

    final data = avatarMap[avatarId] ?? avatarMap['avatar1']!;
    
    Widget avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            data.color.withOpacity(0.4),
            data.color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: data.color.withOpacity(0.6),
          width: 2.0,
        ),
      ),
      child: Center(
        child: Text(
          data.emoji,
          style: TextStyle(
            fontSize: radius * 1.0,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }
    return avatar;
  }
}

class AvatarData {
  final String emoji;
  final String label;
  final Color color;

  AvatarData({
    required this.emoji,
    required this.label,
    required this.color,
  });
}
