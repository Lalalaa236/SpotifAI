import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main_widget/home.dart';

import '../../apis/playlist_api/playlist_song_api.dart';

import '../../utils/app_bloc.dart';

class PlaylistDetail extends StatefulWidget {
  final Map<String, dynamic> playlist;
  final void Function(Widget) onNavigate;

  const PlaylistDetail({
    super.key,
    required this.playlist,
    required this.onNavigate,
  });

  @override
  State<PlaylistDetail> createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends State<PlaylistDetail>
    with SingleTickerProviderStateMixin {
  List<Song> songs = [];
  PaletteColor? dominantColor;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    songs =
        (widget.playlist['songs'] as List<dynamic>).map((e) {
          final songData = e as Map<String, dynamic>;
          final artistList = songData['artists'] as List<dynamic>? ?? [];
          final artistNames = artistList
              .map((a) => (a as Map<String, dynamic>)['name'] as String)
              .join(', ');

          return Song(
            id: songData['id'],
            title: songData['title'] as String,
            artist: artistNames,
            albumArt: songData['cover_image'] as String? ?? '',
            audioSource: songData['audio_url'] as String? ?? '',
            duration: '--:--', // Placeholder for duration
          );
        }).toList();
    _extractDominantColor();
  }

  @override
  void didUpdateWidget(covariant PlaylistDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playlist['id'] != widget.playlist['id']) {
      setState(() {
        songs =
            (widget.playlist['songs'] as List<dynamic>).map((e) {
              final songData = e as Map<String, dynamic>;
              final artistList = songData['artists'] as List<dynamic>? ?? [];
              final artistNames = artistList
                  .map((a) => (a as Map<String, dynamic>)['name'] as String)
                  .join(', ');

              return Song(
                id: songData['id'],
                title: songData['title'] as String,
                artist: artistNames,
                albumArt: songData['cover_image'] as String? ?? '',
                audioSource: songData['audio_url'] as String? ?? '',
                duration: '--:--', // Placeholder for duration
              );
            }).toList();
      });
      _extractDominantColor();
    }
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  Future<String> getSongDuration(String url) async {
    final player = AudioPlayer();
    try {
      await player.setUrl(url);

      // Wait until the duration is available
      Duration? duration = await player.durationStream.firstWhere(
        (d) => d != null,
        orElse: () => const Duration(seconds: 0),
      );

      await player.dispose();

      final minutes = duration!.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error loading duration from $url: $e');
      await player.dispose();
      return '--:--';
    }
  }

  Future<void> _extractDominantColor() async {
    final imageProvider =
        widget.playlist['cover_image'] != null
            ? NetworkImage(widget.playlist['cover_image'])
            : const AssetImage('assets/images/placeholder.jpg')
                as ImageProvider;

    final palette = await PaletteGenerator.fromImageProvider(imageProvider);
    setState(() {
      dominantColor = palette.dominantColor;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        final playlist = widget.playlist;

        final Color startColor = dominantColor?.color ?? Colors.deepPurple;
        final Color endColor = colorScheme.surface;

        return Scaffold(
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    (0.2 * 255).toInt(),
                                  ), // light shadow
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                playlist['cover_image'] ?? '',
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, _, __) => Image.asset(
                                      'assets/images/david_tao_album.jpg',
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Playlist",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  playlist['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge // larger font
                                      ?.copyWith(
                                        fontSize: 65,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    Text(
                                      'Hưng • ${songs.length} songs',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.play_circle_filled_sharp,
                              size: 75,
                              color: Color(0xFF1DB954),
                            ),
                            onPressed: () {
                              context.read<AppCubit>().setFooterSongs(songs);
                            },
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/svg/footer/shuffle.svg',
                              height: 50,
                              colorFilter: ColorFilter.mode(
                                colorScheme.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: () {
                              final shuffledSongs = [...songs]..shuffle();
                              context.read<AppCubit>().setFooterSongs(
                                shuffledSongs,
                              );
                            },
                          ),

                          const SizedBox(width: 12),
                          PopupMenuButton<String>(
                            offset: const Offset(
                              0,
                              50,
                            ), // Moves the menu 50 pixels below the button
                            icon: SvgPicture.asset(
                              'assets/svg/option.svg',
                              height: 50,
                              colorFilter: ColorFilter.mode(
                                colorScheme.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                            onSelected: (value) async {
                              if (value == 'queue') {
                                context.read<AppCubit>().addToQueue(songs);
                              } else if (value == 'delete') {
                                // Confirm deletion
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete Playlist'),
                                      content: const Text(
                                        'Are you sure you want to delete this playlist? This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  // Capture values before async gap
                                  final playlistId =
                                      widget.playlist['id'] as int;
                                  final onNavigate = widget.onNavigate;
                                  if (!mounted) return;
                                  try {
                                    await PlaylistSongApi.deletePlaylist(
                                      playlistId,
                                    );
                                    if (!mounted) return;
                                    context.read<AppCubit>().removePlaylist(
                                      playlistId,
                                    );
                                    context.read<AppCubit>().setIsHome(true);
                                    onNavigate(Home(onNavigate: onNavigate));
                                  } catch (e) {
                                    if (mounted) {
                                      debugPrint('Error deleting playlist: $e');
                                    }
                                  }
                                }
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'queue',
                                    child: Text('Add to queue'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete playlist'),
                                  ),
                                ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                '#',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Title',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                'Duration',
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white38),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: songs.length,
                        separatorBuilder:
                            (_, __) => const Divider(color: Colors.white24),
                        itemBuilder: (context, index) {
                          final song = songs[index];

                          final imageWidget = const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                            size: 32,
                          );

                          return GestureDetector(
                            onSecondaryTapDown: (TapDownDetails details) {
                              final overlay =
                                  Overlay.of(context).context.findRenderObject()
                                      as RenderBox;
                              final offset = overlay.localToGlobal(
                                details.globalPosition,
                              );

                              showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  offset.dx,
                                  offset.dy,
                                  offset.dx,
                                  offset.dy,
                                ),
                                items: [
                                  PopupMenuItem(
                                    child: const Text("Add to queue"),
                                    onTap: () {
                                      context.read<AppCubit>().addToQueue([
                                        song,
                                      ]);
                                    },
                                  ),
                                  PopupMenuItem(
                                    value: 'remove',
                                    child: const Text('Remove from playlist'),
                                    onTap: () async {
                                      try {
                                        // Call API to remove the song from the playlist
                                        await PlaylistSongApi.removeSongFromPlaylist(
                                          widget.playlist['id'] as int,
                                          song.id,
                                        );

                                        setState(() {
                                          songs.remove(song);
                                        });
                                      } catch (e) {
                                        // Handle errors
                                        debugPrint(
                                          'Error removing song from playlist: $e',
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: Image.network(
                                            song.albumArt,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, _, __) => imageWidget,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            song.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      '--:--',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
