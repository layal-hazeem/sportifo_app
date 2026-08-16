import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/widgets/custom_glass_bottom_sheet.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/widgets/action_tile.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class EditPlanAddDayFab extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onCreateNewDay;
  final VoidCallback onAddExistingDay;

  const EditPlanAddDayFab({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.onCreateNewDay,
    required this.onAddExistingDay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedRotation(
      turns: isOpen ? 0.125 : 0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton(
        backgroundColor: AppColors.primaryBtn,
        elevation: 6,
        onPressed: () async {
          onToggle();
          await Future.delayed(const Duration(milliseconds: 200));
          if (!context.mounted) return;

          CustomGlassBottomSheet.show(
            context: context,
            height: 0.30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                EditPlanActionTile(
                  icon: Icons.add_circle_outline,
                  color: AppColors.primaryBtn,
                  title: l10n.createNewDay,
                  subtitle: l10n.creatDaySubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    onCreateNewDay();
                  },
                ),
                const SizedBox(height: 12),
                EditPlanActionTile(
                  icon: Icons.copy_outlined,
                  color: Colors.blue,
                  title: l10n.addExistingDay,
                  subtitle: l10n.addExistingDaySubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    onAddExistingDay();
                  },
                ),
              ],
            ),
          );
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: Icon(
            isOpen ? Icons.close : Icons.add,
            key: ValueKey(isOpen),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}