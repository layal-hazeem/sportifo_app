import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_neumorphic_field.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../view_model/nutrition_cubit.dart';
import '../view_model/nutrition_state.dart';

class ManualMealEntryScreen extends StatefulWidget {
  const ManualMealEntryScreen({super.key});

  @override
  State<ManualMealEntryScreen> createState() => _ManualMealEntryScreenState();
}

class _ManualMealEntryScreenState extends State<ManualMealEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bodyCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<NutritionCubit>().addManualMeal(
        body: _bodyCtrl.text.trim(),
        calories: double.parse(_caloriesCtrl.text.trim()),
        protein: double.parse(_proteinCtrl.text.trim()),
        carbs: double.parse(_carbsCtrl.text.trim()),
        fat: double.parse(_fatCtrl.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: getIt<NutritionCubit>(),
      child: BlocConsumer<NutritionCubit, NutritionState>(
        listener: (context, state) {
          if (state is AddMealSuccess) {
            AppSnackBar.show(
              context,
              message: l10n.meal_added_success,
              type: SnackBarType.success,
            );
            Navigator.pop(context);
          } else if (state is AddMealError) {
            AppSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AddMealLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: WaveAppBar(title: l10n.add_meal, showBackButton: true),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      l10n.meal_details,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.enter_nutritional_info_manually,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    CustomNeumorphicField(
                      hint: l10n.meal_description_hint,
                      icon: Icons.restaurant_menu_outlined,
                      controller: _bodyCtrl,
                      keyboardType: TextInputType.text,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.requiredField : null,
                    ),
                    const SizedBox(height: 16),

                    CustomNeumorphicField(
                      hint: l10n.calories,
                      icon: Icons.local_fire_department_outlined,
                      controller: _caloriesCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l10n.requiredField;
                        if (double.tryParse(v.trim()) == null) {
                          return l10n.enter_valid_number;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomNeumorphicField(
                      hint: l10n.protein_g,
                      icon: Icons.egg_alt_outlined,
                      controller: _proteinCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l10n.requiredField;
                        if (double.tryParse(v.trim()) == null) {
                          return l10n.invalid_value;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomNeumorphicField(
                      hint: l10n.carbs,
                      icon: Icons.grain_outlined,
                      controller: _carbsCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l10n.requiredField;
                        if (double.tryParse(v.trim()) == null) {
                          return l10n.invalid_value;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomNeumorphicField(
                      hint: l10n.fat_g,
                      icon: Icons.water_drop_outlined,
                      controller: _fatCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l10n.requiredField;
                        if (double.tryParse(v.trim()) == null) {
                          return l10n.invalid_value;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBtn,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            :  Text(
                                l10n.save_meal,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
