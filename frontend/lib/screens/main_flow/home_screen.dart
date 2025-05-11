import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Widget imports
import '../../components/header_footer/header.dart';
import '../../components/header_footer/footer.dart';
import '../../components/header_footer/side_bar.dart';
import '../../components/main_widget/home.dart';

// API imports
import '../../apis/album_api/album_song_api.dart';
import '../../apis/playlist_api/playlist_song_api.dart';

// Bloc imports
import '../../utils/app_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final _logger = Logger('HomeScreen');

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _widgetStack = [];
  int _stackIndex = -1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final albums = List<Map<String, dynamic>>.from(
        await AlbumSongApi.getAllAlbums(),
      );
      final playlists = List<Map<String, dynamic>>.from(
        await PlaylistSongApi.getUserPlaylists(),
      );

      if (!mounted) return;

      final cubit = context.read<AppCubit>();
      cubit.setAlbums(albums);
      cubit.setPlaylists(playlists);
      _pushPage(
        Home(onNavigate: _pushPage),
      ); // Home widget now uses BLoC for state
      cubit.setIsHome(true);
    } catch (e) {
      _logger.severe('Error loading data', e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _pushPage(Widget page) {
    setState(() {
      if (_stackIndex < _widgetStack.length - 1) {
        _widgetStack.removeRange(_stackIndex + 1, _widgetStack.length);
      }
      _widgetStack.add(page);
      _stackIndex++;
    });
    _updateIsHomeFlag();
  }

  void _undo() {
    if (_stackIndex > 0) {
      setState(() {
        _stackIndex--;
      });
      _updateIsHomeFlag();
    }
  }

  void _redo() {
    if (_stackIndex < _widgetStack.length - 1) {
      setState(() {
        _stackIndex++;
      });
      _updateIsHomeFlag();
    }
  }

  void _updateIsHomeFlag() {
    final cubit = context.read<AppCubit>();
    final topWidget = _widgetStack[_stackIndex];
    cubit.setIsHome(topWidget.runtimeType == Home);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppCubit>().state;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Header(
          onUndo: _undo,
          onRedo: _redo,
          canUndo: _stackIndex > 0,
          canRedo: _stackIndex < _widgetStack.length - 1,
          onNavigate: _pushPage,
        ),
      ),

      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    ExpandableSidebar(onNavigate: _pushPage),
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
      bottomNavigationBar: Footer(songs: state.songs),
    );
  }
}
