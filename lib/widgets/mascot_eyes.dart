import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MascotEyes extends StatefulWidget {
  final bool isAverted;
  final Offset cursorPosition;

  const MascotEyes({
    super.key, 
    required this.isAverted,
    this.cursorPosition = Offset.zero,
  });

  @override
  State<MascotEyes> createState() => _MascotEyesState();
}

class _MascotEyesState extends State<MascotEyes> {
  final GlobalKey _containerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      duration: const Duration(milliseconds: 300),
      turns: widget.isAverted ? -0.05 : 0,
      child: AnimatedContainer(
        key: _containerKey,
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(widget.isAverted ? -20 : 0, 0, 0),
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD509), // FFD509 Yellow
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Stack(
          children: [
            _buildEye(left: 65, isAverted: widget.isAverted, isRightEye: false),
            _buildEye(left: 185, isAverted: widget.isAverted, isRightEye: true),
          ],
        ),
      ),
    );
  }

  Widget _buildEye({required double left, required bool isAverted, required bool isRightEye}) {
    double xOffset = 0;
    double yOffset = 0;

    if (isAverted) {
      xOffset = isRightEye ? 0 : 25; 
      yOffset = 10;
    } else {
      final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final size = renderBox.size;
        final localPos = renderBox.globalToLocal(widget.cursorPosition);
        
        // Normalized position (-1 to 1) relative to center of the mascot
        double dx = (localPos.dx / size.width * 2) - 1;
        double dy = (localPos.dy / size.height * 2) - 1;

        // Horizontal range is 25px. Center is 12.5.
        xOffset = 12.5 + (dx * 12.5);
        // Vertical range is 20px. Center is 10.
        yOffset = 10 + (dy * 10);
      } else {
        xOffset = 12.5;
        yOffset = 10;
      }
    }

    // Constrain offsets to keep white box inside
    xOffset = xOffset.clamp(0.0, 25.0);
    yOffset = yOffset.clamp(0.0, 20.0);

    return Positioned(
      left: left,
      top: 70,
      child: Container(
        width: 50,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Stack(
          children: [
            // Layer 1: Background Segments (Black & Blue)
            Column(
              children: [
                Expanded(child: Container(color: const Color(0xFF010813))), // eyeDark
                Expanded(child: Container(color: AppColors.loginNavyDark)), // eyeAccent
              ],
            ),
            // Layer 2: The White Inner Eye (Stacked in front)
            Positioned(
              top: yOffset,
              left: xOffset,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 25,
                height: 80, 
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
