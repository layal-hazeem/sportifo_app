import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class BookConsultationButton extends StatelessWidget {
  final VoidCallback onTap;

  const BookConsultationButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF7F7F7).withOpacity(0.0),
              const Color(0xFFF7F7F7).withOpacity(0.9),
              const Color(0xFFF7F7F7),
            ],
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              l10n.book_consultation,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}