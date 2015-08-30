package WWW::YahooJapan::Baseball;
use 5.008001;
use strict;
use warnings;
use utf8;

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

sub _parse_game_player_stats {
  my $cells = shift;
  my $stats = {};

  my %position_table = (
    '投' => 'p',
    '捕' => 'c',
    '一' => '1b',
    '二' => '2b',
    '三' => '3b',
    '遊' => 'ss',
    '左' => 'lf',
    '中' => 'cf',
    '右' => 'rf',
    '指' => 'dh',
    '打' => 'ph',
    '走' => 'pr'
  );
  my @positions = ();
  my $pos_rep = shift @$cells;
  if ($pos_rep =~ /^\((.*)\)$/) {
    my $i = 0;
    for my $p (split //, $1) {
      push(@positions, {
          position => $position_table{$p},
          is_starting => $i++ > 0 ? 0 : 1
      });
    }
  }
  else {
    for my $p (split //, $pos_rep) {
      push(@positions, {
          position => $position_table{$p},
          is_starting => 0
      });
    }
  }
  $stats->{positions} = \@positions;

  my $player_name = shift @$cells;

  my @indexes = qw(avg ab r h rbi k bbhbp shsf sb e hr);
  for my $i (@indexes) {
    $stats->{$i} = shift @$cells;
  }
  my $bi = 1;
  $stats->{innings} = {};
  for my $bat (@$cells) {
    $stats->{innings}->{$bi++} = $bat;
  }
  return $player_name, $stats;
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
    my ($player_name, $player_stats) = _parse_game_player_stats($cells);
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

WWW::YahooJapan::Baseball - It's new $module

=head1 SYNOPSIS

    use WWW::YahooJapan::Baseball;

=head1 DESCRIPTION

WWW::YahooJapan::Baseball is ...

=head1 LICENSE

Copyright (C) Shun Takebayashi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shun Takebayashi E<lt>shun@takebayashi.asiaE<gt>

=cut

