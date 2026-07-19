import 'package:flutter/material.dart';
import 'package:sportifo_app/features/profile/presentation/view/certificate_preview_page.dart';

class CertificateCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;

  const CertificateCard({super.key, required this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),

      onTap:
          onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CertificatePreviewPage(imageUrl: imageUrl),
              ),
            );
          },

      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),

        child: Hero(
          tag: imageUrl,

          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,

            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;

              return Container(
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator()),
              );
            },

            errorBuilder: (_, _, _) {
              return Container(
                color: Colors.grey.shade100,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CoachCertificatesSection extends StatelessWidget {
  final List<dynamic> certificates;

  const CoachCertificatesSection({super.key, required this.certificates});

  @override
  Widget build(BuildContext context) {
    if (certificates.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(child: Text("No certificates")),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: certificates.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (_, index) {
          return CertificateCard(imageUrl: certificates[index]);
        },
      ),
    );
  }
}
