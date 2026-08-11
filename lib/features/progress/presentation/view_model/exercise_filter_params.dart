class _Undefined {
  const _Undefined();
}

class ExerciseFilterParams {
  final int? planId;
  final int? exerciseId;
  final String? from;
  final String? to;

  const ExerciseFilterParams({
    this.planId,
    this.exerciseId,
    this.from,
    this.to,
  });

  bool get isEmpty =>
      planId == null && exerciseId == null && from == null && to == null;

  ExerciseFilterParams copyWith({
    Object? planId = const _Undefined(),
    Object? exerciseId = const _Undefined(),
    Object? from = const _Undefined(),
    Object? to = const _Undefined(),
  }) {
    return ExerciseFilterParams(
      planId: planId is _Undefined ? this.planId : planId as int?,
      exerciseId: exerciseId is _Undefined
          ? this.exerciseId
          : exerciseId as int?,
      from: from is _Undefined ? this.from : from as String?,
      to: to is _Undefined ? this.to : to as String?,
    );
  }
}
