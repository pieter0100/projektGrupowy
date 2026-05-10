import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:projekt_grupowy/utils/constants.dart';
import '../controllers/app_session_controller.dart';

class SettingsSignOutWidget extends StatefulWidget {
  final String textInside;

  const SettingsSignOutWidget(this.textInside, {super.key});

  @override
  State<SettingsSignOutWidget> createState() => _SettingsSignOutWidgetState();
}

class _SettingsSignOutWidgetState extends State<SettingsSignOutWidget> {
  bool _isSigningOut = false;

  Future<void> _handleSignOut() async {
    try {
      final sessionController = context.read<AppSessionController>();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Your progress will be synced before signing out. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                
                setState(() {
                  _isSigningOut = true;
                });

                try {
                  // This will sync pending data to Firestore before signing out
                  await sessionController.signOut();
                  
                  // Navigate to login screen after successful sign out
                  if (mounted) {
                    context.go('/login');
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _isSigningOut = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign out failed: $e')),
                    );
                  }
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error in _handleSignOut: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isSigningOut ? null : _handleSignOut,
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
                  Icons.logout,
                  color: AppColors.navHome,
                  size: AppSizes.iconMedium,
                ),
                const SizedBox(width: AppSizes.settingsIconGap),
                Text(
                  widget.textInside,
                  style: AppTextStyles.settingsLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
