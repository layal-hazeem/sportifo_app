import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/app_snackbar.dart';
import '../../../../core/helpers/app_validators.dart';
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
// مفاتيح التحقق للنماذج
final _step1FormKey = GlobalKey<FormState>();
final _step2FormKey = GlobalKey<FormState>();
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
      if (_step1FormKey.currentState!.validate()) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else {
      if (_step2FormKey.currentState!.validate()) {

        final bool hasEmail = _emailController.text.trim().isNotEmpty;
        final bool hasPhone = _phoneController.text.trim().isNotEmpty;

        if (hasEmail && !hasPhone) {

          _submitRegistration('email');
        }
        else if (!hasEmail && hasPhone) {

          _submitRegistration('phone');
        }
        else if (hasEmail && hasPhone) {

          showOtpChoice();
        }
        else {
          AppSnackBar.show(
            context,
            message: AppLocalizations.of(context)?.messageOfIncompleteInfo ?? "Please provide an email or phone",
            isError: true,
          );
        }
      }
    }
  }

  // method for send to the cubit
  void _submitRegistration(String otpMethod, {bool fromBottomSheet = false}) {

    if (fromBottomSheet) {
      Navigator.pop(context);
    }

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

      body: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.otpScreen,
                arguments: _emailController.text.trim(),
              );
            }
            else if (state is RegisterFailure) {

              Navigator.of(context, rootNavigator: true).pop();

              AppSnackBar.show(
                context,
                message: state.errorMessage,
                isError: true,
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
                            ///  STEP 1
                            SingleChildScrollView(
                              child: Form(
                                key: _step1FormKey,
                                child: Column(
                                  children: [
                                    buildField(
                                      l10n.firstName,
                                      l10n.enterFirstName,
                                      Icons.person_outline,
                                      controller: _firstNameController,
                                      validator: (val) =>
                                          AppValidators.validateRequired(val, message: "Required field"),
                                    ),
                                    buildField(
                                      l10n.lastName,
                                      l10n.enterLastName,
                                      Icons.person_outline,
                                      controller: _lastNameController,
                                      validator: (val) =>
                                          AppValidators.validateRequired(val, message: "Required field"),
                                    ),
                                    buildField(
                                      l10n.email,
                                      l10n.enterEmail,
                                      Icons.email_outlined,
                                      controller: _emailController,
                                      validator: (val) {
                                        if (val!.trim().isEmpty &&
                                            _phoneController.text.trim().isEmpty) {
                                          return "Please enter email or phone";
                                        }
                                        return AppValidators.validateEmail(
                                          val,
                                          isRequired: false,
                                          message: "",
                                        );
                                      },
                                    ),
                                    buildField(
                                      l10n.phone,
                                      l10n.enterPhone,
                                      Icons.phone_outlined,
                                      controller: _phoneController,
                                      validator: (val) {
                                        if (val!.trim().isEmpty &&
                                            _emailController.text.trim().isEmpty) {
                                          return "Please enter email or phone";
                                        }
                                        return AppValidators.validatePhone(
                                          val,
                                          isRequired: false,
                                          message: "",
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 30),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          l10n.dontHaveAccount,
                                          style: const TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: AppSizes.hintFontSize,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: login,
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
                            ),

                            ///  STEP 2
                            SingleChildScrollView(
                              child: Form(
                                key: _step2FormKey,
                                child: Column(
                                  children: [
                                    buildField(
                                      l10n.password,
                                      l10n.passwordHint,
                                      Icons.visibility_off_outlined,
                                      isPassword: true,
                                      controller: _passwordController,
                                      validator: (val) =>
                                          AppValidators.validatePassword(val, message: "Required field"),
                                    ),
                                    buildField(
                                      l10n.confirmPassword,
                                      l10n.confirmPassword,
                                      Icons.visibility_off_outlined,
                                      isPassword: true,
                                      controller: _confirmPasswordController,
                                      validator: (val) => AppValidators.validateConfirmPassword(
                                        val,
                                        _passwordController.text,
                                        message: "Required field",
                                      ),
                                    ),
                                  ],
                                ),
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

  Widget buildField(
      String label,
      String hint,
      IconData icon, {
        bool isPassword = false,
        required TextEditingController controller,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        CustomNeumorphicField(
          hint: hint,
          icon: icon,
          isPassword: isPassword,
          controller: controller,
          validator: validator,
        ),
      ],
    );
  }
}
