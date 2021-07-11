import 'package:app/constants/dimensions.dart';
import 'package:app/models/song.dart';
import 'package:app/providers/album_provider.dart';
import 'package:app/providers/artist_provider.dart';
import 'package:app/providers/interaction_provider.dart';
import 'package:app/providers/song_provider.dart';
import 'package:app/ui/screens/library.dart';
import 'package:app/ui/screens/profile.dart';
import 'package:app/ui/screens/start.dart';
import 'package:app/ui/widgets/album_card.dart';
import 'package:app/ui/widgets/artist_card.dart';
import 'package:app/ui/widgets/bottom_space.dart';
import 'package:app/ui/widgets/headings.dart';
import 'package:app/ui/widgets/horizontal_card_scroller.dart';
import 'package:app/ui/widgets/simple_song_list.dart';
import 'package:app/ui/widgets/song_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late SongProvider songProvider = context.watch();
    late ArtistProvider artistProvider = context.watch();
    late AlbumProvider albumProvider = context.watch();
    late InteractionProvider interactionProvider = context.watch();

    late List<Widget> homeBlocks;

    if (songProvider.songs.isEmpty) {
      homeBlocks = <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              Text(
                'Looks like your library is empty. '
                'You can add songs using the web interface or via the '
                'command line.',
                style: TextStyle(color: Colors.white54),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const StartScreen(),
                          ),
                        );
                      },
                      child: Text('Refresh'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ];
    } else {
      homeBlocks = <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.horizontalPadding,
          ),
          child: SimpleSongList(songs: songProvider.recentlyAdded()),
        ),
        HorizontalCardScroller(
          headingText: 'Most played songs',
          cards: <Widget>[
            ...songProvider.mostPlayed().map((song) => SongCard(song: song)),
            PlaceholderCard(
              icon: CupertinoIcons.music_note,
              onPressed: () => gotoSongsScreen(context),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.horizontalPadding,
          ),
          child: SimpleSongList(
            songs: interactionProvider.getRandomFavorites(limit: 5),
            headingText: 'From your favorites',
          ),
        ),
        HorizontalCardScroller(
          headingText: 'Top albums',
          cards: <Widget>[
            ...albumProvider
                .mostPlayed()
                .map((album) => AlbumCard(album: album)),
            PlaceholderCard(
              icon: CupertinoIcons.music_albums,
              onPressed: () => gotoAlbumsScreen(context),
            ),
          ],
        ),
        HorizontalCardScroller(
          headingText: 'Top artists',
          cards: <Widget>[
            ...artistProvider
                .mostPlayed()
                .map((artist) => ArtistCard(artist: artist)),
            PlaceholderCard(
              icon: CupertinoIcons.music_mic,
              onPressed: () => gotoArtistsScreen(context),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.horizontalPadding,
          ),
          child: SimpleSongList(
            songs: songProvider.leastPlayed(limit: 5),
            headingText: 'Hidden gems',
          ),
        ),
        const BottomSpace(height: 128),
      ]
          .map(
            (widget) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: widget,
            ),
          )
          .toList();
    }

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: Colors.black,
            largeTitle: const Text(
              'Home',
              style: const TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
              onPressed: () => gotoProfileScreen(context),
              icon: const Icon(
                CupertinoIcons.person_alt_circle,
                size: 24,
                color: Colors.white60,
              ),
            ),
          ),
          SliverList(delegate: SliverChildListDelegate.fixed(homeBlocks)),
        ],
      ),
    );
  }
}

class MostPlayedSongs extends StatelessWidget {
  final List<Song> songs;
  final BuildContext context;

  const MostPlayedSongs({
    Key? key,
    required this.songs,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: AppDimensions.horizontalPadding),
          child: Heading5(text: 'Most played'),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...songs.expand(
                (song) => [
                  const SizedBox(width: AppDimensions.horizontalPadding),
                  SongCard(song: song),
                ],
              ),
              const SizedBox(width: AppDimensions.horizontalPadding),
              PlaceholderCard(
                icon: CupertinoIcons.music_note,
                onPressed: () => gotoSongsScreen(context),
              ),
              const SizedBox(width: AppDimensions.horizontalPadding),
            ],
          ),
        ),
      ],
    );
  }
}
