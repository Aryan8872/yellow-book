import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InboxEntry {
  final String id;
  final String messageId;
  final String title;
  final String body;
  final DateTime receivedAt;
  final Map<String, dynamic>? data;
  bool read;

  InboxEntry({
    required this.id,
    required this.messageId,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.data,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'messageId': messageId,
    'title': title,
    'body': body,
    'receivedAt': receivedAt.toIso8601String(),
    'data': data,
    'read': read,
  };

  factory InboxEntry.fromJson(Map<String, dynamic> json) => InboxEntry(
    id: json['id'] as String,
    messageId: json['messageId'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    receivedAt: DateTime.parse(json['receivedAt'] as String),
    data: json['data'] as Map<String, dynamic>?,
    read: json['read'] as bool? ?? false,
  );
}

/// Service for managing notification inbox with secure storage persistence.
/// Uses read-modify-write pattern with dedupe by messageId and 50-item cap.
class NotificationInboxService {
  static const _storageKey = 'notifications_inbox';
  static const _maxItems = 50;

  final FlutterSecureStorage _secureStorage;

  NotificationInboxService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  /// Reads all inbox entries from secure storage.
  Future<List<InboxEntry>> read() async {
    try {
      final json = await _secureStorage.read(key: _storageKey);
      if (json == null || json.isEmpty) return [];

      final List<dynamic> list = jsonDecode(json);
      return list
          .map((e) => InboxEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Adds a new notification to the inbox with dedupe by messageId.
  /// Performs read-modify-write with newest-first insertion and 50-item cap.
  void onMessage({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    required DateTime receivedAt,
    required String messageId,
  }) {
    // Generate unique ID
    final id = '${receivedAt.millisecondsSinceEpoch}_$messageId';

    // Read current entries
    read().then((entries) {
      // Dedupe: remove existing entry with same messageId
      final filtered = entries.where((e) => e.messageId != messageId).toList();

      // Create new entry
      final newEntry = InboxEntry(
        id: id,
        messageId: messageId,
        title: title,
        body: body,
        receivedAt: receivedAt,
        data: data,
        read: false,
      );

      // Insert newest-first
      final updated = [newEntry, ...filtered];

      // Cap at 50 items
      final capped = updated.take(_maxItems).toList();

      // Write back to storage (fire and forget)
      final json = jsonEncode(capped.map((e) => e.toJson()).toList());
      _secureStorage.write(key: _storageKey, value: json).catchError((_) {});
    });
  }

  /// Marks specific entries as read by their IDs.
  void markRead(List<String> ids) {
    read().then((entries) {
      final updated = entries.map((e) {
        if (ids.contains(e.id)) {
          return InboxEntry(
            id: e.id,
            messageId: e.messageId,
            title: e.title,
            body: e.body,
            receivedAt: e.receivedAt,
            data: e.data,
            read: true,
          );
        }
        return e;
      }).toList();

      final json = jsonEncode(updated.map((e) => e.toJson()).toList());
      _secureStorage.write(key: _storageKey, value: json).catchError((_) {});
    });
  }

  /// Marks a single entry as read by its ID.
  void markSingleRead(String id) {
    markRead([id]);
  }

  /// Marks all entries as read.
  void markAllRead() {
    read().then((entries) {
      final updated = entries.map((e) => InboxEntry(
        id: e.id,
        messageId: e.messageId,
        title: e.title,
        body: e.body,
        receivedAt: e.receivedAt,
        data: e.data,
        read: true,
      )).toList();

      final json = jsonEncode(updated.map((e) => e.toJson()).toList());
      _secureStorage.write(key: _storageKey, value: json).catchError((_) {});
    });
  }

  /// Returns the count of unread notifications.
  Future<int> unreadCount() async {
    final entries = await read();
    return entries.where((e) => !e.read).length;
  }

  /// Clears all notifications from the inbox.
  void clear() {
    _secureStorage.delete(key: _storageKey).catchError((_) {});
  }
}
