import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../../data/models/food_log_model.dart';
import '../view_model/nutrition_cubit.dart';
import '../view_model/nutrition_state.dart';
import '../widgets/food_log_card.dart';

class FoodLogsScreen extends StatefulWidget {
  const FoodLogsScreen({super.key});

  @override
  State<FoodLogsScreen> createState() => _FoodLogsScreenState();
}

class _FoodLogsScreenState extends State<FoodLogsScreen> {
  late final NutritionCubit _nutritionCubit;

  @override
  void initState() {
    super.initState();
    _nutritionCubit = getIt<NutritionCubit>();
    _nutritionCubit.initialize();
  }

  Future<void> _onRefresh() async {
    await _nutritionCubit.fetchTodayFoodLogs(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _nutritionCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: WaveAppBar(title: l10n.todays_meals, showBackButton: true),
        body: BlocConsumer<NutritionCubit, NutritionState>(
          listenWhen: (previous, current) {
            return current is AddMealSuccess ||
                current is AddMealError ||
                current is DeleteMealSuccess ||
                current is DeleteMealError;
          },
          listener: (context, state) {
            if (state is AddMealSuccess) {
              AppSnackBar.show(
                context,
                message: l10n.meal_saved_success,
                type: SnackBarType.success,
              );
            } else if (state is AddMealError) {
              AppSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.error,
              );
            } else if (state is DeleteMealSuccess) {
              AppSnackBar.show(
                context,
                message: l10n.meal_deleted_success,
                type: SnackBarType.success,
              );
            } else if (state is DeleteMealError) {
              AppSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.error,
              );
            }
          },
          builder: (context, state) {
            if (state is NutritionLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBtn),
              );
            }

            if (state is NutritionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _onRefresh,
                      icon: const Icon(Icons.refresh),
                      label:  Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is NutritionSuccess ||
                state is AddMealSuccess ||
                state is DeleteMealSuccess) {
              TodayFoodLogsResponse foodLogsData;

              if (state is NutritionSuccess) {
                foodLogsData = state.foodLogs;
              } else if (state is AddMealSuccess) {
                foodLogsData = TodayFoodLogsResponse(
                  logs: state.mealResponse.logs,
                  total: state.mealResponse.total,
                );
              } else if (state is DeleteMealSuccess) {
                foodLogsData = TodayFoodLogsResponse(
                  logs: state.mealResponse.logs,
                  total: state.mealResponse.total,
                );
              } else {
                return const SizedBox.shrink();
              }

              final foodLogs = foodLogsData.logs;
              final total = foodLogsData.total;

              if (foodLogs.isEmpty) {
                return _buildEmptyState(context,l10n);
              }

              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primaryBtn,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildMacrosSummary(total, l10n)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final foodLog = foodLogs[index];
                        return FoodLogCard(
                          key: ValueKey(foodLog.id),
                          foodLog: foodLog,
                          onDelete: () =>
                              _showDeleteConfirmation(context, foodLog.id,l10n),
                        );
                      }, childCount: foodLogs.length),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.no_more_meals,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMacrosSummary(TotalMacros total, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBtn.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBtn.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMacroCard(
            l10n.calories,
            total.calories,
            Icons.local_fire_department,
            const Color(0xFFFF9800),
          ),
          _buildMacroCard(
            l10n.protein,
            total.protein,
            Icons.egg_alt_outlined,
            const Color(0xFFEF5350),
          ),
          _buildMacroCard(
            l10n.carbs,
            total.carbs,
            Icons.grain_outlined,
            const Color(0xFFFFB300),
          ),
          _buildMacroCard(
            l10n.fat,
            total.fat,
            Icons.water_drop_outlined,
            const Color(0xFF42A5F5),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String label, num value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value % 1 == 0 ? '${value.toInt()}g' : '${value}g',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 80,
            color: AppColors.primaryBtn.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.no_meals_logged,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ask_ai_or_add_manual,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.refresh),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBtn,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int mealId, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.primaryBtn,
              size: 50,
            ),
            const SizedBox(height: 12),
             Text(
              l10n.delete_meal_title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content:  Text(
          l10n.delete_meal_confirmation,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:  Text(
              l10n.cancel,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _nutritionCubit.deleteMeal(mealId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:  Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
