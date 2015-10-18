package WWW::YahooJapan::Baseball::Parser;

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

1;
