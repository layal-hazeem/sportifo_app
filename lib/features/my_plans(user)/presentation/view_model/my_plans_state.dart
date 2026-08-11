// ---- States (my_plans_state.dart) ----
import '../../data/models/my_plan_model.dart';
import '../../data/repository/my_plans_repository.dart';

/// 🔥 حالة تاب واحد (Loading / Success / Failure) - منستخدمها لكل التلاتة
/// تابات، فما في تكرار (Loading/Failure/Success) 3 مرات.
///
/// ⚠️ لازم كل كلاس (وحتى الأب TabStatus) يكون عندو const constructor صريح،
/// لأننا مستخدمين TabInitial() جوا const map بالأسفل (بـ MyPlansState).
/// بدون const صريح هون، Dart بيرفض يعتبرها compile-time constant وبيطلع error.
sealed class TabStatus {
  const TabStatus();
}

class TabInitial extends TabStatus {
  const TabInitial();
}

class TabLoading extends TabStatus {
  const TabLoading();
}

class TabSuccess extends TabStatus {
  final List<PlanModel> plans;
  const TabSuccess(this.plans);
}

class TabFailure extends TabStatus {
  final String message;
  const TabFailure(this.message);
}

/// 🔥 الحالة الكاملة للشاشة: حالة مستقلة لكل تاب من التلاتة، محفوظين
/// بـ Map حسب النوع - هيك التابات ما بتعلّق ببعض (لو تاب فشل، الباقي يضلوا شغالين).
class MyPlansState {
  final Map<PlanTabType, TabStatus> tabStatuses;

  const MyPlansState({
    this.tabStatuses = const {
      PlanTabType.coach: TabInitial(),
      PlanTabType.custom: TabInitial(),
      PlanTabType.saved: TabInitial(),
    },
  });

  TabStatus statusFor(PlanTabType type) => tabStatuses[type] ?? const TabInitial();

  MyPlansState copyWithTab(PlanTabType type, TabStatus status) {
    return MyPlansState(tabStatuses: {...tabStatuses, type: status});
  }
}