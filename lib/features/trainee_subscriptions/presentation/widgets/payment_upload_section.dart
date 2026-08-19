import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../../../l10n/app_localizations.dart';

class PaymentUploadSection extends StatefulWidget {
  final Function(String, String) onFilePicked;

  const PaymentUploadSection({super.key, required this.onFilePicked});

  @override
  State<PaymentUploadSection> createState() => _PaymentUploadSectionState();
}

class _PaymentUploadSectionState extends State<PaymentUploadSection> {
  bool _isFileUploaded = false;
  String? _fileName;

  Future<void> _pickFile() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'heic'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _isFileUploaded = true;
          _fileName = file.name;
        });
        widget.onFilePicked(file.path!, file.name);
        if (mounted) {
          AppSnackBar.show(
            context,
            message: l10n.subscription_payment_fileSelected(file.name),
            type: SnackBarType.success,
          );
        }
      } else {
        if (mounted) {
          AppSnackBar.show(
            context,
            message: l10n.subscription_payment_noFileSelected,
            type: SnackBarType.info,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: l10n.subscription_payment_filePickError(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _isFileUploaded
              ? Colors.green.withOpacity(0.08)
              : context.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFileUploaded ? Colors.green : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _isFileUploaded
                  ? Icons.verified_user
                  : Icons.cloud_upload_outlined,
              color: _isFileUploaded ? Colors.green : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              _isFileUploaded
                  ? l10n.subscription_payment_fileUploaded(_fileName ?? '')
                  : l10n.subscription_payment_uploadHint,
              style: TextStyle(
                color: _isFileUploaded ? Colors.green : Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
