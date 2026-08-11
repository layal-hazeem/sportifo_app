import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/features/trainees/data/models/coach_plan_model.dart';
import 'package:sportifo_app/features/trainees/presentation/view_model/trainees_cubit.dart';
import 'package:sportifo_app/features/trainees/presentation/view_model/trainees_state.dart';
import 'package:sportifo_app/features/trainees/presentation/widgets/trainees_grid.dart';
import 'package:sportifo_app/features/trainees/presentation/widgets/trainees_header.dart';

class TraineesScreen extends StatefulWidget {
  const TraineesScreen({super.key});

  @override
  State<TraineesScreen> createState() => _TraineesScreenState();
}

class _TraineesScreenState extends State<TraineesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TraineesCubit>().getCoachTrainees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFCF7),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFBF5), Color(0xFFFFFFFF), Color(0xFFFFFDF9)],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<TraineesCubit, TraineesState>(
            builder: (context, state) {
              if (state is TraineesLoading) {
                return const _TraineesLoading();
              }

              if (state is TraineesFailure) {
                return _TraineesError(
                  message: state.message,
                  onRetry: () {
                    context.read<TraineesCubit>().getCoachTrainees();
                  },
                );
              }

              if (state is TraineesSuccess) {
                return _TraineesContent(plans: state.response.data);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _TraineesContent extends StatelessWidget {
  final List<CoachPlanModel> plans;

  const _TraineesContent({required this.plans});

  int get uniqueTraineesCount {
    final ids = <int>{};

    for (final plan in plans) {
      final id = plan.user?.id;

      if (id != null) {
        ids.add(id);
      }
    }

    return ids.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TraineesHeader(count: uniqueTraineesCount),

        Expanded(
          child: TraineesGrid(
            plans: plans,
            onTraineeTap: (plan) => _openPlan(context, plan),
          ),
        ),
      ],
    );
  }

  void _openPlan(BuildContext context, CoachPlanModel plan) {
    final planId = plan.id;

    if (planId == null) {
      return;
    }

    Navigator.pushNamed(context, AppRoutes.planDetails, arguments: planId);
  }
}

class _TraineesLoading extends StatelessWidget {
  const _TraineesLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                width: 170,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Spacer(),
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.05),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Expanded(child: Center(child: CircularProgressIndicator())),
      ],
    );
  }
}

class _TraineesError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TraineesError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 54,
              color: Colors.black.withOpacity(0.25),
            ),
            const SizedBox(height: 16),
            const Text(
              'Couldn’t load trainees',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
