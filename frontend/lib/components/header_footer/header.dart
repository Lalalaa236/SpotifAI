import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/svg/spotify.svg',
            height: 25,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
