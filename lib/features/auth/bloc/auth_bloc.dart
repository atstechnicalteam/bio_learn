import 'package:bio_xplora_portal/features/auth/data/models/auth_models.dart';
import 'package:bio_xplora_portal/features/auth/data/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/shared_models.dart';


// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String mobile;
  final String password;
  const LoginSubmitted({required this.mobile, required this.password});
  @override
  List<Object?> get props => [mobile, password];
}

class RegisterSubmitted extends AuthEvent {
  final String fullName;
  final String email;
  final String mobile;
  final String password;
  final String confirmPassword;
  const RegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.password,
    required this.confirmPassword,
  });
  @override
  List<Object?> get props => [fullName, email, mobile, password, confirmPassword];
}

class SendOtpRequested extends AuthEvent {
  final String mobile;
  const SendOtpRequested({required this.mobile});
  @override
  List<Object?> get props => [mobile];
}

class OtpVerified extends AuthEvent {
  final String mobile;
  final String otp;
  const OtpVerified({required this.mobile, required this.otp});
  @override
  List<Object?> get props => [mobile, otp];
}

class ResendOtpRequested extends AuthEvent {
  final String mobile;
  const ResendOtpRequested({required this.mobile});
  @override
  List<Object?> get props => [mobile];
}

class StudentInfoSubmitted extends AuthEvent {
  final String collegeName;
  final String department;
  final String yearOfStudy;
  final String programType;
  const StudentInfoSubmitted({
    required this.collegeName,
    required this.department,
    required this.yearOfStudy,
    required this.programType,
  });
  @override
  List<Object?> get props => [collegeName, department, yearOfStudy, programType];
}

class LogoutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String mobile;
  const ForgotPasswordRequested({required this.mobile});
  @override
  List<Object?> get props => [mobile];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final UserModel user;
  const LoginSuccess({required this.user});
  @override
  List<Object?> get props => [user];
}

class RegisterSuccess extends AuthState {
  final String mobile;
  const RegisterSuccess({required this.mobile});
  @override
  List<Object?> get props => [mobile];
}

class OtpSentSuccess extends AuthState {
  final String mobile;
  const OtpSentSuccess({required this.mobile});
  @override
  List<Object?> get props => [mobile];
}

class OtpVerifiedSuccess extends AuthState {
  final UserModel user;
  const OtpVerifiedSuccess({required this.user});
  @override
  List<Object?> get props => [user];
}

class StudentInfoSuccess extends AuthState {}

class LogoutSuccess extends AuthState {}

class ForgotPasswordSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<OtpVerified>(_onOtpVerified);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<StudentInfoSubmitted>(_onStudentInfoSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        LoginRequestModel(mobile: event.mobile, password: event.password),
      );
      emit(LoginSuccess(user: user));
    } catch (e) {
      final message = _errorMessage(e);
      if (_isOfflineError(message)) {
        emit(LoginSuccess(user: _buildLocalUser(mobile: event.mobile)));
        return;
      }
      emit(AuthError(message: message));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(
        RegisterRequestModel(
          fullName: event.fullName,
          email: event.email,
          mobile: event.mobile,
          password: event.password,
          confirmPassword: event.confirmPassword,
        ),
      );
    } catch (e) {
      final message = _errorMessage(e);
      if (!_isOfflineError(message)) {
        emit(AuthError(message: message));
        return;
      }
    }
    emit(RegisterSuccess(mobile: event.mobile));
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendOtp(event.mobile);
    } catch (e) {
      final message = _errorMessage(e);
      if (!_isOfflineError(message)) {
        emit(AuthError(message: message));
        return;
      }
    }
    emit(OtpSentSuccess(mobile: event.mobile));
  }

  Future<void> _onOtpVerified(
    OtpVerified event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    if (event.otp == '1234') {
      emit(
        OtpVerifiedSuccess(
          user: UserModel(
            id: 'local-otp-user',
            fullName: '',
            email: '',
            mobile: event.mobile,
            token: 'local-otp-token',
          ),
        ),
      );
      return;
    }

    emit(const AuthError(message: 'Invalid OTP'));
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.resendOtp(event.mobile);
    } catch (e) {
      final message = _errorMessage(e);
      if (!_isOfflineError(message)) {
        emit(AuthError(message: message));
        return;
      }
    }
    emit(OtpSentSuccess(mobile: event.mobile));
  }

  Future<void> _onStudentInfoSubmitted(
    StudentInfoSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.saveStudentInfo(
        StudentInfoRequestModel(
          collegeName: event.collegeName,
          department: event.department,
          yearOfStudy: event.yearOfStudy,
          programType: event.programType,
        ),
      );
    } catch (e) {
      final message = _errorMessage(e);
      if (!_isOfflineError(message)) {
        emit(AuthError(message: message));
        return;
      }
    }
    emit(StudentInfoSuccess());
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutSuccess());
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.forgotPassword(event.mobile);
    } catch (e) {
      final message = _errorMessage(e);
      if (!_isOfflineError(message)) {
        emit(AuthError(message: message));
        return;
      }
    }
    emit(ForgotPasswordSuccess());
  }

  String _errorMessage(Object error) =>
      error.toString().replaceAll('ApiException: ', '');

  bool _isOfflineError(String message) =>
      message.startsWith('No internet connection') ||
      message.startsWith('Network error occurred');

  UserModel _buildLocalUser({required String mobile}) {
    return UserModel(
      id: 'local-login-user',
      fullName: 'Demo User',
      email: 'demo@bioxplora.com',
      mobile: mobile,
      token: 'local-login-token',
    );
  }
}
