package WWW::YahooJapan::Baseball::Parser;

use Web::Scraper;

sub parse_games_page {
  my ($html, $date, $league) = @_;
  my $day_scraper = scraper {
    process '//*[@id="gm_sch"]/div[contains(@class, "' . $league . '")]/following-sibling::div[position() <= 2 and contains(@class, "NpbScoreBg")]//a[starts-with(@href, "/npb/game/' . $date . '") and not(contains(@href, "/top"))]', 'uris[]' => '@href';
  };
  my $res = $day_scraper->scrape($html);
  return $res->{uris};
}

sub parse_game_player_row {
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

sub parse_game_stats_page {
  my $html = shift;
  my $stats_scraper = scraper {
    process '//*[@id="st_batth" or @id="st_battv"]//tr', 'lines[]' => scraper {
      process '//td', 'cells[]' => 'TEXT';
      process_first '//a[contains(@href, "/npb/player")]', 'player_uri' => '@href';
    };
  };
  my $res = $stats_scraper->scrape($html);
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