import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/widgets/cached_static_gif.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailsScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseDetailsScreen> createState() =>
      _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  late final TextEditingController setsController;
  late final TextEditingController repsController;
  late final TextEditingController durationController;
  late final TextEditingController orderController;

  @override
  void initState() {
    super.initState();

    setsController = TextEditingController(
      text: widget.exercise.sets?.toString() ?? "",
    );

    repsController = TextEditingController(
      text: widget.exercise.reps ?? "",
    );

    durationController = TextEditingController(
      text: widget.exercise.duration ?? "",
    );

    orderController = TextEditingController(
      text: widget.exercise.order?.toString() ?? "",
    );
  }

  @override
  void dispose() {
    setsController.dispose();
    repsController.dispose();
    durationController.dispose();
    orderController.dispose();
    super.dispose();
  }

  void save() {
    widget.exercise.sets =
        int.tryParse(setsController.text);

    widget.exercise.reps =
        repsController.text.trim().isEmpty
            ? null
            : repsController.text.trim();

    widget.exercise.duration =
        durationController.text.trim().isEmpty
            ? null
            : durationController.text.trim();

    widget.exercise.order =
        int.tryParse(orderController.text);

    Navigator.pop(context);
  }

  Widget field(
    String label,
    TextEditingController controller,
    TextInputType keyboard,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;

    return Scaffold(
      appBar: AppBar(
        title: Text(ex.name),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 220,
                child: CachedStaticGif(
                  imageUrl: ex.gifUrl ?? "",
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              ex.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              ex.description,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 30),

            field(
              "Sets",
              setsController,
              TextInputType.number,
            ),

            field(
              "Reps",
              repsController,
              TextInputType.text,
            ),

            field(
              "Duration",
              durationController,
              TextInputType.text,
            ),

            field(
              "Order",
              orderController,
              TextInputType.number,
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,
                ),
                onPressed: save,
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}