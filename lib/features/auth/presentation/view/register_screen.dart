import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  void login() {
    Navigator.pushReplacementNamed(context, AppRoutes.register);
  }
  final PageController _controller = PageController();
  int currentPage = 0;

  void nextStep() {
    if (currentPage == 0) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      /// otp
      showOtpChoice();
    }
  }

  void showOtpChoice() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),


              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

               Text(l10n.chooseOtpMethod,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(l10n.viaEmail),
                onTap: () => Navigator.pop(context),
              ),

              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: Text(l10n.viaPhone),
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.mainPadding),
          child: Column(
            children: [
              const SizedBox(height: 40),

        Text(
        l10n.createAccount,
        style: const TextStyle(
          fontSize: AppSizes.titleFontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),

              const SizedBox(height: 30),

              //Pages
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                  },
                  children: [
                    //1
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          buildField(l10n.firstName, l10n.enterFirstName, Icons.person_outline),
                          buildField(l10n.lastName, l10n.enterLastName, Icons.person_outline),
                          buildField(l10n.emailOrPhone, l10n.emailHint, Icons.email_outlined),
                          buildField(l10n.phone, l10n.enterPhone, Icons.phone_outlined),
                          const SizedBox(height: 30),
                           Text("Already have an account ?",),

                          TextButton(
                            onPressed: login,
                            child: Text(
                             " login >",
                              style: TextStyle(
                                color: AppColors.primaryBtn,
                                fontSize: 18,
                              ),
                            ),
                          ),

                          // Text("Already have an account ?",),

                        ],
                      ),
                    ),

                    // 2
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          buildField(l10n.password, l10n.passwordHint,Icons.visibility_off_outlined, isPassword: true),
                          buildField(l10n.confirmPassword,l10n.confirmPassword, Icons.visibility_off_outlined, isPassword: true),

                          const SizedBox(height: 20),


                          Column(
                            children: [
                              Text(
                                l10n.profilePicture,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),

                              CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.primaryBtn.withOpacity(0.1),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: AppColors.textDark,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  l10n.termsText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.hintText,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              CustomAuthButton(
                text: currentPage == 0 ? l10n.next : l10n.register,                onPressed: nextStep,
              ),

              const SizedBox(height: 20),
              // Back
              if (currentPage == 1)
                TextButton(
                  onPressed: () {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    l10n.back,
                    style: const TextStyle(
                      color: AppColors.primaryBtn,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String label, String hint, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.labelFontSize,
          ),
        ),

        const SizedBox(height: 10),

        CustomNeumorphicField(
          hint: hint,
          icon: icon,
          isPassword: isPassword,
        ),
      ],
    );
  }
}