import 'package:flutter/material.dart';

import '../../apis/songs_api/find_artist_and_fetch_songs_api.dart';

class SearchResult extends StatefulWidget {
  final List<dynamic> artists;
  final List<dynamic> songs;

  const SearchResult({super.key, required this.artists, required this.songs});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  @override
  void initState() {
    super.initState();
    _fetchArtistSongs();
  }

  Future<void> _fetchArtistSongs() async {
    try {
      // If artists list is not empty, fetch songs for all artists
      if (widget.artists.isNotEmpty) {
        for (var artist in widget.artists) {
          final artistId = artist['id'];
          if (artistId != null) {
            final songs = await FindArtistAndFetchSongsApi.fetchSongsByArtist(
              artistId,
            );
            setState(() {
              widget.songs.addAll(songs);
            });
          }
        }
      }
      // If artists is empty but songs is not, fetch songs for the artists of the first song
      else if (widget.songs.isNotEmpty) {
        final firstSongArtists =
            widget.songs[0]['artists'] as List<dynamic>? ?? [];
        for (var artist in firstSongArtists) {
          final artistId = artist['id'];
          if (artistId != null) {
            final songs = await FindArtistAndFetchSongsApi.fetchSongsByArtist(
              artistId,
            );
            setState(() {
              widget.songs.addAll(songs);
            });
          }
        }
      }
    } catch (e) {
      // Handle error appropriately
      print('Error fetching songs for artists: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEmpty = widget.artists.isEmpty && widget.songs.isEmpty;

    final topArtist = widget.artists.isNotEmpty ? widget.artists.first : null;
    final topSong =
        widget.artists.isEmpty && widget.songs.isNotEmpty
            ? widget.songs.first
            : null;

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        // Change background to colorScheme.surface
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
                            Container(
                              width: 500,
                              decoration: BoxDecoration(
                                color: const Color(0xFF424242),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(20),
                              child:
                                  (topArtist != null)
                                      ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          topArtist['image'] != null
                                              ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  topArtist['image'],
                                                ),
                                                radius: 70,
                                              )
                                              : const CircleAvatar(
                                                radius: 40,
                                                backgroundColor: Color(
                                                  0xFF424242,
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                          const SizedBox(height: 20),
                                          Text(
                                            topArtist['name'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      )
                                      : (topSong != null)
                                      ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          topSong['cover_image'] != null
                                              ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  topSong['cover_image'],
                                                ),
                                                radius: 70,
                                              )
                                              : const CircleAvatar(
                                                radius: 40,
                                                backgroundColor: Color(
                                                  0xFF424242,
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                          const SizedBox(height: 20),
                                          Text(
                                            topSong['title'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 32,
                                            ),
                                          ),
                                          if (topSong['artists'] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                (topSong['artists']
                                                        as List<dynamic>)
                                                    .map((a) => a['name'])
                                                    .join(', '),
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        // Songs list, same height as Top result
                        Expanded(
                          child: Container(
                            height: 325,
                            child:
                                widget.songs.isEmpty
                                    ? const Center(
                                      child: Text(
                                        'No songs found.',
                                        style: TextStyle(color: Colors.white70),
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
                                                        widget.songs.isNotEmpty
                                                    ? widget.songs
                                                        .skip(1)
                                                        .length
                                                    : widget.songs.length,
                                            itemBuilder: (context, idx) {
                                              final s =
                                                  widget.artists.isEmpty &&
                                                          widget
                                                              .songs
                                                              .isNotEmpty
                                                      ? widget.songs
                                                          .skip(1)
                                                          .toList()[idx]
                                                      : widget.songs[idx];
                                              final songArtists =
                                                  (s['artists']
                                                          as List<dynamic>?)
                                                      ?.map(
                                                        (artist) =>
                                                            artist['name'],
                                                      )
                                                      .join(', ') ??
                                                  '';
                                              return Container(
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      s['cover_image'] != null
                                                          ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            child: Image.network(
                                                              s['cover_image'],
                                                              width: 48,
                                                              height: 48,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                          : const Icon(
                                                            Icons.music_note,
                                                            size: 48,
                                                            color: Colors.white,
                                                          ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              s['title'] ?? '',
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
                                                              songArtists,
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white70,
                                                                fontSize: 12,
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
                                                          color: Colors.white,
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
    );
  }
}
