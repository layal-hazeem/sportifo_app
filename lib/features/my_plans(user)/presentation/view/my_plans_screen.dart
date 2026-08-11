import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/my_plan_model.dart';
import '../../data/repository/my_plans_repository.dart';
import '../view_model/my_plans_cubit.dart';
import '../view_model/my_plans_state.dart';
import '../widgets/workout_plan_card.dart';

/// 🔥 إعدادات تاب واحد - كل شي خاص فيه (عنوان، رسائل الحالة الفاضية، وزر
/// الـ CTA) محطوط هون. الشاشة بتلف عليها بمصفوفة واحدة (List<_PlanTabConfig>)
/// فما في تكرار لواجهة/كود لكل تاب - نفس الفكرة يلي طلبتيها بالضبط.
class _PlanTabConfig {
  final PlanTabType type;
  final String label;
  final String emptyTitle;
  final String emptySubtitle;
  final String? emptyButtonText;
  final void Function(BuildContext context)? onEmptyButtonTap;

  const _PlanTabConfig({
    required this.type,
    required this.label,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.emptyButtonText,
    this.onEmptyButtonTap,
  });
}

final List<_PlanTabConfig> _kTabConfigs = [
  _PlanTabConfig(
    type: PlanTabType.coach,
    label: 'Coach Plan',
    emptyTitle: 'No Coach Plan Found',
    emptySubtitle: 'Get a personalized workout routine from our expert coaches.',
    emptyButtonText: 'Explore Coaches',
    onEmptyButtonTap: (context) => Navigator.pushNamed(context, AppRoutes.coach),
  ),
  _PlanTabConfig(
    type: PlanTabType.custom,
    label: 'My Plans',
    emptyTitle: 'No Custom Plans Yet',
    emptySubtitle: 'Build your own custom plan and train on your schedule.',
    emptyButtonText: 'Create Custom Plan',
    // ⚠️ TODO: ما في لسا شاشة "أنشئ خطة شخصية" جاهزة بالتطبيق (اللي موجودة
    // بروت createPlan حالياً خاصة بالكوتش بينشئ خطة لعميل، مش لنفس المستخدم).
    // لما تجهز هاي الشاشة، بس ضيفي هون: Navigator.pushNamed(context, AppRoutes.createSelfPlan)
    onEmptyButtonTap: null,
  ),
  _PlanTabConfig(
    type: PlanTabType.saved,
    label: 'Saved',
    emptyTitle: 'No Saved Plans Yet',
    emptySubtitle: 'Plans you save from the platform library will show up here.',
    emptyButtonText: null,
  ),
];

class MyPlansScreen extends StatefulWidget {
  const MyPlansScreen({super.key});

  @override
  State<MyPlansScreen> createState() => _MyPlansScreenState();
}

class _MyPlansScreenState extends State<MyPlansScreen> {
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // 🔥 منحمّل بس التاب الأول أول ما تفتح الشاشة (lazy) - باقي التابات
    // بتنحمّل بس أول ما المستخدم يفتحها فعلياً (شوف _onTabTap)
    context.read<MyPlansCubit>().fetchTab(_kTabConfigs[0].type);
  }

  void _onTabTap(int index) {
    setState(() => _activeTabIndex = index);
    // 🔥 بتحمّل مرة وحدة بس (fetchTab أصلاً بتتفادى إعادة الطلب لو الداتا موجودة)
    context.read<MyPlansCubit>().fetchTab(_kTabConfigs[index].type);
  }

  @override
  Widget build(BuildContext context) {
    final activeConfig = _kTabConfigs[_activeTabIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 4),
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  for (int i = 0; i < _kTabConfigs.length; i++) _buildToggleButton(_kTabConfigs[i].label, i),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<MyPlansCubit, MyPlansState>(
                builder: (context, state) {
                  final status = state.statusFor(activeConfig.type);
                  return switch (status) {
                    TabLoading() || TabInitial() => const Center(child: CircularProgressIndicator(color: AppColors.primaryBtn)),
                    TabFailure() => Center(child: Text(status.message, style: const TextStyle(color: AppColors.hintText))),
                    TabSuccess() => _buildPlansList(activeConfig, status.plans),
                  };
                },
              ),
            ),
          ],
        ),
      ),
      // 👈 شلنا الـ FloatingActionButton القديم (كان زر "+" بدون أي action
      // فعلي، ومكرر مع زر "Create Custom Plan" الموجود بالحالة الفاضية).
    );
  }

  Widget _buildToggleButton(String title, int tabIndex) {
    final isSelected = _activeTabIndex == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTap(tabIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBtn : Colors.transparent,
            borderRadius: BorderRadius.circular(16.0),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.hintText,
              fontWeight: FontWeight.bold,
              fontSize: 13.0,
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 دالة واحدة بترسم لائحة أي تاب (فاضية أو فيها خطط) - نفس الكود
  // لكل التلاتة تابات، بس بتاخد config مختلف.
  Widget _buildPlansList(_PlanTabConfig config, List<PlanModel> plans) {
    if (plans.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primaryBtn,
        onRefresh: () async => await context.read<MyPlansCubit>().fetchTab(config.type, isRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(config.emptyTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Text(config.emptySubtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.hintText, fontSize: 14.0, height: 1.5)),
                  if (config.emptyButtonText != null) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: config.onEmptyButtonTap != null ? () => config.onEmptyButtonTap!(context) : null,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBtn, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                        child: Text(config.emptyButtonText!, style: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryBtn,
      onRefresh: () async => await context.read<MyPlansCubit>().fetchTab(config.type, isRefresh: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        itemCount: plans.length,
        itemBuilder: (context, index) => WorkoutPlanCard(plan: plans[index]),
      ),
    );
  }
}