import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

// API imports
import '../../apis/album_api/album_song_api.dart';
import '../../apis/playlist_api/add_album_to_playlist_api.dart';
import '../../apis/playlist_api/playlist_song_api.dart';

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
  late AudioPlayer _audioPlayer;
  bool isLoading = true;
  PaletteColor? dominantColor;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen(
      (playerState) {
        final processingState = playerState.processingState;
        if (processingState == ProcessingState.buffering) {
          debugPrint('Buffering...');
        } else if (processingState == ProcessingState.ready) {
          debugPrint('Ready to play');
        } else if (processingState == ProcessingState.completed) {
          debugPrint('Playback completed');
        }
      },
      onError: (error, stackTrace) {
        debugPrint('Player state error: $error');
      },
    );
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
    try {
      // Ensure the URL is valid
      if (url.isEmpty) {
        _logger.warning('Invalid URL provided for song duration');
        return '--:--';
      }

      // Set the URL with a timeout
      await Future.any([
        _audioPlayer.setUrl(url),
        Future.delayed(const Duration(seconds: 10), () {
          throw TimeoutException('Loading audio file timed out');
        }),
      ]);

      // Wait until the duration is available
      Duration? duration = await _audioPlayer.durationStream.firstWhere(
        (d) => d != null,
        orElse: () => const Duration(seconds: 0),
      );

      // Format the duration into mm:ss
      final minutes = duration!.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } on TimeoutException {
      _logger.warning('Timeout while loading audio file: $url');
      return '--:--';
    } on Exception catch (e, stackTrace) {
      _logger.severe('Error fetching song duration from $url', e, stackTrace);
      return '--:--';
    }
  }

  Future<void> _fetchSongs() async {
    try {
      final result = await AlbumSongApi.getSongsOfAlbum(widget.album['id']);
      final List<Map<String, dynamic>> fetchedSongs =
          List<Map<String, dynamic>>.from(result);

      final parsedSongs = await Future.wait(
        fetchedSongs.map((songData) async {
          final artistList = songData['artists'] as List<dynamic>? ?? [];
          final artistNames = artistList
              .map((a) => (a as Map<String, dynamic>)['name'] as String)
              .join(', ');

          final audioSource = songData['audio_url'] as String? ?? '';
          final duration = await getSongDuration(
            audioSource,
          ); // Fetch duration here

          return Song(
            id: songData['id'],
            title: songData['title'] as String,
            artist: artistNames,
            albumArt: songData['cover_image'] as String? ?? '',
            audioSource: audioSource,
            duration: duration, // Add duration to the Song object
          );
        }).toList(),
      );

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

  Future<void> _addSongToPlaylist(int playlistId, int songId) async {
    try {
      _logger.info(
        'Adding song to playlist: playlistId=$playlistId, songId=$songId',
      );
      final result = await PlaylistSongApi.addSongToPlaylist(
        playlistId,
        songId,
      );

      if (!mounted) return;

      if (result != null) {
        _logger.info('Song added to playlist successfully!');

        // Fetch updated playlists
        final updatedPlaylists = List<Map<String, dynamic>>.from(
          await PlaylistSongApi.getUserPlaylists(),
        );

        if (!mounted) return;
        // Update playlists in the AppCubit
        context.read<AppCubit>().setPlaylists(updatedPlaylists);
      } else {
        _logger.warning('Failed to add song to playlist.');
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      _logger.severe('Error adding song to playlist', e, stackTrace);
    }
  }

  Future<void> _addAlbumToPlaylist() async {
    try {
      final result = await AddAlbumToPlaylistApi.createPlaylistAndAddAlbum(
        widget.album['title'],
        widget.album['id'],
      );

      if (!mounted) return;

      if (result != null) {
        _logger.info('Album added to playlist successfully!');

        // Fetch updated playlists
        final updatedPlaylists = List<Map<String, dynamic>>.from(
          await PlaylistSongApi.getUserPlaylists(),
        );

        if (!mounted) return;
        // Update playlists in the AppCubit
        context.read<AppCubit>().setPlaylists(updatedPlaylists);
      } else {
        _logger.warning('Failed to add album to playlist.');
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
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

      if (!mounted) return;

      if (result != null) {
        _logger.info('Album added to existing playlist successfully!');

        // Fetch updated playlists
        final updatedPlaylists = List<Map<String, dynamic>>.from(
          await PlaylistSongApi.getUserPlaylists(),
        );

        if (!mounted) return;
        // Update playlists in the AppCubit
        context.read<AppCubit>().setPlaylists(updatedPlaylists);
      } else {
        _logger.warning('Failed to add album to existing playlist.');
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      _logger.severe('Error adding album to existing playlist', e, stackTrace);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
                                    offset: const Offset(10, 70),
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
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Select a Playlist',
                                                      ),
                                                      content: SizedBox(
                                                        width: 300,
                                                        height: 300,
                                                        child: ListView(
                                                          shrinkWrap: true,
                                                          children:
                                                              widget.playlists.map((
                                                                playlist,
                                                              ) {
                                                                return ListTile(
                                                                  title: Text(
                                                                    playlist['name'],
                                                                  ),
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(); // Close the dialog
                                                                    _addToExistingPlaylist(
                                                                      playlist['id'],
                                                                    ); // Add to playlist
                                                                  },
                                                                );
                                                              }).toList(),
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop(); // Close the dialog
                                                          },
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Row(
                                                children: const [
                                                  Text('Add to playlist'),
                                                ],
                                              ),
                                            ),
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
                                              // Ensure the widget is still mounted
                                              context
                                                  .read<AppCubit>()
                                                  .addToQueue([song]);
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: const Text(
                                              "Add to playlist",
                                            ),
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      'Select a Playlist',
                                                    ),
                                                    content: SizedBox(
                                                      width: 300,
                                                      height: 300,
                                                      child: ListView(
                                                        shrinkWrap: true,
                                                        children:
                                                            widget.playlists.map((
                                                              playlist,
                                                            ) {
                                                              return ListTile(
                                                                title: Text(
                                                                  playlist['name'],
                                                                ),
                                                                onTap: () async {
                                                                  _addSongToPlaylist(
                                                                    playlist['id']
                                                                        as int,
                                                                    song.id,
                                                                  );

                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(); // Close the dialog
                                                                },
                                                              );
                                                            }).toList(),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop(); // Close the dialog
                                                        },
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
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
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: Image.network(
                                                    song.albumArt,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          _,
                                                          __,
                                                        ) => const Icon(
                                                          Icons.music_note,
                                                          color: Colors.white54,
                                                          size: 32,
                                                        ),
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
                                              song.duration, // Use the pre-fetched duration
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
