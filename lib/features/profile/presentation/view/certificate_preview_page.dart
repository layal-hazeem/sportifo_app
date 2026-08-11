import 'package:flutter/material.dart';

class CertificatePreviewPage extends StatelessWidget {
  final String imageUrl;

  const CertificatePreviewPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Center(
        child: Hero(
          tag: imageUrl,
          child: Material(
            color: Colors.transparent,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
