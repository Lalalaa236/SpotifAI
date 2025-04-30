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
        songTitles: ['Hated By Life Itself', 'Lemon', 'Renai Circulation'],
        artists: ['Iori Kanzaki', 'Kenshi Yonezu', 'Kana Hanazawa'],
        albumArt: 'assets/images/david_tao_album.jpg',
        audioSources: [
          'assets/audio/album/HatedByLifeItself.mp3',
          'assets/audio/album/Lemon.mp3',
          'assets/audio/album/RenaiCirculation.mp3',
        ],
      ),
    );
  }
}
