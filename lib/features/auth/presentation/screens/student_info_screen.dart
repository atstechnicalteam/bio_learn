import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/auth_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../home/presentation/screens/home_screen.dart';

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
    'B.Sc Biotechnology', 'B.Sc Bioinformatics', 'B.Sc Biochemistry',
    'B.Sc Microbiology', 'B.Tech Biotechnology', 'M.Sc Biotechnology',
    'M.Sc Bioinformatics', 'Other',
  ];

  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year', 'PG 1st Year', 'PG 2nd Year'];

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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            AppStrings.studentInformation,
                            style: AppTextStyles.screenTitle,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Please complete your details to continue',
                            style: AppTextStyles.authSubtitle,
                          ),
                          const SizedBox(height: 22),
                          AppTextField(
                            label: 'College Name',
                            hint: 'Enter your college name',
                            controller: _collegeController,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter college name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.paddingMD),
                          AppDropdownField<String>(
                            label: 'Department',
                            hint: 'Select department',
                            value: _selectedDepartment,
                            items: _departments
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                            onChanged:
                                (v) => setState(() => _selectedDepartment = v),
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
                            items: _years
                                .map(
                                  (y) => DropdownMenuItem(
                                    value: y,
                                    child: Text(y),
                                  ),
                                )
                                .toList(),
                            onChanged:
                                (v) => setState(() => _selectedYear = v),
                            validator: (v) {
                              if (v == null) return 'Select year of study';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.paddingMD),
                          Text(
                            'Program Type',
                            style: AppTextStyles.formLabel,
                          ),
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
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AppPrimaryButton(
                  text: AppStrings.continueText,
                  height: 46,
                  borderRadius: 8,
                  textStyle: AppTextStyles.authButton,
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.2 : 1,
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
                  Text(
                    title,
                    style: AppTextStyles.formLabel.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.helperText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
