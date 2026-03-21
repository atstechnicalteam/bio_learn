class LoginRequestModel {
  final String mobile;
  final String password;

  LoginRequestModel({required this.mobile, required this.password});

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
        'password': password,
      };
}

class RegisterRequestModel {
  final String fullName;
  final String email;
  final String mobile;
  final String password;
  final String confirmPassword;

  RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'email': email,
        'mobile': mobile,
        'password': password,
        'confirm_password': confirmPassword,
      };
}

class OtpRequestModel {
  final String mobile;
  final String otp;

  OtpRequestModel({required this.mobile, required this.otp});

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
        'otp': otp,
      };
}

class StudentInfoRequestModel {
  final String collegeName;
  final String department;
  final String yearOfStudy;
  final String programType;

  StudentInfoRequestModel({
    required this.collegeName,
    required this.department,
    required this.yearOfStudy,
    required this.programType,
  });

  Map<String, dynamic> toJson() => {
        'college_name': collegeName,
        'department': department,
        'year_of_study': yearOfStudy,
        'program_type': programType,
      };
}
