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

class Message {
  final String text;
  final bool isUser;
  final List<Song>? songs;
  Message(this.text, this.isUser, {this.songs});
}

class AppState {
  final List<Map<String, dynamic>> albums;
  final List<Map<String, dynamic>> playlists;
  final List<Song> songs;
  final bool isHome;
  final bool isChatting;
  final List<Message> chatMessages;
  final String? conversationId;

  AppState({
    this.albums = const [],
    this.playlists = const [],
    this.songs = const [],
    this.isHome = true,
    this.isChatting = false,
    this.chatMessages = const [],
    this.conversationId,
  });

  AppState copyWith({
    List<Map<String, dynamic>>? albums,
    List<Map<String, dynamic>>? playlists,
    List<Song>? songs,
    bool? isHome,
    bool? isChatting,
    List<Message>? chatMessages,
    String? conversationId,
  }) {
    return AppState(
      albums: albums ?? this.albums,
      playlists: playlists ?? this.playlists,
      songs: songs ?? this.songs,
      isHome: isHome ?? this.isHome,
      isChatting: isChatting ?? this.isChatting,
      chatMessages: chatMessages ?? this.chatMessages,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());

  void setIsHome(bool value) => emit(state.copyWith(isHome: value));

  void setIsChatting() => emit(state.copyWith(isChatting: !state.isChatting));

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

  void addChatMessage(Message message) {
    // If the message contains songs, update both chatMessages and songs in AppState
    if (message.songs != null && message.songs!.isNotEmpty) {
      emit(state.copyWith(chatMessages: [...state.chatMessages, message]));
    } else {
      emit(state.copyWith(chatMessages: [...state.chatMessages, message]));
    }
  }

  void setConversationId(String? id) {
    emit(state.copyWith(conversationId: id));
  }

  void clearChat() {
    emit(state.copyWith(chatMessages: [], conversationId: null));
  }
}
