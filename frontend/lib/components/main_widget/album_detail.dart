import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// API imports
import '../../apis/album_song_api.dart';
import '../../apis/add_album_to_playlist_api.dart';

// Bloc imports
import '../../utils/app_bloc.dart';

class AlbumDetail extends StatefulWidget {
  final Map<String, dynamic> album;
  final void Function(Widget) onNavigate;
  final List<Map<String, dynamic>> playlists;

  const AlbumDetail({
    super.key,
    required this.album,
    required this.onNavigate,
    required this.playlists,
  });

  @override
  State<AlbumDetail> createState() => _AlbumDetailState();
}

class _AlbumDetailState extends State<AlbumDetail>
    with SingleTickerProviderStateMixin {
  final _logger = Logger('AlbumDetail');
  List<Song> songs = [];
  bool isLoading = true;
  PaletteColor? dominantColor;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _fetchSongs();
    _extractDominantColor();
  }

  @override
  void didUpdateWidget(covariant AlbumDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If user navigates to a different album, re‑fetch
    if (oldWidget.album['id'] != widget.album['id']) {
      setState(() {
        isLoading = true;
        songs = [];
      });
      _fetchSongs(); // re‑fetch track list
      _extractDominantColor(); // re‑compute palette
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
    } catch (e, stackTrace) {
      _logger.severe('Error fetching song duration', e, stackTrace);
      await player.dispose();
      return '--:--';
    }
  }

  Future<void> _fetchSongs() async {
    try {
      final result = await AlbumSongApi.getSongsOfAlbum(widget.album['id']);
      final List<Map<String, dynamic>> fetchedSongs =
          List<Map<String, dynamic>>.from(result);

      final parsedSongs =
          fetchedSongs.map((songData) {
            final artistList = songData['artists'] as List<dynamic>? ?? [];
            final artistNames = artistList
                .map((a) => (a as Map<String, dynamic>)['name'] as String)
                .join(', ');

            return Song(
              title: songData['title'] as String,
              artist: artistNames,
              albumArt: songData['cover_image'] as String? ?? '',
              audioSource: songData['audio_url'] as String? ?? '',
            );
          }).toList();

      if (!mounted) return; // Ensure the widget is still mounted
      setState(() {
        songs = parsedSongs;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return; // Ensure the widget is still mounted
      _logger.severe('Error fetching songs', e, stackTrace);
    }
  }

  Future<void> _extractDominantColor() async {
    final imageProvider =
        widget.album['cover_image'] != null
            ? NetworkImage(widget.album['cover_image'])
            : const AssetImage('assets/images/placeholder.jpg')
                as ImageProvider;

    final palette = await PaletteGenerator.fromImageProvider(imageProvider);
    setState(() {
      dominantColor = palette.dominantColor;
    });
  }

  Future<void> _addAlbumToPlaylist() async {
    try {
      final result = await AddAlbumToPlaylistApi.createPlaylistAndAddAlbum(
        widget.album['title'],
        widget.album['id'],
      );
      if (result != null) {
        _logger.info('Album added to playlist successfully!');
      } else {
        _logger.warning('Failed to add album to playlist.');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error adding album to playlist', e, stackTrace);
    }
  }

  Future<void> _addToExistingPlaylist(int playlistId) async {
    try {
      _logger.info(
        'Adding album to playlist: playlistId=$playlistId, albumId=${widget.album['id']}',
      );
      final result = await AddAlbumToPlaylistApi.addAlbumToExistingPlaylist(
        playlistId,
        widget.album['id'] as int,
      );
      if (!mounted) return; // Ensure the widget is still mounted
      if (result != null) {
        _logger.info('Album added to existing playlist successfully!');
      } else {
        _logger.warning('Failed to add album to existing playlist.');
      }
    } catch (e, stackTrace) {
      if (!mounted) return; // Ensure the widget is still mounted
      _logger.severe('Error adding album to existing playlist', e, stackTrace);
    }
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

        final album = widget.album;
        final artist = album['artist_detail'];

        final Color startColor = dominantColor?.color ?? Colors.deepPurple;
        final Color endColor = colorScheme.surface;

        return Scaffold(
          body:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FadeTransition(
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
                                        album['cover_image'] ?? '',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, _, __) => Image.asset(
                                              'assets/images/placeholder.jpg',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Album",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          album['title'],
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
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                artist['image'],
                                              ),
                                            ),

                                            const SizedBox(width: 12),
                                            Text(
                                              'By ${artist['name']} • ${album['release_date']} • ${songs.length} songs',
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
                                      color: const Color(0xFF1DB954),
                                    ),
                                    onPressed: () {
                                      context.read<AppCubit>().setFooterSongs(
                                        songs,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: SvgPicture.asset(
                                      'assets/svg/footer/shuffle.svg',
                                      height: 50,
                                      colorFilter: ColorFilter.mode(
                                        Theme.of(context).colorScheme.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    onPressed: () {
                                      final shuffledSongs = [...songs]
                                        ..shuffle();
                                      context.read<AppCubit>().setFooterSongs(
                                        shuffledSongs,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: SvgPicture.asset(
                                      'assets/svg/add.svg',
                                      height: 50,
                                      colorFilter: ColorFilter.mode(
                                        colorScheme.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    onPressed: () {
                                      _addAlbumToPlaylist();
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
                                    onSelected: (value) {
                                      if (value == 'queue') {
                                        context.read<AppCubit>().addToQueue(
                                          songs,
                                        );
                                      }
                                    },
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'queue',
                                            child: Text('Add to queue'),
                                          ),
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                const Text('Add to playlist'),
                                                const Spacer(),
                                                const Icon(Icons.arrow_right),
                                              ],
                                            ),
                                            onTap: () {
                                              // Show a nested popup menu for playlists
                                              final overlay =
                                                  Overlay.of(context).context
                                                          .findRenderObject()
                                                      as RenderBox;
                                              final offset = overlay
                                                  .localToGlobal(Offset.zero);

                                              showMenu(
                                                context: context,
                                                position: RelativeRect.fromLTRB(
                                                  offset.dx +
                                                      200, // Adjust the x-offset to position the nested menu
                                                  offset.dy,
                                                  offset.dx,
                                                  offset.dy,
                                                ),
                                                items:
                                                    widget.playlists.map((
                                                      playlist,
                                                    ) {
                                                      return PopupMenuItem(
                                                        child: Text(
                                                          playlist['name'],
                                                        ),
                                                        onTap: () {
                                                          _addToExistingPlaylist(
                                                            playlist['id'],
                                                          );
                                                        },
                                                      );
                                                    }).toList(),
                                              );
                                            },
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
                                    (_, __) =>
                                        const Divider(color: Colors.white24),
                                itemBuilder: (context, index) {
                                  final song = songs[index];

                                  final imageWidget = const Icon(
                                    Icons.music_note,
                                    color: Colors.white54,
                                    size: 32,
                                  );

                                  return GestureDetector(
                                    onSecondaryTapDown: (
                                      TapDownDetails details,
                                    ) {
                                      final overlay =
                                          Overlay.of(
                                                context,
                                              ).context.findRenderObject()
                                              as RenderBox;
                                      final offset = overlay.localToGlobal(
                                        details.globalPosition,
                                      );

                                      if (!mounted)
                                        return; // Ensure the widget is still mounted
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
                                              Future.delayed(Duration.zero, () {
                                                if (!mounted)
                                                  return; // Ensure the widget is still mounted
                                                context
                                                    .read<AppCubit>()
                                                    .addToQueue([song]);
                                              });
                                            },
                                          ),
                                          const PopupMenuItem(
                                            child: Text("Add to playlist"),
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
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: Image.network(
                                                    song.albumArt,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (context, _, __) =>
                                                            imageWidget,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Flexible(
                                                  child: Text(
                                                    song.title,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
