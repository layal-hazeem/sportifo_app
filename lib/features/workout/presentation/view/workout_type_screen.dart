import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_model/categories_cubit/categories_cubit.dart';
import '../view_model/categories_cubit/categories_state.dart';
import '../widgets/light_premium_workout_card.dart';

class WorkoutTypeScreen extends StatefulWidget {
  const WorkoutTypeScreen({super.key});

  @override
  State<WorkoutTypeScreen> createState() => _WorkoutTypeScreenState();
}

class _WorkoutTypeScreenState extends State<WorkoutTypeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
          ),
        );

    _headerOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    // ❌ تم إزالة استدعاء الـ Fetch من هنا لكي يتحدث الكيوبيت عند تغيير اللغة
  }

  // ✅ تمت إضافة هذه الدالة لتحديث البيانات من السيرفر (والكاش) فوراً عند تغيير اللغة أو فتح الشاشة
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<CategoriesCubit>().fetchCategories(1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.75;

    // 🔥 نقلنا الـ Map إلى داخل دالة build لكي تستطيع قراءة الترجمة المتغيرة (l10n)
    final Map<int, Map<String, String>> categoryUIInfo = {
      1: {
        'subtitle': l10n.build_muscle, // 🔥 تمت الترجمة
        'image': 'assets/images/strength.jpg',
      },
      2: {
        'subtitle': l10n.burn_fat, // 🔥 تمت الترجمة
        'image': 'assets/images/cardio.jpg',
      },
    };

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: BlocConsumer<CategoriesCubit, CategoriesState>(
          listener: (context, state) {
            if (state is CategoriesSuccess) {
              _controller.forward(from: 0.0);
            }
          },
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: SizedBox(
                      width: cardWidth,
                      child: const AspectRatio(
                        aspectRatio: 0.31,
                        child: LoadingShimmer(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 20,
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is CategoriesFailure) {
              return Center(
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is CategoriesSuccess) {
              final categories = state.categories;

              if (categories.isEmpty) {
                return Center(child: Text(l10n.no_categories_found));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _headerSlideAnimation,
                    child: FadeTransition(
                      opacity: _headerOpacityAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            // 🔥 ترجمة النص الثابت فوق الكروت
                            Text(
                              l10n.chooseYourWorkoutType ??
                                  "Choose Your\nWorkout Type",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final uiInfo =
                            categoryUIInfo[category.id] ??
                            {
                              'subtitle': l10n.start_training, // 🔥 تمت الترجمة
                              'image': 'assets/images/default_workout.png',
                            };

                        final delay = 0.2 + (index * 0.2);
                        final slideAnim =
                            Tween<Offset>(
                              begin: const Offset(0.5, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: Interval(
                                  delay,
                                  1.0,
                                  curve: Curves.easeOutQuart,
                                ),
                              ),
                            );

                        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
                            .animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: Interval(
                                  delay,
                                  1.0,
                                  curve: Curves.easeIn,
                                ),
                              ),
                            );

                        return SlideTransition(
                          position: slideAnim,
                          child: FadeTransition(
                            opacity: fadeAnim,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: SizedBox(
                                width: cardWidth,
                                child: LightPremiumWorkoutCard(
                                  // 🔥 إزالة toUpperCase() لتجنب أخطاء الخطوط العربية
                                  title: category.name,
                                  subtitle: uiInfo['subtitle']!,
                                  imagePath: uiInfo['image']!,
                                  onTap: () {
                                    if (category.id == 1) {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.muscleGroups,
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.exercisesList,
                                        arguments: {
                                          'categoryId': category.id,
                                          'categoryName': category.name,
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
