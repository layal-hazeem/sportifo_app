import 'package:flutter/material.dart';

class ProfileImageView extends StatelessWidget {
  final String? imageUrl;
  final ImageProvider? localImage;

  const ProfileImageView({
    super.key,
    this.imageUrl,
    this.localImage,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;

    if (localImage != null) {
      provider = localImage;
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      provider = NetworkImage(imageUrl!);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: Hero(
                tag: "profile-image",
                child: provider == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 150,
                      )
                    : Image(
                        image: provider,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}