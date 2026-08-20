import 'package:hive/hive.dart';
import '../models/local_message.dart';

class PendingMessagesService {
  static const String _boxName = 'pending_messages';
  late Box<LocalMessage> _box;

  Future<void> init() async {
    _box = await Hive.openBox<LocalMessage>(_boxName);
  }

  Future<void> addMessage(LocalMessage message) async {
    await _box.put(message.clientUuid, message);
  }

  Future<void> removeMessage(String clientUuid) async {
    await _box.delete(clientUuid);
  }

  List<LocalMessage> getPendingMessages() {
    return _box.values.toList();
  }

  Future<void> updateStatus(String clientUuid, String newStatus) async {
    final message = _box.get(clientUuid);
    if (message != null) {
      await _box.put(clientUuid, message.copyWith(status: newStatus));
    }
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  bool hasPendingMessages() {
    return _box.isNotEmpty;
  }
}