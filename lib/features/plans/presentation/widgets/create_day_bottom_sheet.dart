import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';

class CreateDayBottomSheet extends StatefulWidget {
  final Function(String) onCreate;

  const CreateDayBottomSheet({super.key, required this.onCreate});

  static void show(BuildContext context, Function(String) onCreate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (_) => CreateDayBottomSheet(onCreate: onCreate),
    );
  }

  @override
  State<CreateDayBottomSheet> createState() => _CreateDayBottomSheetState();
}

class _CreateDayBottomSheetState extends State<CreateDayBottomSheet> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Container(
        padding: const EdgeInsets.all(24),

        decoration: const BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 45,
              height: 5,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: 70,
              height: 70,

              decoration: BoxDecoration(
                color: AppColors.primaryBtn.withOpacity(.12),

                borderRadius: BorderRadius.circular(22),
              ),

              child: const Icon(
                Icons.calendar_month_rounded,
                size: 35,
                color: AppColors.primaryBtn,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Create Workout Day",

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Give your training day a name",

              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: controller,

              autofocus: true,

              decoration: InputDecoration(
                hintText: "Example: Chest Day",

                filled: true,

                fillColor: Colors.grey.shade100,

                prefixIcon: const Icon(
                  Icons.fitness_center,
                  color: AppColors.primaryBtn,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  final value = controller.text.trim();

                  if (value.isEmpty) return;

                  widget.onCreate(value);

                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,

                  padding: const EdgeInsets.symmetric(vertical: 16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: const Text(
                  "Create Day",

                  style: TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,

                    fontSize: 16,
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
