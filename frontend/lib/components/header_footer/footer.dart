import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

import '../../utils/app_bloc.dart';

class Footer extends StatefulWidget {
  final List<Song> songs;

  const Footer({super.key, required this.songs});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool isMuted = false;
  Duration currentTime = Duration.zero;
  Duration totalTime = Duration.zero;
  double volume = 0.2;
  double previousVolume = 0.2;
  int currentIndex = 0;
  bool isShuffle = false;
  bool isRepeat = false;
  List<int> shuffledIndices = [];
  int shuffledPosition = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        currentTime = p;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        totalTime = d;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (isRepeat) {
        _playAudio(); // Replay the current song
      } else {
        skipNext();
      }
    });

    _audioPlayer.setVolume(volume);
  }

  @override
  void didUpdateWidget(covariant Footer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final hasNewPlaylist = oldWidget.songs != widget.songs;

    if (hasNewPlaylist && widget.songs.isNotEmpty) {
      currentIndex = 0;
      _playAudio(); // autoplay new audio
    } else if (widget.songs.isEmpty) {
      setState(() {
        isPlaying = false; // stop playing if no songs
      });
    }
  }

  Future<void> _playAudio() async {
    await _audioPlayer.stop();

    if (isShuffle && shuffledIndices.isEmpty) {
      _generateShuffleList();
      shuffledPosition = 0;
      currentIndex = shuffledIndices[shuffledPosition];
    }

    String url = widget.songs[currentIndex].audioSource;
    await _audioPlayer.play(UrlSource(url));
    setState(() {
      isPlaying = true;
    });
  }

  void togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _generateShuffleList() {
    final random = Random();
    shuffledIndices = List<int>.generate(widget.songs.length, (i) => i);
    shuffledIndices.remove(currentIndex); // Remove the current song index
    shuffledIndices.shuffle(random);
    shuffledIndices.insert(0, currentIndex); // Put current song first
    shuffledPosition = 0; // Set position to current song
  }

  void skipNext() {
    if (isShuffle) {
      if (shuffledPosition < shuffledIndices.length - 1) {
        shuffledPosition++;
        currentIndex = shuffledIndices[shuffledPosition];
        _playAudio();
      } else if (isRepeat) {
        _generateShuffleList();
        shuffledPosition = 0;
        currentIndex = shuffledIndices[shuffledPosition];
        _playAudio();
      }
    } else {
      if (currentIndex < widget.songs.length - 1) {
        setState(() {
          currentIndex++;
        });
        _playAudio();
      } else if (isRepeat) {
        setState(() {
          currentIndex = 0;
        });
        _playAudio();
      }
    }
  }

  void skipPrevious() {
    if (isShuffle) {
      if (shuffledPosition > 0) {
        shuffledPosition--;
        currentIndex = shuffledIndices[shuffledPosition];
        _playAudio();
      }
    } else {
      if (currentIndex > 0) {
        setState(() {
          currentIndex--;
        });
        _playAudio();
      }
    }
  }

  void toggleMute() {
    setState(() {
      if (isMuted) {
        volume = previousVolume;
        _audioPlayer.setVolume(volume);
        isMuted = false;
      } else {
        previousVolume = volume;
        volume = 0;
        _audioPlayer.setVolume(0);
        isMuted = true;
      }
    });
  }

  void toggleShuffle() {
    setState(() {
      isShuffle = !isShuffle;
      if (isShuffle) {
        _generateShuffleList();
      } else {
        shuffledIndices.clear();
        shuffledPosition = 0;
      }
    });
  }

  void toggleRepeat() {
    setState(() {
      isRepeat = !isRepeat;
    });
  }

  void updateVolume(double newVolume) {
    setState(() {
      volume = newVolume;
      isMuted = newVolume == 0;
      if (!isMuted) previousVolume = newVolume;
    });
    _audioPlayer.setVolume(volume);
  }

  void updateCurrentTime(double seconds) {
    final newDuration = Duration(seconds: seconds.toInt());
    _audioPlayer.seek(newDuration);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 250,
            child:
                widget.songs.isEmpty
                    ? const SizedBox.shrink()
                    : Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            widget.songs[currentIndex].albumArt,
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.songs[currentIndex].title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.songs[currentIndex].artist,
                                style: const TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: isShuffle ? Colors.green : Colors.white,
                    ),
                    onPressed: toggleShuffle,
                  ),

                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: skipPrevious,
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 36,
                      color: Colors.white,
                    ),
                    onPressed: togglePlayPause,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: skipNext,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.repeat,
                      color: isRepeat ? Colors.green : Colors.white,
                    ),
                    onPressed: toggleRepeat,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _formatDuration(currentTime),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 600,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                      ),
                      child: Slider(
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey,
                        value: currentTime.inSeconds.toDouble().clamp(
                          0,
                          totalTime.inSeconds.toDouble(),
                        ),
                        max: totalTime.inSeconds.toDouble(),
                        onChanged: updateCurrentTime,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(totalTime),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: toggleMute,
              ),
              SizedBox(
                width: 150,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: volume,
                    min: 0,
                    max: 1,
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    onChanged: updateVolume,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    return "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(d.inSeconds.remainder(60)).toString().padLeft(2, '0')}";
  }
}
