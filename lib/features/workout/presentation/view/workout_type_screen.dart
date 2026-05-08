import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../view_model/categories_cubit/categories_cubit.dart';
import '../view_model/categories_cubit/categories_state.dart';
import '../widgets/light_premium_workout_card.dart'; // 🔥 استيراد الـ Widget المنفصل

class WorkoutTypeScreen extends StatefulWidget {
  const WorkoutTypeScreen({super.key});

  @override
  State<WorkoutTypeScreen> createState() => _WorkoutTypeScreenState();
}

class _WorkoutTypeScreenState extends State<WorkoutTypeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // استدعاء الـ API لجلب التصنيفات الأساسية (رقم 1 يعني مقاومة وكارديو)
    context.read<CategoriesCubit>().fetchCategories(1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔥 قمنا بتغيير الروابط إلى مسارات محلية (Local Assets)
  // تأكدي أن هذه المسارات مطابقة للمجلدات عندك في المشروع
  final Map<int, Map<String, String>> _categoryUIInfo = {
    1: {
      'subtitle': 'Burn Fat',
      'image': 'assets/images/strength.jpg', // مسار صورة الكارديو
    },
    2: {
      'subtitle': 'Build Muscle',
      'image': 'assets/images/cardio.jpg', // مسار صورة المقاومة
    }
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryBtn));
              }
              else if (state is CategoriesFailure) {
                return Center(child: Text(state.errorMessage, style: const TextStyle(color: Colors.red)));
              }
              else if (state is CategoriesSuccess) {
                final categories = state.categories;

                if (categories.isEmpty) {
                  return const Center(child: Text("No categories found."));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories.map((category) {

                      // جلب الصورة المحلية والوصف، وصورة افتراضية في حال لم نجدها
                      final uiInfo = _categoryUIInfo[category.id] ?? {
                        'subtitle': 'Start Training',
                        'image': 'assets/images/default_workout.png',
                      };

                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: SizedBox(
                          width: cardWidth,
                          child: LightPremiumWorkoutCard(
                            title: category.name.toUpperCase(),
                            subtitle: uiInfo['subtitle']!,
                            imagePath: uiInfo['image']!, // نمرر المسار المحلي
                            onTap: () {
                              if (category.id == 2) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.exercisesList,
                                  arguments: {'categoryId': category.id},
                                );
                              } else {
                                Navigator.pushNamed(context, AppRoutes.muscleGroups);
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}