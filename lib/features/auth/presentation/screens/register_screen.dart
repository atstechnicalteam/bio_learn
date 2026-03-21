import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/auth_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'otp_screen.dart';
import 'splash_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepository: AuthRepositoryImpl()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OtpScreen(mobile: state.mobile),
                ),
              );
            } else if (state is AuthError) {
              showErrorSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingLG,
                      vertical: AppSizes.paddingLG,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - (AppSizes.paddingLG * 2),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Center(
                                  child: BioxploraLogoWidget(logoWidth: 150),
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  AppStrings.createAccount,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.authTitle,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Start your learning journey with\nBioxplora',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.authSubtitle,
                                ),
                                const SizedBox(height: 26),
                                AppTextField(
                                  label: 'Full Name',
                                  hint: 'Enter your full name',
                                  controller: _nameController,
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.textHint,
                                    size: 20,
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Enter full name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSizes.paddingMD),
                                AppTextField(
                                  label: 'Email Address',
                                  hint: 'Enter your email',
                                  controller: _emailController,
                                  isEmail: true,
                                  prefixIcon: const Icon(
                                    Icons.mail_outline,
                                    color: AppColors.textHint,
                                    size: 20,
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Enter email';
                                    }
                                    if (!v.contains('@')) {
                                      return 'Enter valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSizes.paddingMD),
                                AppTextField(
                                  label: AppStrings.mobileNumber,
                                  hint: 'Enter your phone number',
                                  controller: _mobileController,
                                  isPhone: true,
                                  prefixIcon: const Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.textHint,
                                    size: 20,
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Enter mobile number';
                                    }
                                    if (v.length < 10) {
                                      return 'Enter valid mobile number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSizes.paddingMD),
                                AppTextField(
                                  label: AppStrings.password,
                                  hint: 'Enter password',
                                  controller: _passwordController,
                                  isPassword: true,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Enter password';
                                    }
                                    if (v.length < 6) {
                                      return 'Minimum 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Minimum 6 characters',
                                  style: AppTextStyles.helperText,
                                ),
                                const SizedBox(height: AppSizes.paddingMD),
                                AppTextField(
                                  label: 'Confirm Password',
                                  hint: 'Confirm password',
                                  controller: _confirmPasswordController,
                                  isPassword: true,
                                  textInputAction: TextInputAction.done,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Confirm password';
                                    }
                                    if (v != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSizes.paddingXL),
                                AppPrimaryButton(
                                  text: AppStrings.sendOtp,
                                  height: 46,
                                  borderRadius: 8,
                                  textStyle: AppTextStyles.authButton,
                                  isLoading: state is AuthLoading,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        RegisterSubmitted(
                                          fullName: _nameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          mobile: _mobileController.text.trim(),
                                          password: _passwordController.text,
                                          confirmPassword:
                                              _confirmPasswordController.text,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: AppSizes.paddingMD),
                                Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingMD,
                                      ),
                                      child: Text(
                                        AppStrings.or,
                                        style: AppTextStyles.authSubtitle,
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.paddingSM),
                                Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        AppStrings.alreadyHaveAccount,
                                        style: AppTextStyles.authSubtitle,
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.of(context).pop(),
                                        child: Text(
                                          AppStrings.login,
                                          style: AppTextStyles.authLink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSizes.paddingMD),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
