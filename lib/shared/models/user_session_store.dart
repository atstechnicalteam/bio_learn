import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_models.dart';

class UserSessionState {
  const UserSessionState({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.collegeName,
    required this.department,
    required this.yearOfStudy,
    required this.programType,
  });

  factory UserSessionState.initial() {
    return const UserSessionState(
      fullName: '',
      email: '',
      mobile: '',
      collegeName: '',
      department: '',
      yearOfStudy: '',
      programType: '',
    );
  }

  factory UserSessionState.fromJson(Map<String, dynamic> json) {
    return UserSessionState(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      collegeName: json['collegeName'] as String? ?? '',
      department: json['department'] as String? ?? '',
      yearOfStudy: json['yearOfStudy'] as String? ?? '',
      programType: json['programType'] as String? ?? '',
    );
  }

  final String fullName;
  final String email;
  final String mobile;
  final String collegeName;
  final String department;
  final String yearOfStudy;
  final String programType;

  String get displayName => fullName.trim().isNotEmpty ? fullName.trim() : 'Learner';

  UserSessionState copyWith({
    String? fullName,
    String? email,
    String? mobile,
    String? collegeName,
    String? department,
    String? yearOfStudy,
    String? programType,
  }) {
    return UserSessionState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      collegeName: collegeName ?? this.collegeName,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      programType: programType ?? this.programType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'collegeName': collegeName,
      'department': department,
      'yearOfStudy': yearOfStudy,
      'programType': programType,
    };
  }
}

class _PendingRegistrationState {
  const _PendingRegistrationState({
    required this.fullName,
    required this.email,
    required this.mobile,
  });

  factory _PendingRegistrationState.empty() {
    return const _PendingRegistrationState(
      fullName: '',
      email: '',
      mobile: '',
    );
  }

  factory _PendingRegistrationState.fromJson(Map<String, dynamic> json) {
    return _PendingRegistrationState(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
    );
  }

  final String fullName;
  final String email;
  final String mobile;

  bool get hasValue =>
      fullName.trim().isNotEmpty ||
      email.trim().isNotEmpty ||
      mobile.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
    };
  }
}

class UserSessionStore {
  UserSessionStore._();

  static final UserSessionStore instance = UserSessionStore._();

  static const String _sessionKey = 'user_session_store.current_user';
  static const String _pendingKey = 'user_session_store.pending_registration';

  final ValueNotifier<UserSessionState> state =
      ValueNotifier(UserSessionState.initial());

  SharedPreferences? _preferences;
  bool _initialized = false;
  _PendingRegistrationState _pending = _PendingRegistrationState.empty();

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    _preferences = await SharedPreferences.getInstance();

    final rawSession = _preferences!.getString(_sessionKey);
    if (rawSession != null && rawSession.isNotEmpty) {
      final decoded = jsonDecode(rawSession);
      if (decoded is Map) {
        state.value = UserSessionState.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    }

    final rawPending = _preferences!.getString(_pendingKey);
    if (rawPending != null && rawPending.isNotEmpty) {
      final decoded = jsonDecode(rawPending);
      if (decoded is Map) {
        _pending = _PendingRegistrationState.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    }

    _initialized = true;
  }

  Future<void> savePendingRegistration({
    required String fullName,
    required String email,
    required String mobile,
  }) async {
    await ensureInitialized();
    _pending = _PendingRegistrationState(
      fullName: fullName.trim(),
      email: email.trim(),
      mobile: mobile.trim(),
    );
    await _preferences!.setString(_pendingKey, jsonEncode(_pending.toJson()));
  }

  Future<UserSessionState> saveUser(UserModel user) async {
    await ensureInitialized();

    final current = state.value;
    final pendingMatchesMobile =
        _pending.hasValue &&
        (_pending.mobile.isEmpty || _pending.mobile == user.mobile);
    final currentMatchesMobile =
        current.mobile.isNotEmpty && current.mobile == user.mobile;

    final nextState = UserSessionState(
      fullName: user.fullName.trim().isNotEmpty
          ? user.fullName.trim()
          : pendingMatchesMobile
              ? _pending.fullName
              : currentMatchesMobile
                  ? current.fullName
                  : '',
      email: user.email.trim().isNotEmpty
          ? user.email.trim()
          : pendingMatchesMobile
              ? _pending.email
              : currentMatchesMobile
                  ? current.email
                  : '',
      mobile: user.mobile.trim(),
      collegeName: user.collegeName?.trim().isNotEmpty == true
          ? user.collegeName!.trim()
          : currentMatchesMobile
              ? current.collegeName
              : '',
      department: user.department?.trim().isNotEmpty == true
          ? user.department!.trim()
          : currentMatchesMobile
              ? current.department
              : '',
      yearOfStudy: user.yearOfStudy?.trim().isNotEmpty == true
          ? user.yearOfStudy!.trim()
          : currentMatchesMobile
              ? current.yearOfStudy
              : '',
      programType: user.programType?.trim().isNotEmpty == true
          ? user.programType!.trim()
          : currentMatchesMobile
              ? current.programType
              : '',
    );

    state.value = nextState;
    await _preferences!.setString(_sessionKey, jsonEncode(nextState.toJson()));
    _pending = _PendingRegistrationState.empty();
    await _preferences!.remove(_pendingKey);
    return nextState;
  }

  Future<void> updateStudentInfo({
    required String collegeName,
    required String department,
    required String yearOfStudy,
    required String programType,
  }) async {
    await ensureInitialized();
    final nextState = state.value.copyWith(
      collegeName: collegeName.trim(),
      department: department.trim(),
      yearOfStudy: yearOfStudy.trim(),
      programType: programType.trim(),
    );
    state.value = nextState;
    await _preferences!.setString(_sessionKey, jsonEncode(nextState.toJson()));
  }

  String fallbackNameForMobile(String mobile) {
    final trimmedMobile = mobile.trim();
    if (state.value.mobile == trimmedMobile &&
        state.value.fullName.trim().isNotEmpty) {
      return state.value.fullName.trim();
    }
    if (_pending.mobile == trimmedMobile && _pending.fullName.trim().isNotEmpty) {
      return _pending.fullName.trim();
    }
    return '';
  }

  Future<void> clear() async {
    await ensureInitialized();
    state.value = UserSessionState.initial();
    _pending = _PendingRegistrationState.empty();
    await _preferences!.remove(_sessionKey);
    await _preferences!.remove(_pendingKey);
  }
}
