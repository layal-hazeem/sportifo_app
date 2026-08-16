import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/existing_days/data/model/existing_days_model.dart';
import 'package:sportifo_app/features/existing_days/presentation/view_model/existing_days_cubit.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class ExistingDaysListBottomSheet extends StatefulWidget {
  const ExistingDaysListBottomSheet({super.key});

  @override
  State<ExistingDaysListBottomSheet> createState() =>
      _ExistingDaysListBottomSheetState();
}

class _ExistingDaysListBottomSheetState
    extends State<ExistingDaysListBottomSheet>
    with TickerProviderStateMixin {
  final Set<int> expandedDays = {};
  final Set<ExistingDaysModel> selectedDays = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(3),

      child: BlocBuilder<ExistingDaysCubit, ExistingDaysState>(
        builder: (context, state) {
          if (state is ExistingDaysLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExistingDaysError) {
            return Center(child: Text(state.errorMessage));
          }

          if (state is ExistingDaysSuccess) {
            if (state.days.isEmpty) {
              return Center(child: Text(l10n.noExistingDaysFound));
            }

            return Column(
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  l10n.addExistingDays,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBtn,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${state.days.length} ${l10n.availableDays}',
                  style: TextStyle(color: AppColors.hintText),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (_, _) => const SizedBox(height: 12),

                    itemCount: state.days.length,

                    itemBuilder: (context, index) {
                      final day = state.days[index];

                      final isExpanded = expandedDays.contains(index);

                      final isSelected = selectedDays.contains(day);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.65),

                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryBtn
                                : AppColors.primaryBtn.withOpacity(.15),
                          ),
                        ),

                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        expandedDays.remove(index);
                                      } else {
                                        expandedDays.add(index);
                                      }
                                    });
                                  },

                                  child: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_right,
                                    color: AppColors.primaryBtn,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBtn,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),

                                const SizedBox(width: 18),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        day.name ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),

                                      Text(
                                        '${day.exercises?.length ?? 0} ${l10n.exercises}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedDays.remove(day);
                                      } else {
                                        selectedDays.add(day);
                                      }
                                    });
                                  },

                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),

                                    width: 24,
                                    height: 24,

                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryBtn
                                          : Colors.transparent,

                                      borderRadius: BorderRadius.circular(6),

                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryBtn
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),

                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),

                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,

                              child: isExpanded
                                  ? Column(
                                      children: [
                                        const Divider(),

                                        ...(day.exercises ?? []).map(
                                          (exercise) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),

                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 7,
                                                  height: 7,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryBtn,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),

                                                const SizedBox(width: 10),

                                                Expanded(
                                                  child: Text(
                                                    exercise.name ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ADD BUTTON
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBtn,
                      elevation: 0,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    onPressed: selectedDays.isEmpty
                        ? null
                        : () {
                            Navigator.pop<List<ExistingDaysModel>>(
                              context,
                              selectedDays.toList(),
                            );
                          },

                    child: Text(
                      '${l10n.addSelectedDays} ${selectedDays.length}',

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
