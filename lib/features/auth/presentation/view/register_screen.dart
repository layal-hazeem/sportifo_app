import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
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
  bool _isTermsAccepted = false;

  // 🔥 متغيرات التحكم بحالة التحقق التلقائي لكل خطوة
  AutovalidateMode _step1AutovalidateMode = AutovalidateMode.disabled;
  AutovalidateMode _step2AutovalidateMode = AutovalidateMode.disabled;

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
    final l10n = AppLocalizations.of(context)!;
    if (currentPage == 0) {
      if (_step1FormKey.currentState!.validate()) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        // 🔥 إذا فشل التحقق عند الضغط، نُفعل التحقق التلقائي لتظهر الأخطاء للمستخدم ويعدلها
        setState(() {
          _step1AutovalidateMode = AutovalidateMode.onUserInteraction;
        });
      }
    } else {
      if (_step2FormKey.currentState!.validate()) {
        if (!_isTermsAccepted) {
          AppSnackBar.show(
            context,
            message: l10n.agreed,
            type: SnackBarType.error,
          );
          return;
        }

        final bool hasEmail = _emailController.text.trim().isNotEmpty;
        final bool hasPhone = _phoneController.text.trim().isNotEmpty;

        if (hasEmail && !hasPhone) {
          _submitRegistration('email');
        } else if (!hasEmail && hasPhone) {
          _submitRegistration('phone');
        } else if (hasEmail && hasPhone) {
          showOtpChoice();
        } else {
          AppSnackBar.show(
            context,
            message: l10n.messageOfIncompleteInfo,
            type: SnackBarType.error,
          );
        }
      } else {
        // 🔥 إذا فشل التحقق في الخطوة الثانية، نُفعل التحقق التلقائي لها
        setState(() {
          _step2AutovalidateMode = AutovalidateMode.onUserInteraction;
        });
      }
    }
  }

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
              Text(
                l10n.chooseOtpMethod,
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
                onTap: () => _submitRegistration('email', fromBottomSheet: true),
              ),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: Text(l10n.viaPhone),
                onTap: () => _submitRegistration('phone', fromBottomSheet: true),
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
            AppSnackBar.show(
              context,
              message: l10n.otpSentMessage,
              type: SnackBarType.success,
            );
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.otpScreen,
              arguments: _emailController.text.isNotEmpty
                  ? _emailController.text.trim()
                  : _phoneController.text.trim(),
            );
          } else if (state is RegisterFailure) {
            AppSnackBar.show(
              context,
              message: state.errorMessage,
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    l10n.createAccount,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() => currentPage = index);
                      },
                      children: [
                        ///  STEP 1
                        _buildScrollablePage(
                          formKey: _step1FormKey,
                          autovalidateMode: _step1AutovalidateMode, // 🔥 تمرير الحالة الديناميكية
                          l10n: l10n,
                          state: state,
                          isLastStep: false,
                          children: [
                            buildField(
                              l10n.firstName, l10n.enterFirstName, Icons.person_outline,
                              controller: _firstNameController,
                              validator: (val) => AppValidators.validateRequired(val, message: l10n.requiredField),
                            ),
                            buildField(
                              l10n.lastName, l10n.enterLastName, Icons.person_outline,
                              controller: _lastNameController,
                              validator: (val) => AppValidators.validateRequired(val, message: l10n.requiredField),
                            ),
                            buildField(
                              l10n.email, l10n.enterEmail, Icons.email_outlined,
                              controller: _emailController,
                              validator: (val) {
                                if (val!.trim().isEmpty && _phoneController.text.trim().isEmpty) {
                                  return l10n.enterEmailOrPhone;
                                }
                                return AppValidators.validateEmail(val, isRequired: false, message: l10n.invalidEmail);
                              },
                            ),
                            buildField(
                              l10n.phone, l10n.enterPhone, Icons.phone_outlined,
                              controller: _phoneController,
                              validator: (val) {
                                if (val!.trim().isEmpty && _emailController.text.trim().isEmpty) {
                                  return l10n.enterEmailOrPhone;
                                }
                                return AppValidators.validatePhone(val, isRequired: false, message: l10n.invalidPhone);
                              },
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(l10n.dontHaveAccount, style: const TextStyle(color: AppColors.textDark, fontSize: 14)),
                                TextButton(
                                  onPressed: login,
                                  child: Text(
                                    l10n.login,
                                    style: const TextStyle(color: AppColors.primaryBtn, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        ///  STEP 2
                        _buildScrollablePage(
                          formKey: _step2FormKey,
                          autovalidateMode: _step2AutovalidateMode, // 🔥 تمرير الحالة الديناميكية
                          l10n: l10n,
                          state: state,
                          isLastStep: true,
                          children: [
                            buildField(
                              l10n.password, l10n.passwordHint, Icons.lock_outline,
                              isPassword: true,
                              controller: _passwordController,
                              validator: (val) => AppValidators.validatePassword(val, message: l10n.requiredField),
                            ),
                            buildField(
                              l10n.confirmPassword, l10n.confirmPassword, Icons.lock_outline,
                              isPassword: true,
                              controller: _confirmPasswordController,
                              validator: (val) => AppValidators.validateConfirmPassword(
                                val,
                                _passwordController.text,
                                message: l10n.passwordMismatch,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScrollablePage({
    required GlobalKey<FormState> formKey,
    required AutovalidateMode autovalidateMode, // 🔥 أصبحت تستقبل الـ mode كمعامل مرن
    required AppLocalizations l10n,
    required RegisterState state,
    required bool isLastStep,
    required List<Widget> children,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Form(
                key: formKey,
                autovalidateMode: autovalidateMode, // 🔥 ربطها بالمتغير الممرر
                child: Column(
                  children: [
                    ...children,
                    const Spacer(),
                    const SizedBox(height: 20),
                    if (isLastStep) _buildPrivacyPolicy(l10n),
                    const SizedBox(height: 20),
                    CustomAuthButton(
                      text: !isLastStep ? l10n.next : l10n.register,
                      onPressed: (isLastStep && !_isTermsAccepted) ? null : nextStep,
                      isLoading: state is RegisterLoading,
                    ),
                    const SizedBox(height: 10),
                    if (currentPage == 1)
                      TextButton(
                        onPressed: () => _controller.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                        child: Text(l10n.back, style: const TextStyle(color: AppColors.linkColor, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyPolicy(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _isTermsAccepted,
            activeColor: AppColors.primaryBtn,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) => setState(() => _isTermsAccepted = val ?? false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.hintText, fontSize: 13, height: 1.4, fontFamily: 'Cairo'),
              children: [
                TextSpan(text: l10n.termsPart1),
                TextSpan(text: l10n.termsPart2, style: const TextStyle(color: AppColors.primaryBtn, fontWeight: FontWeight.bold)),
                TextSpan(text: l10n.termsPart3),
                TextSpan(text: l10n.termsPart4, style: const TextStyle(color: AppColors.primaryBtn, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildField(String label, String hint, IconData icon, {bool isPassword = false, required TextEditingController controller, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        CustomNeumorphicField(hint: hint, icon: icon, isPassword: isPassword, controller: controller, validator: validator),
      ],
    );
  }
}