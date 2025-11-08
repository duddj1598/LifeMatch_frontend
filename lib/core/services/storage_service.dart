// lib/core/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'ACCESS_TOKEN', value: accessToken);
    await _storage.write(key: 'REFRESH_TOKEN', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'ACCESS_TOKEN');
  }

  Future<void> deleteAllTokens() async {
    await _storage.deleteAll();
  }
}