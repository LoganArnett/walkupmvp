import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service for backend sync
class SupabaseService {
  static SupabaseClient? _client;

  /// Initialize Supabase with URL and anon key
  /// Call this before using the client
  static Future<void> init({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Get the Supabase client instance
  /// Throws if not initialized
  static SupabaseClient get client {
    if (_client == null) {
      throw StateError(
        'SupabaseService not initialized. Call SupabaseService.init() first.',
      );
    }
    return _client!;
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;

  /// Get current user
  static User? get currentUser => _client?.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
