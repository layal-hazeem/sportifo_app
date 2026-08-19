import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is DeleteAccountSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.deletedSucceful),
              backgroundColor: Colors.green,
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.register,
              (route) => false,
            );
          });
        }

        if (state is DeleteAccountFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },

      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.backgroundColor,

          appBar: WaveAppBar(title: l10n.deleteAccount, showBackButton: true),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.delete_forever_rounded,
                          color: Colors.red,
                          size: 90,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          l10n.deleteAccount,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          l10n.deleteHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.deleteHint2,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildInfoTile(
                          Icons.person_outline,
                          l10n.yourProfile,
                          context,
                        ),
                        const SizedBox(height: 12),

                        _buildInfoTile(
                          Icons.fitness_center,
                          l10n.workoutPlans,
                          context,
                        ),
                        const SizedBox(height: 12),

                        _buildInfoTile(
                          Icons.bookmark_outline,
                          l10n.saved_exercises,
                          context,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final profileCubit = context.read<ProfileCubit>();

                      _showDeleteConfirmationDialog(context, profileCubit);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      l10n.continue1,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    ProfileCubit profileCubit,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text(l10n.confirmDelete),
            ],
          ),
          content: Text(
            "${l10n.deletionConfirmationQuestion}\n\n"
            "${l10n.deleteHint2}",
            style: TextStyle(fontSize: 15),
          ),
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                profileCubit.deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.delete,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String title, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.cancel, color: Colors.red),
        ],
      ),
    );
  }
}
