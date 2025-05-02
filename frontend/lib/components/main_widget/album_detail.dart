import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../apis/album_song_api.dart';

class AlbumDetail extends StatefulWidget {
  final Map<String, dynamic> album;
  final void Function(Widget) onNavigate;
  final void Function({
    required List<String> titles,
    required List<String> artists,
    required List<String> albumArt,
    required List<String> audioSources,
  })
  onPlayAlbum;

  const AlbumDetail({
    super.key,
    required this.album,
    required this.onNavigate,
    required this.onPlayAlbum,
  });

  @override
  State<AlbumDetail> createState() => _AlbumDetailState();
}

class _AlbumDetailState extends State<AlbumDetail>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> songs = [];
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
    } catch (e) {
      print('Error loading duration from $url: $e');
      await player.dispose();
      return '--:--';
    }
  }

  Future<void> _fetchSongs() async {
    try {
      final result = await AlbumSongApi.getSongsOfAlbum(widget.album['id']);
      final List<Map<String, dynamic>> fetchedSongs =
          List<Map<String, dynamic>>.from(result);

      for (var song in fetchedSongs) {
        final url = song['url'];
        if (url != null && url.toString().startsWith('http')) {
          song['duration_display'] = await getSongDuration(url);
        } else {
          song['duration_display'] = '--:--';
        }
      }

      setState(() {
        songs = fetchedSongs;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching songs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _extractDominantColor() async {
    final imageProvider =
        widget.album['cover_image'] != null
            ? NetworkImage(widget.album['cover_image'])
            : const AssetImage('assets/images/david_tao_album.jpg')
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  album['cover_image'] ?? '',
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
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Icons.play_circle_filled,
                                  size: 75,
                                  color: Color(0xFF1DB954),
                                ),
                                onPressed: () {
                                  final titles =
                                      songs
                                          .map((s) => s['title'] as String)
                                          .toList();
                                  final artists =
                                      songs.map((s) {
                                        // 'artists' is a List of maps; extract each name and join with commas
                                        final artistList =
                                            s['artists'] as List<dynamic>? ??
                                            [];
                                        return artistList
                                            .map(
                                              (a) =>
                                                  (a
                                                          as Map<
                                                            String,
                                                            dynamic
                                                          >)['name']
                                                      as String,
                                            )
                                            .join(', ');
                                      }).toList();
                                  final albumArt =
                                      songs
                                          .map(
                                            (s) => s['cover_image'] as String,
                                          )
                                          .toList();
                                  final sources =
                                      songs
                                          .map((s) => s['audio_url'] as String)
                                          .toList();

                                  widget.onPlayAlbum(
                                    titles: titles,
                                    artists: artists,
                                    albumArt: albumArt,
                                    audioSources: sources,
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              SvgPicture.asset(
                                'assets/svg/footer/shuffle.svg',
                                height: 50,
                                colorFilter: ColorFilter.mode(
                                  colorScheme.onSurface,
                                  BlendMode.srcIn,
                                ),
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

                          // Song List
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

                              return Padding(
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
                                              song['cover_image'] ?? '',
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
                                              song['title'],
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
                                        song['duration_display'] ?? '--:--',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
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
  }
}
