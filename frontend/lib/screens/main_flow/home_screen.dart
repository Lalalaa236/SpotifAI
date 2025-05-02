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
  final List<Widget> _widgetStack = [];
  int _stackIndex = -1;

  void _pushPage(Widget page) {
    setState(() {
      if (_stackIndex < _widgetStack.length - 1) {
        _widgetStack.removeRange(_stackIndex + 1, _widgetStack.length);
      }
      _widgetStack.add(page);
      _stackIndex++;
    });
  }

  void _undo() {
    if (_stackIndex > 0) {
      setState(() {
        _stackIndex--;
      });
    }
  }

  void _redo() {
    if (_stackIndex < _widgetStack.length - 1) {
      setState(() {
        _stackIndex++;
      });
    }
  }

  List<String> currentSongTitles = [];
  List<String> currentArtists = [];
  List<String> currentAlbumArt = [];
  List<String> currentAudioSources = [];

  void _setFooterSongs({
    required List<String> titles,
    required List<String> artists,
    required List<String> albumArt,
    required List<String> audioSources,
  }) {
    setState(() {
      currentSongTitles = titles;
      currentArtists = artists;
      currentAlbumArt = albumArt;
      currentAudioSources = audioSources;
    });
  }

  List<Map<String, dynamic>> playlists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
    print('Playlists loaded successfully: ${playlists.length} items.');
  }

  Future<void> _loadPlaylists() async {
    // fetch raw JSON/list
    try {
      final raw = await AlbumSongApi.getAllAlbums();
      final data = List<Map<String, dynamic>>.from(raw);
      setState(() {
        playlists = data;
        isLoading = false;
        _pushPage(
          Home(
            playlists: playlists,
            onNavigate: _pushPage,
            onPlayAlbum: _setFooterSongs,
          ),
        );
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
        child: Header(
          onUndo: _undo,
          onRedo: _redo,
          canUndo: _stackIndex > 0,
          canRedo: _stackIndex < _widgetStack.length - 1,
        ),
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
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        child: IndexedStack(
                          index: _stackIndex,
                          children: _widgetStack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: Footer(
        songTitles: currentSongTitles,
        artists: currentArtists,
        albumArt: currentAlbumArt,
        audioSources: currentAudioSources,
      ),
    );
  }
}
