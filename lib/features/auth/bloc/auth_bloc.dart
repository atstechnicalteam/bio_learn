import 'package:bio_xplora_portal/features/auth/data/models/auth_models.dart';
import 'package:bio_xplora_portal/features/auth/data/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/shared_models.dart';
import '../../../../shared/models/user_session_store.dart';


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
  final String email;
  const SendOtpRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

class OtpVerified extends AuthEvent {
  final String email;
  final String otp;
  const OtpVerified({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}

class ResendOtpRequested extends AuthEvent {
  final String email;
  const ResendOtpRequested({required this.email});
  @override
  List<Object?> get props => [email];
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
  final String email;
  const RegisterSuccess({required this.email});
  @override
  List<Object?> get props => [email];
}

class OtpSentSuccess extends AuthState {
  final String email;
  const OtpSentSuccess({required this.email});
  @override
  List<Object?> get props => [email];
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
      final session = await UserSessionStore.instance.saveUser(user);
      emit(LoginSuccess(user: _userWithSession(user, session)));
    } catch (e) {
      final message = _errorMessage(e);
      if (_isOfflineError(message)) {
        final localUser = await _buildLocalUser(mobile: event.mobile);
        emit(LoginSuccess(user: localUser));
        return;
      }
      emit(AuthError(message: message));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await UserSessionStore.instance.savePendingRegistration(
      fullName: event.fullName,
      email: event.email,
      mobile: event.mobile,
    );
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
      emit(RegisterSuccess(email: event.email));
    } catch (e) {
      final message = _errorMessage(e);
      if (!_isOfflineError(message)) {
        emit(AuthError(message: message));
        return;
      }
      emit(RegisterSuccess(email: event.email));
    }
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendOtp(event.email);
      emit(OtpSentSuccess(email: event.email));
    } catch (e) {
      emit(AuthError(message: _errorMessage(e)));
    }
  }

  Future<void> _onOtpVerified(
    OtpVerified event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.verifyOtp(
        OtpRequestModel(email: event.email, otp: event.otp),
      );
      final session = await UserSessionStore.instance.saveUser(user);
      emit(OtpVerifiedSuccess(user: _userWithSession(user, session)));
    } catch (e) {
      final message = _errorMessage(e);
      if (_isOfflineError(message)) {
        final localUser = await _buildLocalUser(email: event.email);
        emit(OtpVerifiedSuccess(user: localUser));
        return;
      }
      emit(AuthError(message: message));
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.resendOtp(event.email);
      emit(OtpSentSuccess(email: event.email));
    } catch (e) {
      emit(AuthError(message: _errorMessage(e)));
    }
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
    await UserSessionStore.instance.updateStudentInfo(
      collegeName: event.collegeName,
      department: event.department,
      yearOfStudy: event.yearOfStudy,
      programType: event.programType,
    );
    emit(StudentInfoSuccess());
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      await UserSessionStore.instance.clear();
      emit(LogoutSuccess());
    } catch (e) {
      await UserSessionStore.instance.clear();
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

  Future<UserModel> _buildLocalUser({String email = '', String mobile = ''}) async {
    final user = UserModel(
      id: 'local-login-user',
      fullName: 'Learner',
      email: email,
      mobile: mobile,
      token: 'local-login-token',
    );
    final session = await UserSessionStore.instance.saveUser(user);
    return _userWithSession(user, session);
  }

  UserModel _userWithSession(UserModel user, UserSessionState session) {
    return UserModel(
      id: user.id,
      fullName: session.fullName,
      email: session.email,
      mobile: session.mobile,
      profileImage: user.profileImage,
      collegeName: session.collegeName,
      department: session.department,
      yearOfStudy: session.yearOfStudy,
      programType: session.programType,
      token: user.token,
    );
  }
}
