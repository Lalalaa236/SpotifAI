import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MoveWindow(
      child: Container(
        color: colorScheme.background,
        height: kToolbarHeight,
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 0.0,
          top: 5.0,
          bottom: 5.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.density_medium_rounded,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
                const SizedBox(width: 40),
                Icon(
                  Icons.arrow_back_ios,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
                const SizedBox(width: 8.0),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
              ],
            ),

            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        colorScheme.surface, // Optional: Add a background color
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/svg/homef.svg',
                    height: 25,
                    colorFilter: ColorFilter.mode(
                      colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),

                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/search.svg',
                        height: 25,
                        colorFilter: ColorFilter.mode(
                          colorScheme.onSurface.withOpacity(0.6),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      SizedBox(
                        width: 400, // Adjust width as needed
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'What do you want to play?',
                            hintStyle: TextStyle(
                              color: textTheme.bodyLarge!.color!.withOpacity(
                                0.6,
                              ),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                            isDense: true,
                          ),
                          style: TextStyle(
                            color: textTheme.bodyLarge!.color,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Window buttons
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        colorScheme.surface, // Optional: Add a background color
                  ),
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primary.withOpacity(0.3),
                    child: Text(
                      'H',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                  ),
                ),

                const SizedBox(width: 10),
                MinimizeWindowButton(
                  colors: WindowButtonColors(iconNormal: colorScheme.onSurface),
                ),
                MaximizeWindowButton(
                  colors: WindowButtonColors(iconNormal: colorScheme.onSurface),
                ),
                CloseWindowButton(
                  colors: WindowButtonColors(iconNormal: colorScheme.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
