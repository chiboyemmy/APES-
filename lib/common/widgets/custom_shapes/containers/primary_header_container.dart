import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import '../curved_edges/curved_edges_widget.dart';
import 'circular_container.dart';

/// A container widget with a primary color background and curved edges.
class TPrimaryHeaderContainer extends StatelessWidget {
  /// Create a container with a primary color background and curved edges.
  ///
  /// Parameters:
  ///   - child: The widget to be placed inside the container.
  const TPrimaryHeaderContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TCurvedEdgesWidget(
      child: Container(
        color: TColors.primary,
        padding: const EdgeInsets.only(bottom: 0),

        /// -- If [size.isFinite': is not true.in Stack] error occurred -> Read README.md file at [DESIGN ERRORS] # 1
        child: Stack(
          children: [
            /// -- Background Custom Shapes
            Positioned(
                top: -150,
                right: -250,
                child: TCircularContainer(
                    backgroundColor: TColors.textWhite.withValues(alpha: 0.1))),
            Positioned(
                top: 100,
                right: -300,
                child: TCircularContainer(
                    backgroundColor: TColors.textWhite.withValues(alpha: 0.1))),
            child,
          ],
        ),
      ),
    );
  }
}
