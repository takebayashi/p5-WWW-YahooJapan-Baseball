package WWW::YahooJapan::Baseball;
use 5.008001;
use strict;
use warnings;
use utf8;
use WWW::YahooJapan::Baseball::Parser;

our $VERSION = "0.01";

use URI;
use Web::Scraper;
use Data::Dumper;

our $PREFIX = "http://baseball.yahoo.co.jp";

sub get_game_uris {
  my $ymd = shift;
  my $league = shift;
  my $day_scraper = scraper {
    process '//*[@id="gm_sch"]/div[contains(@class, "' . $league . '")]/following-sibling::div[position() <= 2 and contains(@class, "NpbScoreBg")]//a[starts-with(@href, "/npb/game/' . $ymd . '") and not(contains(@href, "/top"))]', 'uris[]' => '@href';
  };
  my $res = $day_scraper->scrape(URI->new($PREFIX . '/npb/schedule/?date=' . $ymd));
  return $res->{uris};
}

sub get_game_stats {
  my $uri = shift;
  $uri->path($uri->path . 'stats');
  my $stats_scraper = scraper {
    process '//*[@id="st_batth" or @id="st_battv"]//tr', 'lines[]' => scraper {
      process '//td', 'cells[]' => 'TEXT';
      process_first '//a[contains(@href, "/npb/player")]', 'player_uri' => '@href';
    };
  };
  my $res = $stats_scraper->scrape($uri);
  my @players = ();
  for my $line (@{$res->{lines}}) {
    my $cells = $line->{cells};
    unless ($cells and $line->{player_uri}) {
      next;
    }
    my ($player_name, $player_stats) = WWW::YahooJapan::Baseball::Parser::parse_game_player_row($cells);
    $player_stats->{player} = {
      name => $player_name,
      uri => $line->{player_uri},
      $line->{player_uri}->query_form
    };
    push(@players, $player_stats);
  }
  return \@players;
}

1;
__END__

=encoding utf-8

=head1 NAME

WWW::YahooJapan::Baseball - Fetches Yahoo Japan's baseball stats

=head1 SYNOPSIS

    use WWW::YahooJapan::Baseball;

=head1 DESCRIPTION

WWW::YahooJapan::Baseball provides a way to fetch Japanese baseball stats via Yahoo Japan's baseball service.

=head1 LICENSE

Copyright (C) Shun Takebayashi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shun Takebayashi E<lt>shun@takebayashi.asiaE<gt>

=cut

