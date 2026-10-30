import 'dart:typed_data';
import 'package:http/http.dart' as http;

class SupabaseStorageService {
  static const String supabaseUrl = 'https://gqtgxquzgjdrvdraiytg.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxdGd4cXV6Z2pkcnZkcmFpeXRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI2NTE2ODYsImV4cCI6MjEwODIyNzY4Nn0.GjcOb5_wPVnure2Gkbg9W6S5O9nRXHH4vMgpvV_a51k';
  static const String bucketName = 'avatars';

  static Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) async {
    final url = Uri.parse('$supabaseUrl/storage/v1/object/$bucketName/$fileName');

    final response = await http.post(
      url,
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': mimeType,
        'x-upsert': 'true', // Overwrite if already exists
      },
      body: bytes,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return '$supabaseUrl/storage/v1/object/public/$bucketName/$fileName';
    } else {
      throw Exception('Supabase upload failed (${response.statusCode}): ${response.body}');
    }
  }
}

