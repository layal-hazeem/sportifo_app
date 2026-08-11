import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_neumorphic_field.dart';
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
    return BlocProvider.value(
      value: getIt<NutritionCubit>(),
      child: BlocConsumer<NutritionCubit, NutritionState>(
        listener: (context, state) {
          if (state is AddMealSuccess) {
            AppSnackBar.show(
              context,
              message: 'Meal added successfully!',
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
            appBar: const WaveAppBar(title: 'Add Meal', showBackButton: true),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meal Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter the nutritional information manually',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    CustomNeumorphicField(
                      hint: 'Meal Description (e.g. 5 eggs)',
                      icon: Icons.restaurant_menu_outlined,
                      controller: _bodyCtrl,
                      keyboardType: TextInputType.text,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    CustomNeumorphicField(
                      hint: 'Calories',
                      icon: Icons.local_fire_department_outlined,
                      controller: _caloriesCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomNeumorphicField(
                      hint: 'Protein (g)',
                      icon: Icons.egg_alt_outlined,
                      controller: _proteinCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomNeumorphicField(
                      hint: 'Carbs (g)',
                      icon: Icons.grain_outlined,
                      controller: _carbsCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomNeumorphicField(
                      hint: 'Fat (g)',
                      icon: Icons.water_drop_outlined,
                      controller: _fatCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid';
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
                            : const Text(
                                'Save Meal',
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
