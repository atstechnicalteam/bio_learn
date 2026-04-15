import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/form_validation.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../bloc/auth_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
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
            if (state is LoginSuccess) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
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
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.authOutline,
                                width: 1.1,
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Center(
                                    child: BioxploraLogoWidget(logoWidth: 150),
                                  ),
                                  const SizedBox(height: 28),
                                  Text(
                                    AppStrings.login,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.authTitle,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Enter your credentials to securely access',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.authSubtitle,
                                  ),
                                  const SizedBox(height: 28),
                                  AppTextField(
                                    label: AppStrings.mobileNumber,
                                    hint: '9876543210',
                                    controller: _mobileController,
                                    isPhone: true,
                                    validator: FormValidation.validatePhone,
                                  ),
                                  const SizedBox(height: AppSizes.paddingMD),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppStrings.password,
                                            style: AppTextStyles.formLabel,
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              AppStrings.forgotPassword,
                                              style: AppTextStyles.authLink
                                                  .copyWith(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        textInputAction: TextInputAction.done,
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return 'Enter password';
                                          }
                                          return null;
                                        },
                                        style: AppTextStyles.formInput,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter your password',
                                          hintStyle: AppTextStyles.formHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 94),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.textPrimary
                                              .withValues(alpha: 0.16),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: AppPrimaryButton(
                                      text: AppStrings.login,
                                      height: 46,
                                      borderRadius: 8,
                                      textStyle: AppTextStyles.authButton,
                                      isLoading: state is AuthLoading,
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<AuthBloc>().add(
                                            LoginSubmitted(
                                              mobile: _mobileController.text
                                                  .trim(),
                                              password:
                                                  _passwordController.text,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 28),
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
                                  const SizedBox(height: 28),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        AppStrings.newToBioxplora,
                                        style: AppTextStyles.authSubtitle,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          AppStrings.createAccount,
                                          style: AppTextStyles.authLink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
