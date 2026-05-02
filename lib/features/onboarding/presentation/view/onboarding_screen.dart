import 'package:flutter/material.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../view_model/onboarding_view_model.dart';
import '../widgets/dots_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int currentIndex = 0;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    fadeAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animationController.forward();
  }

  void next() async {
    if (currentIndex < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // 🔥 حفظنا في الذاكرة أنه شاهد الافتتاحية
      await getIt<LocalStorage>().saveOnboardingSeen();
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.register);
    }
  }

  void skip() async {
    // 🔥 حفظنا في الذاكرة أنه تخطى الافتتاحية
    await getIt<LocalStorage>().saveOnboardingSeen();
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.register);
  }

  @override
  void dispose() {
    _controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = onboardingPages(l10n);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [

          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
                animationController.reset();
                animationController.forward();
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];

              return FadeTransition(
                opacity: fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 120),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        child: Image.asset(
                          page.image,
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppSizes.titleFontSize - 4,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.hintText,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          //  Skip
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: AppColors.primaryBtn,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Sportifo",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),


                if (currentIndex != pages.length - 1)
                  TextButton(
                    onPressed: skip,
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: AppColors.primaryBtn,
                        fontSize: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Section
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                DotsIndicator(
                  currentIndex: currentIndex,
                  length: pages.length,
                ),
                const SizedBox(height: 20),

                CustomAuthButton(
                  text: currentIndex == pages.length - 1
                      ? l10n.getStarted
                      : l10n.next,
                  onPressed: next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}