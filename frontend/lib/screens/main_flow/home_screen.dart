import 'package:flutter/material.dart';

// Widget imports
import '../../components/header_footer/header.dart';
import '../../components/header_footer/footer.dart';
import '../../components/header_footer/side_bar.dart';
import '../../components/main_widget/home.dart';

import '../../apis/album_song_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> playlists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    // fetch raw JSON/list
    try {
      final raw = await AlbumSongApi.getAllAlbums();
      final data = List<Map<String, dynamic>>.from(raw);
      setState(() {
        playlists = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading playlists: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Header(),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    ExpandableSidebar(playlists: playlists),
                    const SizedBox(width: 8.0),
                    Expanded(child: MainContent(playlists: playlists)),
                  ],
                ),
              ),
      bottomNavigationBar: Footer(
        songTitles: [
          'Until I Found You',
          'Until I Found You',
          'Until I Found You',
          'Until I Found You',
        ],
        artists: [
          'Stephen Sanchez',
          'Stephen Sanchez',
          'Stephen Sanchez',
          'Stephen Sanchez',
        ],
        albumArt: 'assets/images/david_tao_album.jpg',
        audioSources: [
          'assets/audio/album/Until I Found You.mp3',
          'assets/audio/album/Lemon_Pop_-_the.verandas.mp3',
          'assets/audio/album/Flowers_Of_September_-_The_Tangerine_Club.mp3',
          'assets/audio/album/Yellow_-_Sam_Opoku.mp3',
        ],
      ),
    );
  }
}
