import 'package:flutter_bloc/flutter_bloc.dart';

class Song {
  final int id;
  final String title;
  final String artist;
  final String albumArt;
  final String audioSource;
  final String duration;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.audioSource,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'audioSource': audioSource,
      'duration': duration,
    };
  }
}

class AppState {
  final List<Map<String, dynamic>> albums;
  final List<Map<String, dynamic>> playlists;
  final List<Song> songs;
  final bool isHome;

  AppState({
    this.albums = const [],
    this.playlists = const [],
    this.songs = const [],
    this.isHome = true,
  });

  AppState copyWith({
    List<Map<String, dynamic>>? albums,
    List<Map<String, dynamic>>? playlists,
    List<Song>? songs,
    bool? isHome,
  }) {
    return AppState(
      albums: albums ?? this.albums,
      playlists: playlists ?? this.playlists,
      songs: songs ?? this.songs,
      isHome: isHome ?? this.isHome,
    );
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());

  void setIsHome(bool value) => emit(state.copyWith(isHome: value));

  void setFooterSongs(List<Song> newSongs) {
    emit(state.copyWith(songs: newSongs));
  }

  void addToQueue(List<Song> additionalSongs) {
    emit(state.copyWith(songs: [...state.songs, ...additionalSongs]));
  }

  void setAlbums(List<Map<String, dynamic>> albums) =>
      emit(state.copyWith(albums: albums));

  void setPlaylists(List<Map<String, dynamic>> playlists) =>
      emit(state.copyWith(playlists: playlists));

  void removePlaylist(int playlistId) {
    final updatedPlaylists =
        state.playlists
            .where((playlist) => playlist['id'] != playlistId)
            .toList();
    emit(state.copyWith(playlists: updatedPlaylists));
  }
}
