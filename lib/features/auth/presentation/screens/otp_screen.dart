import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/auth_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'student_info_screen.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  const OtpScreen({super.key, required this.mobile});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      ['1', '2', '3', '4'].map((digit) => TextEditingController(text: digit)).toList();
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 59;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }
// Timer logic to handle resend OTP cooldown
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

  String get _otp =>
      _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
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
                MaterialPageRoute(
                  builder: (_) => const StudentInfoScreen(),
                ),
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
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: AppColors.textPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    Text(
                      AppStrings.verifyAccount,
                      style: AppTextStyles.headingLG.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSM),
                    const Text(
                      'Please enter the 4-digit code sent to',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+91 ${widget.mobile}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    // OTP boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(4, (i) {
                        final isFocused = i == _controllers
                            .indexWhere((c) => c.text.isEmpty);
                        return Padding(
                          padding: EdgeInsets.only(right: i < 3 ? 16 : 0),
                          child: _OtpBox(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            isActive: _controllers[i].text.isNotEmpty ||
                                (i > 0 && _controllers[i - 1].text.isNotEmpty),
                            onChanged: (val) {
                              if (val.isNotEmpty && i < 3) {
                                _focusNodes[i + 1].requestFocus();
                              } else if (val.isEmpty && i > 0) {
                                _focusNodes[i - 1].requestFocus();
                              }
                              setState(() {});
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    AppPrimaryButton(
                      text: AppStrings.verifyAndContinue,
                      isLoading: state is AuthLoading,
                      onPressed: _otp.length == 4
                          ? () {
                              context.read<AuthBloc>().add(
                                    OtpVerified(
                                      mobile: widget.mobile,
                                      otp: _otp,
                                    ),
                                  );
                            }
                          : null,
                    ),
                    const SizedBox(height: AppSizes.paddingMD),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Didn't receive code? ",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: _canResend
                              ? () {
                                  context.read<AuthBloc>().add(
                                        ResendOtpRequested(mobile: widget.mobile),
                                      );
                                }
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
                        if (!_canResend) ...[
                          const SizedBox(width: 4),
                          Text(
                            _timerText,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: isActive ? AppColors.cardBackground : AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
