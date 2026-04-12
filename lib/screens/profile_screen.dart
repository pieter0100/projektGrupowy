import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'package:projekt_grupowy/utils/constants.dart';
import 'package:projekt_grupowy/services/auth_service.dart';
import 'package:projekt_grupowy/services/offline_store.dart';
import 'package:hive/hive.dart';
import '../game_logic/models/game_result.dart';
import '../game_logic/models/game_progress.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();
  bool _isDeleting = false;

  Future<void> _handleDeleteAccount(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => _DeleteAccountDialog(
        onConfirm: (password) async {
          try {
            setState(() {
              _isDeleting = true;
            });

            // Step 1: Re-authenticate user
            _logger.i('Re-authenticating user for account deletion...');
            await _authService.reauthenticateUser(password);

            if (!mounted) return;

            // Step 2: Delete local cache
            _logger.i('Clearing local offline cache...');
            final resultsBox = await Hive.openBox<GameResult>('results');
            final progressBox = await Hive.openBox<GameProgress>('progress');
            final offlineStore = OfflineStore(resultsBox, progressBox);
            await offlineStore.clearAllData();

            if (!mounted) return;

            // Step 3: Delete account (triggers Cloud Function cleanup)
            _logger.i(
              'Deleting Firebase Auth user and triggering data cleanup...',
            );
            await _authService.deleteAccount();

            if (!mounted) return;

            // Success: Show success message and navigate to login
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        scrolledUnderElevation: 0.0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Settings Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Delete Account Button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Permanently delete your account and all data',
              ),
              enabled: !_isDeleting,
              onTap: _isDeleting ? null : () => _handleDeleteAccount(context),
            ),
          ),

          const SizedBox(height: 24),

          // Warning Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Deleting your account is permanent and cannot be undone. All your data will be erased.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
