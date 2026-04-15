import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/form_validation.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../bloc/auth_bloc.dart';
import '../../data/repositories/auth_repository.dart';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _collegeController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedYear;
  String _programType = 'internship';

  final List<String> _departments = [
    'B.Sc Biotechnology',
    'B.Sc Bioinformatics',
    'B.Sc Biochemistry',
    'B.Sc Microbiology',
    'B.Tech Biotechnology',
    'M.Sc Biotechnology',
    'M.Sc Bioinformatics',
    'Other',
  ];

  final List<String> _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'PG 1st Year',
    'PG 2nd Year',
  ];

  static const TextStyle _legacyInputStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle _legacyHintStyle = TextStyle(
    color: AppColors.textHint,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  @override
  void dispose() {
    _collegeController.dispose();
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
            if (state is StudentInfoSuccess) {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: AppSizes.paddingMD),
                      Text(
                        AppStrings.studentInformation,
                        style: AppTextStyles.headingXL,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Please complete your details to continue',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLG),
                      AppTextField(
                        label: 'College Name',
                        hint: 'Enter your college name',
                        controller: _collegeController,
                        labelStyle: AppTextStyles.labelMD,
                        inputStyle: _legacyInputStyle,
                        hintStyle: _legacyHintStyle,
                        validator: FormValidation.validateCollege,
                      ),
                      const SizedBox(height: AppSizes.paddingMD),
                      AppDropdownField<String>(
                        label: 'Department',
                        hint: 'Select department',
                        value: _selectedDepartment,
                        labelStyle: AppTextStyles.labelMD,
                        inputStyle: _legacyInputStyle,
                        hintStyle: _legacyHintStyle,
                        items: _departments
                            .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedDepartment = v),
                        validator: (v) {
                          if (v == null) return 'Select department';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingMD),
                      AppDropdownField<String>(
                        label: 'Year of Study',
                        hint: 'Select year',
                        value: _selectedYear,
                        labelStyle: AppTextStyles.labelMD,
                        inputStyle: _legacyInputStyle,
                        hintStyle: _legacyHintStyle,
                        items: _years
                            .map(
                              (y) => DropdownMenuItem(value: y, child: Text(y)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedYear = v),
                        validator: (v) {
                          if (v == null) return 'Select year of study';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingMD),
                      Text('Program Type', style: AppTextStyles.labelMD),
                      const SizedBox(height: 10),
                      _ProgramTypeCard(
                        title: 'Internship Program',
                        subtitle:
                            'Practical internship-based learning with certification',
                        value: 'internship',
                        groupValue: _programType,
                        onChanged: (v) => setState(() => _programType = v!),
                      ),
                      const SizedBox(height: AppSizes.paddingSM),
                      _ProgramTypeCard(
                        title: 'Course Program',
                        subtitle: 'Online course with quizzes and certificate',
                        value: 'course',
                        groupValue: _programType,
                        onChanged: (v) => setState(() => _programType = v!),
                      ),
                      const SizedBox(height: AppSizes.paddingXL),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: AppPrimaryButton(
              text: AppStrings.continueText,
              height: 52,
              borderRadius: 12,
              isLoading: state is AuthLoading,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                    StudentInfoSubmitted(
                      collegeName: _collegeController.text.trim(),
                      department: _selectedDepartment!,
                      yearOfStudy: _selectedYear!,
                      programType: _programType,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgramTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _ProgramTypeCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingMD,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBackground : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headingSM),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySM),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
