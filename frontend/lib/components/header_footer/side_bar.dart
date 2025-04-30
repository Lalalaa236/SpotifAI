import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExpandableSidebar extends StatefulWidget {
  final List<Map<String, dynamic>> playlists; // {title, subtitle, imagePath}

  const ExpandableSidebar({super.key, required this.playlists});

  @override
  State<ExpandableSidebar> createState() => _ExpandableSidebarState();
}

class _ExpandableSidebarState extends State<ExpandableSidebar> {
  bool isExpanded = false;
  bool _isLibraryHovered = false;

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isExpanded ? 350 : 70,
        color: colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              isExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isExpanded)
                    MouseRegion(
                      onEnter: (_) => setState(() => _isLibraryHovered = true),
                      onExit: (_) => setState(() => _isLibraryHovered = false),
                      child:
                          _isLibraryHovered
                              ? IconButton(
                                icon: SvgPicture.asset(
                                  'assets/svg/libraryf.svg',
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    colorScheme.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onPressed: toggleSidebar,
                              )
                              : GestureDetector(
                                onTap: toggleSidebar,
                                child: Text(
                                  'Your Library',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    )
                  else
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/svg/library.svg',
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          colorScheme.onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: toggleSidebar,
                    ),
                  if (isExpanded)
                    IconButton(
                      icon: Icon(Icons.add, color: colorScheme.onSurface),
                      onPressed: () {
                        // TODO: Add functionality to create a new playlist
                      },
                    ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: widget.playlists.length,
                itemBuilder: (context, index) {
                  final playlist = widget.playlists[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child:
                              // use network image if cover_image exists, else fallback to placeholder asset
                              (playlist['cover_image'] as String?)
                                          ?.isNotEmpty ==
                                      true
                                  ? Image.network(
                                    playlist['cover_image'] as String,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    'assets/images/david_tao_album.jpg',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        if (isExpanded) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist['title']!,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  'Playlist - Hưng',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
