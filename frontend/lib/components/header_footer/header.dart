// Package imports
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// API imports
import '../../apis/songs_api/find_artist_and_fetch_songs_api.dart';
import '../../apis/songs_api/find_song_api.dart';

// Widget imports
import '../main_widget/search_result.dart';
import '../main_widget/home.dart';

// Bloc imports
import '../../utils/app_bloc.dart';

class Header extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool canUndo;
  final bool canRedo;

  final void Function(Widget) onNavigate;

  const Header({
    super.key,
    this.onUndo,
    this.onRedo,
    this.canUndo = false,
    this.canRedo = false,
    required this.onNavigate,
  });

  static final TextEditingController _searchController =
      TextEditingController();

  Future<void> _handleSearch(String value) async {
    if (value.trim().isEmpty) return;
    final artists = await FindArtistAndFetchSongsApi.findArtistByName(
      value.trim(),
    );
    final songs = await FindSongApi.findSongByName(value.trim());

    // Use the onNavigate callback to show SearchResult
    onNavigate(SearchResult(artists: artists, songs: songs));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
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
                // Left section with menu and undo/redo
                Row(
                  children: [
                    Icon(
                      Icons.density_medium_rounded,
                      color: colorScheme.onSurface,
                      size: 22,
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      onPressed:
                          canUndo
                              ? () {
                                onUndo!();
                                _searchController.clear();
                              }
                              : null,
                      icon: Icon(Icons.arrow_back_ios),
                      color:
                          canUndo
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withAlpha(
                                (0.6 * 0xFF).round(),
                              ),
                      iconSize: 22,
                      tooltip: 'Undo',
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      onPressed:
                          canRedo
                              ? () {
                                onRedo!();
                                _searchController.clear();
                              }
                              : null,
                      icon: Icon(Icons.arrow_forward_ios),
                      color:
                          canRedo
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withAlpha(
                                (0.6 * 0xFF).round(),
                              ),
                      iconSize: 22,
                      tooltip: 'Redo',
                    ),
                  ],
                ),

                // Center search bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<AppCubit>().setIsHome(true);
                        onNavigate(Home(onNavigate: onNavigate));
                        _searchController.clear();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surface,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          state.isHome
                              ? 'assets/svg/homef.svg'
                              : 'assets/svg/home.svg',
                          height: 25,
                          colorFilter: ColorFilter.mode(
                            colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
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
                              colorScheme.onSurface.withAlpha(
                                (0.6 * 0xFF).round(),
                              ),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          SizedBox(
                            width: 400,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'What do you want to play?',
                                hintStyle: TextStyle(
                                  color: textTheme.bodyLarge!.color!.withAlpha(
                                    (0.6 * 0xFF).round(),
                                  ),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                isDense: true,
                              ),
                              style: TextStyle(
                                color: textTheme.bodyLarge!.color,
                                fontSize: 16,
                              ),
                              onSubmitted: _handleSearch,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    IconButton(
                      onPressed: context.read<AppCubit>().setIsChatting,
                      icon: Icon(Icons.mic),
                      color: colorScheme.onSurface.withAlpha(
                        (0.6 * 0xFF).round(),
                      ),
                      iconSize: 22,
                      tooltip: 'Voice Search',
                    ),
                  ],
                ),

                // Right window controls
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surface,
                      ),
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: colorScheme.primary.withAlpha(
                          (0.6 * 0xFF).round(),
                        ),
                        child: Text(
                          'H',
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    MinimizeWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: colorScheme.onSurface,
                      ),
                    ),
                    MaximizeWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: colorScheme.onSurface,
                      ),
                    ),
                    CloseWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
