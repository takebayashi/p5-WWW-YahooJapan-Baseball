# NAME

WWW::YahooJapan::Baseball - Fetches Yahoo Japan's baseball stats

# SYNOPSIS

    use WWW::YahooJapan::Baseball;
    use Data::Dumper;

    my @uris = WWW::YahooJapan::Baseball::get_game_uris('20151001', 'NpbPl');
    for my $uri (@uris) {
      my @player_stats = WWW::YahooJapan::Baseball::get_game_player_stats($uri);
      print Dumper \@player_stats;
    }

# DESCRIPTION

WWW::YahooJapan::Baseball provides a way to fetch Japanese baseball stats via Yahoo Japan's baseball service.

# LICENSE

Copyright (C) Shun Takebayashi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shun Takebayashi <shun@takebayashi.asia>
