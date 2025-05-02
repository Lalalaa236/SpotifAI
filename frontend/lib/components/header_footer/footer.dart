import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class Footer extends StatefulWidget {
  final List<String> audioSources; // URLs now
  final List<String> albumArt; // Changed to List<String>
  final List<String> songTitles;
  final List<String> artists;

  const Footer({
    super.key,
    required this.audioSources,
    required this.albumArt,
    required this.songTitles,
    required this.artists,
  });

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
  final Random _random = Random();

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

    final hasNewPlaylist = oldWidget.audioSources != widget.audioSources;

    if (hasNewPlaylist && widget.audioSources.isNotEmpty) {
      currentIndex = 0;
      _playAudio(); // autoplay new audio
    } else if (widget.audioSources.isEmpty) {
      setState(() {
        isPlaying = false; // stop playing if no audio sources
      });
    }
  }

  Future<void> _playAudio() async {
    await _audioPlayer.stop(); // stop current song before switching
    String url = widget.audioSources[currentIndex];
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

  void skipNext() {
    if (widget.audioSources.isEmpty) return;

    if (isShuffle) {
      int nextIndex;
      do {
        nextIndex = _random.nextInt(widget.audioSources.length);
      } while (nextIndex == currentIndex && widget.audioSources.length > 1);
      setState(() {
        currentIndex = nextIndex;
      });
      _playAudio();
    } else if (currentIndex < widget.audioSources.length - 1) {
      setState(() {
        currentIndex++;
      });
      _playAudio();
    }
  }

  void skipPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _playAudio();
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
                (widget.audioSources.isEmpty ||
                        widget.albumArt.isEmpty ||
                        widget.songTitles.isEmpty ||
                        widget.artists.isEmpty)
                    ? const SizedBox.shrink()
                    : Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            widget.albumArt[currentIndex],
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
                                widget.songTitles[currentIndex],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.artists[currentIndex],
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
