// lib/core/utils/url_fixer.dart

class UrlFixer {
  static const String _serverIp = '192.168.1.106:8000';
  
  static String? image(String? url) {
    if (url == null || url.isEmpty) return null;
    return url.replaceAll('127.0.0.1:8000', _serverIp);
  }
}