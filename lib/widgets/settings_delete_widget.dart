import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'package:projekt_grupowy/utils/constants.dart';
import 'package:projekt_grupowy/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:projekt_grupowy/controllers/app_session_controller.dart';

class SettingsDeleteWidget extends StatefulWidget {
  final String textInside;

  const SettingsDeleteWidget(this.textInside, {super.key});

  @override
  State<SettingsDeleteWidget> createState() => _SettingsDeleteWidgetState();
}

class _SettingsDeleteWidgetState extends State<SettingsDeleteWidget> {
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();
  bool _isDeleting = false;

  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => _DeleteAccountDialog(
        onConfirm: (password) async {
          if (!mounted) return;

          setState(() {
            _isDeleting = true;
          });

          try {
            // Re-authenticate user
            _logger.i('Re-authenticating user...');
            await _authService.reauthenticateUser(password);
            _logger.i('Re-authentication successful');

            // Delete account
            _logger.i('Deleting account...');
            final syncService = Provider.of<AppSessionController>(context, listen: false).syncService;
            await _authService.deleteAccount(syncService);
            _logger.i('Account deleted successfully');

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Account deleted successfully. Redirecting to login...',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );

              // Navigate to login after brief delay
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                context.go('/login');
              }
            }
          } catch (e) {
            if (mounted) {
              final errorMessage = e.toString().replaceAll('Exception: ', '');
              _logger.e('❌ Account deletion error');
              _logger.e('Full error object: $e');
              _logger.e('Error message: $errorMessage');
              _logger.e('Error type: ${e.runtimeType}');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $errorMessage'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                _isDeleting = false;
              });
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isDeleting ? null : _showDeleteDialog,
      borderRadius: BorderRadius.circular(AppSizes.settingsRadius),
      child: Container(
        width: AppSizes.settingsWidth,
        height: AppSizes.settingsHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: AppColors.settingsBorder,
            width: AppSizes.settingsBorderWidth,
          ),
          borderRadius: BorderRadius.circular(AppSizes.settingsRadius),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: AppSizes.settingsPaddingLeft),
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  color: AppColors.black,
                  size: AppSizes.iconMedium,
                ),
                const SizedBox(width: AppSizes.settingsIconGap),
                Text(widget.textInside, style: AppTextStyles.settingsLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for confirming account deletion with password re-authentication
class _DeleteAccountDialog extends StatefulWidget {
  final Function(String password) onConfirm;

  const _DeleteAccountDialog({required this.onConfirm});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleConfirm() async {
    final password = _passwordController.text;

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onConfirm(password);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.red, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text('Delete Account?', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your account data, progress, and results will be permanently deleted.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              'To confirm, please enter your password:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Delete Account'),
        ),
      ],
    );
  }
}
