import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable gradient scaffold used across all screens except Landing.
/// Provides a consistent dark linear gradient background flowing
/// from deep midnight navy at the top to pure black at the bottom,
/// with a glassmorphic frosted AppBar.
class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: appBar != null
          ? PreferredSize(
              preferredSize: appBar!.preferredSize,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF031628).withOpacity(0.5),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.04),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: appBar,
                  ),
                ),
              ),
            )
          : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF031628), // deep midnight navy
              Color(0xFF010A13), // near-black navy
              Color(0xFF000000), // pure black
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: body,
      ),
    );
  }
}
