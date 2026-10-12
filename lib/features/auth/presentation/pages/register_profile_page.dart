import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fixa/core/app_state/app_state_cubit.dart';
import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/core/theme/app_colors.dart';
import 'package:fixa/core/theme/app_spacing.dart';
import 'package:fixa/core/theme/app_typography.dart';
import 'package:fixa/features/auth/presentation/cubit/register_profile_cubit.dart';
import 'package:fixa/shared/widgets/app_form_error_text.dart';
import 'package:fixa/shared/widgets/app_form_label.dart';
import 'package:fixa/shared/widgets/app_loading_overlay.dart';
import 'package:fixa/shared/widgets/app_response_modal.dart';
import 'package:fixa/shared/widgets/app_text_field.dart';
import 'package:fixa/shared/widgets/auth_flow_scaffold.dart';
import 'package:fixa/shared/widgets/auth_legal_notice.dart';

class RegisterProfilePage extends StatefulWidget {
  const RegisterProfilePage({super.key, this.sessionToken});

  final String? sessionToken;

  @override
  State<RegisterProfilePage> createState() => _RegisterProfilePageState();
}

class _RegisterProfilePageState extends State<RegisterProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _birthdayController;
  late final TextEditingController _addressController;
  DateTime? _birthday;
  XFile? _profilePicture;
  Uint8List? _profilePictureBytes;

  bool get _hasRequiredFields =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _birthday != null &&
      _addressController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController()..addListener(_handleChanged);
    _lastNameController = TextEditingController()..addListener(_handleChanged);
    _birthdayController = TextEditingController()..addListener(_handleChanged);
    _addressController = TextEditingController()..addListener(_handleChanged);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  Future<void> _pickProfilePicture() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        _profilePicture = pickedImage;
      });

      final bytes = await pickedImage.readAsBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _profilePictureBytes = bytes;
      });

      if (mounted) {
        context.read<RegisterProfileCubit>().clearError();
      }
    } on PlatformException catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open photo library. Please restart the app and try again.',
          ),
        ),
      );
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final latestAllowed = DateTime(now.year - 18, now.month, now.day);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _birthday ?? latestAllowed,
      firstDate: DateTime(1900),
      lastDate: latestAllowed,
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _birthday = selectedDate;
      _birthdayController.text = _formatDisplayDate(selectedDate);
    });

    if (mounted) {
      context.read<RegisterProfileCubit>().clearError();
    }
  }

  String _formatApiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatDisplayDate(DateTime date) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day}${_ordinalSuffix(date.day)} ${months[date.month - 1]} ${date.year}';
  }

  String _ordinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }

    return switch (day % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateCubit>().state;
    final resolvedSessionToken =
        widget.sessionToken ?? appState.registrationSessionToken;

    return BlocConsumer<RegisterProfileCubit, RegisterProfileState>(
      listener: (context, state) async {
        if (state.status == RegisterProfileStatus.loading) {
          AppLoadingOverlay.show(
            context,
            title: 'Finishing your profile',
            subtitle: 'Almost ready to explore Fixa',
          );
          return;
        }

        AppLoadingOverlay.hide();
        if (state.status != RegisterProfileStatus.success) {
          return;
        }

        final message = state.result?.message.trim();
        await showAppResponseModal(
          context,
          message: message != null && message.isNotEmpty
              ? message
              : 'Profile created successfully.',
        );
        if (context.mounted) context.go(AppRoutes.authWelcome);
      },
      builder: (context, state) {
        final canSubmit =
            _hasRequiredFields &&
            !state.isLoading &&
            resolvedSessionToken != null &&
            resolvedSessionToken.trim().isNotEmpty;

        return AuthFlowScaffold(
          buttonLabel: state.isLoading ? 'Saving...' : 'Agree and continue',
          onButtonPressed: canSubmit
              ? () => context.read<RegisterProfileCubit>().registerProfile(
                  sessionToken: resolvedSessionToken.trim(),
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  birthday: _formatApiDate(_birthday!),
                  address: _addressController.text.trim(),
                  profilePicture: _profilePicture,
                )
              : null,
          footerContent: const AuthLegalNotice(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.authHeroHorizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickProfilePicture,
                    child: SizedBox(
                      width: 118,
                      height: 118,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.14,
                                ),
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x20000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: const Color(0xFFF3F6FB),
                              backgroundImage: _profilePictureBytes != null
                                  ? MemoryImage(_profilePictureBytes!)
                                  : null,
                              child: _profilePictureBytes == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFE8EEF7),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person_rounded,
                                            size: 36,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 1,
                            bottom: 1,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Tell us about you',
                  style: AppTypography.authFieldTitle.copyWith(
                    color: AppColors.authText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppFormLabel(text: 'First name', color: AppColors.ink),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _firstNameController,
                  hintText: 'First name',
                  textInputAction: TextInputAction.next,
                  width: AppSpacing.inputWidth,
                  onChanged: (_) =>
                      context.read<RegisterProfileCubit>().clearError(),
                  textStyle: AppTypography.authFieldInput.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const AppFormLabel(text: 'Last name', color: AppColors.ink),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _lastNameController,
                  hintText: 'Last name',
                  textInputAction: TextInputAction.next,
                  width: AppSpacing.inputWidth,
                  onChanged: (_) =>
                      context.read<RegisterProfileCubit>().clearError(),
                  textStyle: AppTypography.authFieldInput.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const AppFormLabel(text: 'Birthday', color: AppColors.ink),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _birthdayController,
                  hintText: 'Birthday',
                  readOnly: true,
                  onTap: _pickBirthday,
                  width: AppSpacing.inputWidth,
                  textStyle: AppTypography.authFieldInput.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: AppSpacing.inputWidth,
                  child: Text(
                    'To sign up, you need to be at least 18. Other people who use AMASS won’t see your birthday.',
                    style: AppTypography.legalNotice.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textFieldBorder,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppFormLabel(text: 'Address', color: AppColors.ink),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _addressController,
                  hintText: 'Enter address',
                  textInputAction: TextInputAction.done,
                  width: AppSpacing.inputWidth,
                  onChanged: (_) =>
                      context.read<RegisterProfileCubit>().clearError(),
                  textStyle: AppTypography.authFieldInput.copyWith(
                    color: AppColors.ink,
                  ),
                  suffixIcon: SizedBox(
                    width: 58,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A400),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                if (state.errorMessage != null &&
                    state.errorMessage!.trim().isNotEmpty)
                  AppFormErrorText(
                    message: state.errorMessage!,
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
