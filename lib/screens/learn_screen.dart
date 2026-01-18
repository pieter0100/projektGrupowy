import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/utils/constants.dart';
import 'package:projekt_grupowy/widgets/learn_widget.dart';
import 'package:projekt_grupowy/widgets/learn_info_widget.dart';

class LearnScreen extends StatelessWidget {
  final String? level;

  const LearnScreen({super.key, this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/level'),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Learn'),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        scrolledUnderElevation: 0.0,
      ),
      body: ListView(
        children: [
          SizedBox(height: AppSizes.screenPaddingTop),
          Center(child: LearnInfoWidget("× $level")),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LearnWidget("intro"),
              SizedBox(height: AppSizes.spacingSmall),
              Text("Intro", style: TextStyle(fontSize: AppSizes.settingsFontSize)),
              SizedBox(height: AppSizes.spacingMedium),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // MENUANCHOR for testing purpose TODO after clicking set random type of game
              MenuAnchor(
                // Menu elements
                menuChildren: [
                  MenuItemButton(
                    child: const Text('Memory tryb'),
                    onPressed: () {
                      context.go('/level/learn/practice?level=$level');
                    },
                  ),
                  MenuItemButton(
                    child: const Text('MC tryb'),
                    onPressed: () {
                      context.push('/level/learn/practice/MC?level=$level');
                    },
                  ),
                  MenuItemButton(
                    child: const Text('Typed answer tryb'),
                    onPressed: () {
                      context.push(
                        '/level/learn/practice/typedAnswer?level=$level',
                      );
                    },
                  ),
                ],
                // Practice widget
                builder:
                    (
                      BuildContext context,
                      MenuController controller,
                      Widget? child,
                    ) {
                      return GestureDetector(
                        onTap: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },

                        child: LearnWidget("practice"),
                      );
                    },
              ),
              SizedBox(height: AppSizes.spacingSmall),
              Text("Practice", style: TextStyle(fontSize: AppSizes.settingsFontSize)),
              SizedBox(height: AppSizes.spacingMedium),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LearnWidget("exam"),
              SizedBox(height: AppSizes.spacingSmall),
              Text("Exam", style: TextStyle(fontSize: AppSizes.settingsFontSize)),
              SizedBox(height: AppSizes.spacingMedium),
            ],
          ),
        ],
      ),
    );
  }
}
