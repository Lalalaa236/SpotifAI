import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_bloc.dart';

import '../../apis/songs_api/find_artist_and_fetch_songs_api.dart';

class SearchResult extends StatefulWidget {
  final List<dynamic> artists;
  final List<dynamic> songs;

  const SearchResult({super.key, required this.artists, required this.songs});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  bool _isTopResultHovered = false;
  List<Song> _displaySongs = [];

  @override
  void initState() {
    super.initState();
    _convertAndSetSongs(widget.songs);
    _fetchArtistSongs();
  }

  void _convertAndSetSongs(List<dynamic> songs) {
    setState(() {
      _displaySongs =
          songs.map((s) {
            // Concatenate all artist names, separated by commas
            String artistName = '';
            if (s['artists'] != null &&
                s['artists'] is List &&
                s['artists'].isNotEmpty) {
              artistName = (s['artists'] as List)
                  .map((a) => a['name'] ?? '')
                  .where((name) => name.isNotEmpty)
                  .join(', ');
            }
            return Song(
              id:
                  s['id'] is int
                      ? s['id']
                      : int.tryParse(s['id'].toString()) ?? 0,
              title: s['title'] ?? '',
              artist: artistName,
              albumArt: s['cover_image'] ?? '',
              audioSource: s['audio_url'] ?? '',
              duration: s['duration'] ?? '',
            );
          }).toList();
    });
  }

  Future<void> _fetchArtistSongs() async {
    try {
      if (widget.artists.isNotEmpty) {
        for (var artist in widget.artists) {
          final artistId = artist['id'];
          if (artistId != null) {
            final songs = await FindArtistAndFetchSongsApi.fetchSongsByArtist(
              artistId,
            );
            _convertAndSetSongs([..._displaySongs, ...songs]);
          }
        }
      } else if (widget.songs.isNotEmpty) {
        final firstSongArtists =
            widget.songs[0]['artists'] as List<dynamic>? ?? [];
        for (var artist in firstSongArtists) {
          final artistId = artist['id'];
          if (artistId != null) {
            final songs = await FindArtistAndFetchSongsApi.fetchSongsByArtist(
              artistId,
            );
            _convertAndSetSongs([..._displaySongs, ...songs]);
          }
        }
      }
    } catch (e) {
      print('Error fetching songs for artists: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEmpty = widget.artists.isEmpty && _displaySongs.isEmpty;

    final topArtist = widget.artists.isNotEmpty ? widget.artists.first : null;
    final topSong =
        widget.artists.isEmpty && _displaySongs.isNotEmpty
            ? _displaySongs.first
            : null;

    return BlocBuilder<AppCubit, AppState>(
      builder:
          (context, state) => ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child:
                  isEmpty
                      ? Center(
                        child: Text(
                          'No results found.',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top result
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Top result',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  MouseRegion(
                                    onEnter:
                                        (_) => setState(
                                          () => _isTopResultHovered = true,
                                        ),
                                    onExit:
                                        (_) => setState(
                                          () => _isTopResultHovered = false,
                                        ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 500,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF424242),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(20),
                                          child:
                                              (topArtist != null)
                                                  ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      topArtist['image'] != null
                                                          ? Container(
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.35,
                                                                      ),
                                                                  blurRadius:
                                                                      16,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        8,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                    topArtist['image'],
                                                                  ),
                                                              radius: 70,
                                                            ),
                                                          )
                                                          : const CircleAvatar(
                                                            radius: 40,
                                                            backgroundColor:
                                                                Color(
                                                                  0xFF424242,
                                                                ),
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 40,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        topArtist['name'] ?? '',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 32,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const Text(
                                                        'Artist',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 13,
                                                        ),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ],
                                                  )
                                                  : (topSong != null)
                                                  ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      topSong
                                                              .albumArt
                                                              .isNotEmpty
                                                          ? Container(
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.35,
                                                                      ),
                                                                  blurRadius:
                                                                      16,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        8,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                    topSong
                                                                        .albumArt,
                                                                  ),
                                                              radius: 70,
                                                            ),
                                                          )
                                                          : const CircleAvatar(
                                                            radius: 40,
                                                            backgroundColor:
                                                                Color(
                                                                  0xFF424242,
                                                                ),
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 40,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        topSong.title,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 32,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Text(
                                                          topSong.artist,
                                                          style: const TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 13,
                                                          ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                  : const SizedBox.shrink(),
                                        ),
                                        if (_isTopResultHovered)
                                          Positioned(
                                            bottom: 16,
                                            right: 16,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withAlpha(
                                                          (0.2 * 0xFF).round(),
                                                        ),
                                                    blurRadius: 18,
                                                    spreadRadius: 1,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons
                                                      .play_circle_filled_sharp,
                                                  size: 75,
                                                  color: const Color(
                                                    0xFF1DB954,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  context
                                                      .read<AppCubit>()
                                                      .setFooterSongs(
                                                        _displaySongs,
                                                      );
                                                },
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              // Songs list, same height as Top result
                              Expanded(
                                child: SizedBox(
                                  height: 325,
                                  child:
                                      _displaySongs.isEmpty
                                          ? const Center(
                                            child: Text(
                                              'No songs found.',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          )
                                          : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Songs',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount:
                                                      widget.artists.isEmpty &&
                                                              _displaySongs
                                                                  .isNotEmpty
                                                          ? _displaySongs.length
                                                          : _displaySongs
                                                              .length,
                                                  itemBuilder: (context, idx) {
                                                    final s =
                                                        widget
                                                                    .artists
                                                                    .isEmpty &&
                                                                _displaySongs
                                                                    .isNotEmpty
                                                            ? _displaySongs
                                                                .toList()[idx]
                                                            : _displaySongs[idx];
                                                    return Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          s.albumArt.isNotEmpty
                                                              ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                child: Image.network(
                                                                  s.albumArt,
                                                                  width: 48,
                                                                  height: 48,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                ),
                                                              )
                                                              : const Icon(
                                                                Icons
                                                                    .music_note,
                                                                size: 48,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  s.title,
                                                                  style: const TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                Text(
                                                                  s.artist,
                                                                  style: const TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white70,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.play_arrow,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            iconSize: 20,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            onPressed: () {
                                                              // TODO: Add play logic here
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
            ),
          ),
    );
  }
}
