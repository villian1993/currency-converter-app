import 'package:flutter/material.dart';

class GradientDivider extends StatelessWidget {
  final double width;
  final bool defaultColor;

  const GradientDivider({super.key, this.width = 320,this.defaultColor = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: 1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: defaultColor
              ? Colors.white
              : null,
          gradient: defaultColor ? null :const RadialGradient(
            center: Alignment.center,
            radius: 0.5,
            colors: [Color.fromRGBO(0, 0, 0, 0.2), Color(0x1A666666)],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
