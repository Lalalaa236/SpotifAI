import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main_widget/playlist_detail.dart';
import '../main_widget/album_detail.dart';

import '../../utils/app_bloc.dart';

class Home extends StatefulWidget {
  final void Function(Widget) onNavigate;

  const Home({super.key, required this.onNavigate});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        final libraryItems = state.playlists.take(8).toList();

        return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF224a75), Color(0xFF121212)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ListView(
              children: [
                Row(
                  children: [
                    _buildTag("All"),
                    _buildTag("Music"),
                    _buildTag("Podcasts"),
                  ],
                ),
                const SizedBox(height: 20),

                GridView.builder(
                  shrinkWrap: true,
                  itemCount: libraryItems.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final item = libraryItems[index];
                    return GestureDetector(
                      onTap: () {
                        context.read<AppCubit>().setIsHome(false);
                        widget.onNavigate(
                          PlaylistDetail(
                            playlist: item,
                            onPlayAlbum:
                                context.read<AppCubit>().setFooterSongs,
                            onAddToQueue: context.read<AppCubit>().addToQueue,
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              child: Image.network(
                                item['cover_image'] as String,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['name']!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Made For Hung
                _buildSectionTitle("Made For Hưng"),
                const SizedBox(height: 12),
                _buildAlbumScroll(context, state.albums, state.playlists),

                const SizedBox(height: 30),

                // Discover Picks For You
                _buildSectionTitle("Discover picks for you"),
                const SizedBox(height: 12),
                _buildAlbumScroll(context, state.albums, state.playlists),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "Show all",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumScroll(
    BuildContext context,
    List<Map<String, dynamic>> items,
    List<Map<String, dynamic>> playlists,
  ) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 25),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              context.read<AppCubit>().setIsHome(false);
              widget.onNavigate(
                AlbumDetail(
                  album: item,
                  playlists: playlists,
                  onNavigate: widget.onNavigate,
                ),
              );
            },
            child: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      image: DecorationImage(
                        image:
                            item['cover_image'] != null &&
                                    (item['cover_image'] as String).isNotEmpty
                                ? NetworkImage(item['cover_image'])
                                : const AssetImage(
                                      'assets/images/placeholder.jpg',
                                    )
                                    as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      item['title'] ?? 'Untitled',
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
