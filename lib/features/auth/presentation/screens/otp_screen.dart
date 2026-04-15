import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/auth_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'student_info_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  void _verifyOtp(BuildContext context) {
    if (_otp.length < 4) return;
    context.read<AuthBloc>().add(OtpVerified(email: widget.email, otp: _otp));
  }

  void _resendOtp(BuildContext context) {
    if (!_canResend) return;
    context.read<AuthBloc>().add(ResendOtpRequested(email: widget.email));
  }
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 59;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 59;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining <= 0) {
        t.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _secondsRemaining--);
      }
    });
  }

  String get _timerText {
    final mins = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '($mins:$secs)';
  }

  String get _otp => _controllers.map((c) => c.text).join();

  int get _activeIndex {
    final nextEmptyIndex = _controllers.indexWhere((c) => c.text.isEmpty);
    return nextEmptyIndex == -1 ? _controllers.length - 1 : nextEmptyIndex;
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
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
            if (state is OtpVerifiedSuccess) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudentInfoScreen()),
              );
            } else if (state is OtpSentSuccess) {
              _startTimer();
              showSuccessSnackBar(context, 'OTP sent successfully');
            } else if (state is AuthError) {
              showErrorSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentTopSpacing = AppSizes.paddingLG;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingMD),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - (AppSizes.paddingMD * 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundGrey,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMD,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingMD),
                          Text(
                            AppStrings.verifyAccount,
                            style: AppTextStyles.headingXL.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: contentTopSpacing),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Please enter the 4-digit code sent to',
                                    style: AppTextStyles.bodyLG.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.paddingXS),
                                  Text(
                                    widget.email,
                                    style: AppTextStyles.headingSM.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.paddingXL),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 18,
                                    children: List.generate(4, (i) {
                                      return _OtpBox(
                                        controller: _controllers[i],
                                        focusNode: _focusNodes[i],
                                        isActive:
                                            i == _activeIndex ||
                                            _controllers[i].text.isNotEmpty,
                                        onChanged: (val) {
                                          if (val.isNotEmpty && i < 3) {
                                            _focusNodes[i + 1].requestFocus();
                                          } else if (val.isEmpty && i > 0) {
                                            _focusNodes[i - 1].requestFocus();
                                          } else {
                                            focusNodeUnfocusIfLast(i, val);
                                          }
                                          if (_otp.length == 4) {
                                            _verifyOtp(context);
                                          }
                                          setState(() {});
                                        },
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: AppSizes.paddingXL),
                                  AppPrimaryButton(
                                    text: AppStrings.verifyAndContinue,
                                    isLoading: state is AuthLoading,
                                    onPressed: _otp.length == 4
                                        ? () => _verifyOtp(context)
                                        : null,
                                  ),
                                  const SizedBox(height: AppSizes.paddingLG),
                                  Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 4,
                                      children: [
                                        const Text(
                                          "Didn't receive code?",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _canResend
                                              ? () => _resendOtp(context)
                                              : null,
                                          child: Text(
                                            AppStrings.resend,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: _canResend
                                                  ? AppColors.primary
                                                  : AppColors.textHint,
                                            ),
                                          ),
                                        ),
                                        if (!_canResend)
                                          Text(
                                            _timerText,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  void focusNodeUnfocusIfLast(int index, String value) {
    if (index == _focusNodes.length - 1 && value.isNotEmpty) {
      _focusNodes[index].unfocus();
    }
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isActive ? AppColors.cardBackground : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
          width: isActive ? 2 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        cursorColor: AppColors.primary,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.0,
        ),
        decoration: const InputDecoration(
          counterText: '',
          isCollapsed: true,
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}