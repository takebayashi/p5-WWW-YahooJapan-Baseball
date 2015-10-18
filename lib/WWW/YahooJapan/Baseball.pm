package WWW::YahooJapan::Baseball;
use 5.008001;
use strict;
use warnings;
use utf8;
use WWW::YahooJapan::Baseball::Parser;

our $VERSION = "0.01";

use URI;

our $PREFIX = "http://baseball.yahoo.co.jp";

sub get_game_uris {
  my $ymd = shift;
  my $league = shift;
  my $uri = URI->new($PREFIX . '/npb/schedule/?date=' . $ymd);
  WWW::YahooJapan::Baseball::Parser::parse_games_page($ymd, $league, uri => $uri);
}

sub get_game_player_stats {
  my $uri = shift;
  $uri->path($uri->path . 'stats');
  WWW::YahooJapan::Baseball::Parser::parse_game_stats_page(uri => $uri);
}

1;
__END__

=encoding utf-8

=head1 NAME

WWW::YahooJapan::Baseball - Fetches Yahoo Japan's baseball stats

=head1 SYNOPSIS

    use WWW::YahooJapan::Baseball;
    use Data::Dumper;

    my @uris = WWW::YahooJapan::Baseball::get_game_uris('20151001', 'NpbPl');
    for my $uri (@uris) {
      my @player_stats = WWW::YahooJapan::Baseball::get_game_player_stats($uri);
      print Dumper \@player_stats;
    }

=head1 DESCRIPTION

WWW::YahooJapan::Baseball provides a way to fetch Japanese baseball stats via Yahoo Japan's baseball service.

=head1 LICENSE

Copyright (C) Shun Takebayashi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shun Takebayashi E<lt>shun@takebayashi.asiaE<gt>

=cut

