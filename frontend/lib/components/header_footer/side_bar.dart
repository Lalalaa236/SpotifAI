import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main_widget/playlist_detail.dart';

import '../../utils/app_bloc.dart';

class ExpandableSidebar extends StatefulWidget {
  final void Function(Widget) onNavigate;

  const ExpandableSidebar({super.key, required this.onNavigate});

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

    return BlocListener<AppCubit, AppState>(
      listenWhen:
          (previous, current) => previous.playlists != current.playlists,
      listener: (context, state) {
        debugPrint(
          'Playlists updated: ${state.playlists.length} playlists available.',
        );
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isExpanded ? 350 : 70,
          color: colorScheme.surface,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                isExpanded
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 10.0,
                  top: 10.0,
                  bottom: 5.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isExpanded)
                      MouseRegion(
                        onEnter:
                            (_) => setState(() => _isLibraryHovered = true),
                        onExit:
                            (_) => setState(() => _isLibraryHovered = false),
                        child: GestureDetector(
                          onTap: toggleSidebar,
                          child: SizedBox(
                            height: 40,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // Sliding icon from left
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 250),
                                  left: _isLibraryHovered ? 0 : -30,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 250),
                                    opacity: _isLibraryHovered ? 1.0 : 0.0,
                                    child: SvgPicture.asset(
                                      'assets/svg/libraryf.svg',
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                        colorScheme.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),

                                // Slightly shifted text on hover
                                AnimatedPadding(
                                  duration: const Duration(milliseconds: 250),
                                  padding: EdgeInsets.only(
                                    left: _isLibraryHovered ? 30 : 0,
                                  ),
                                  child: Text(
                                    'Your Library',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
                      AnimatedOpacity(
                        opacity: isExpanded ? 1.0 : 0.0,
                        duration: const Duration(
                          milliseconds: 300,
                        ), // Match sidebar animation duration
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Handle create playlist action
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF424242),
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 12.0,
                              top: 8.0,
                              bottom: 8.0,
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min, // Wrap content tightly
                              children: [
                                Icon(Icons.add, color: colorScheme.onSurface),
                                const SizedBox(width: 6),
                                Text(
                                  'Create',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: BlocBuilder<AppCubit, AppState>(
                  builder: (context, state) {
                    return ListView.builder(
                      itemCount: state.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = state.playlists[index];
                        return GestureDetector(
                          onTap: () {
                            context.read<AppCubit>().setIsHome(false);
                            widget.onNavigate(
                              PlaylistDetail(
                                playlist: playlist,
                                onNavigate: widget.onNavigate,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // shrink‑wrap row
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  clipBehavior: Clip.hardEdge,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    playlist['cover_image'] as String,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (isExpanded) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    // takes remaining space
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          playlist['name'] as String,
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
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
