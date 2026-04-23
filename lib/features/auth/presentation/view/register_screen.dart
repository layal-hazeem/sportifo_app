import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';
import '../view_model/register/register_cubit.dart';
import '../view_model/register/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  File? _selectedProfilePic;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void login() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

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

  // method for send to the cubit
  void _submitRegistration(String otpMethod) {
    Navigator.pop(context); // close BottomSheet


    context.read<RegisterCubit>().registerUser(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      otpMethod: otpMethod,
      profilePic: _selectedProfilePic,
    );
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),

              // 3. تعديل الـ onTap ليرسل البيانات بدلاً من الإغلاق فقط
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(l10n.viaEmail),
                onTap: () => _submitRegistration('email'),
              ),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: Text(l10n.viaPhone),
                onTap: () => _submitRegistration('phone'),
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
      // 4. تغليف الواجهة بـ BlocConsumer
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {

            Navigator.pushReplacementNamed(
                context,
                AppRoutes.otpScreen,
              arguments: _emailController.text.trim(),
            );
          }
          /// !!!
          else if (state is RegisterFailure) {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.mainPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        l10n.createAccount,
                        style: const TextStyle(
                          fontSize:  AppSizes.titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Pages
                      Expanded(
                        child: PageView(
                          controller: _controller,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() => currentPage = index);
                          },
                          children: [
                            // 1
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  buildField(l10n.firstName, l10n.enterFirstName, Icons.person_outline, controller: _firstNameController),
                                  buildField(l10n.lastName, l10n.enterLastName, Icons.person_outline, controller: _lastNameController),
                                  buildField(l10n.emailOrPhone, l10n.emailHint, Icons.email_outlined, controller: _emailController),
                                  buildField(l10n.phone, l10n.enterPhone, Icons.phone_outlined, controller: _phoneController),
                                  const SizedBox(height: 30),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        l10n.dontHaveAccount, // Fixed: using localization if available or keep text
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: AppSizes.hintFontSize,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _controller.animateToPage(
                                            1,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeIn,
                                          );
                                        },
                                        child: Text(
                                          l10n.login,
                                          style: const TextStyle(
                                            color: AppColors.primaryBtn,
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppSizes.mediumFontSize,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // 2
                            SingleChildScrollView(
                              child: Column(
                                children: [

                                  buildField(l10n.password, l10n.passwordHint, Icons.visibility_off_outlined, isPassword: true, controller: _passwordController),
                                  buildField(l10n.confirmPassword, l10n.confirmPassword, Icons.visibility_off_outlined, isPassword: true, controller: _confirmPasswordController),
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
                                        backgroundColor: AppColors.primaryBtn.withValues(alpha: 0.1),
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
                          style: const TextStyle(
                            color: AppColors.hintText,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      CustomAuthButton(
                        text: currentPage == 0 ? l10n.next : l10n.register,
                        onPressed: nextStep,
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

                // loading
                if (state is RegisterLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryBtn),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildField(String label, String hint, IconData icon, {bool isPassword = false, required TextEditingController controller}) {
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
          controller: controller,
        ),
      ],
    );
  }
}
