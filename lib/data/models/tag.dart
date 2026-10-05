import 'package:flutter/material.dart';

class Tag {
  final int? id;
  final String title;
  final Color color;
  final int? reminderId;
  final bool isDefault;

  Tag({
    this.id,
    required String title,
    this.color = Colors.white,
    this.reminderId,
    this.isDefault = false,
  }) : title = title.trim();

  factory Tag.fromMap(Map<String, dynamic> map) => Tag(
    id: map['id'] as int?,
    title: map['title'] as String,
    color: Color(map['color'] as int),
    reminderId: map['reminder_id'] as int?,
    isDefault: (map['is_default'] as int? ?? 0) == 1,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'color': color.toARGB32(),
    if (reminderId != null) 'reminder_id': reminderId,
    'is_default': isDefault ? 1 : 0,
  };
}
