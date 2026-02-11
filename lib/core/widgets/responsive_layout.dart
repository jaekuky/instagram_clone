import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget? webLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    this.webLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
          return webLayout ?? tabletLayout ?? mobileLayout;
        } else if (constraints.maxWidth >= AppConstants.mobileBreakpoint) {
          return tabletLayout ?? mobileLayout;
        }
        return mobileLayout;
      },
    );
  }
}
