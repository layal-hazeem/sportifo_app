// lib/core/utils/url_fixer.dart

class UrlFixer {
  static const String _serverIp = 'sportifo-dev.duckdns.org';  // ← بدّل
  
  static String? image(String? url) {
    if (url == null || url.isEmpty) return null;
    return url.replaceAll('127.0.0.1:8000', _serverIp)
              .replaceAll('192.168.1.106:8000', _serverIp);  // ← أضف هاد السطر كمان
  }
}