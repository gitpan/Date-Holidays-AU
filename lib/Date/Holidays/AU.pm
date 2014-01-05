package Date::Holidays::AU;

use strict;
use warnings;

use Time::Local();
use Date::Easter();
use Exporter();
use Carp;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(is_holiday holidays);
our $VERSION   = '0.10';

our (%cached);

use constant DEFAULT_STATE => 'VIC';

sub holidays {
    my (%params) = @_;
    unless ( ( exists $params{year} ) && ( defined $params{year} ) ) {
        $params{year} = ( localtime(time) )[5];
        $params{year} += 1900;
    }
    unless ( $params{year} =~ /^\d{4}$/ ) {
        croak("Year must be numeric and four digits, eg '2004'\n");
    }
    my ($year) = $params{year};
    unless ( defined $params{state} ) {
        carp "State not defined, setting state to default: " . DEFAULT_STATE;
        $params{state} = DEFAULT_STATE;
    }

    my ($state) = uc( $params{state} );
    unless ( ( $state eq 'VIC' )
        || ( $state eq 'WA' )
        || ( $state eq 'NT' )
        || ( $state eq 'QLD' )
        || ( $state eq 'TAS' )
        || ( $state eq 'NSW' )
        || ( $state eq 'SA' )
        || ( $state eq 'ACT' ) )
    {
        croak(
"State must be one of 'VIC','WA','NT','QLD','TAS','NSW','SA','ACT'\n"
        );
    }
    my ($concat) = $state;
    foreach my $key (%params) {
        next if ( $key eq 'year' );
        next if ( $key eq 'state' );
        next unless ( $params{$key} );
        if ( ref $params{$key} ) {
            if ( ( ref $params{$key} ) eq 'ARRAY' ) {
                $concat .= '_' . $key;
                foreach my $element ( @{ $params{$key} } ) {
                    $concat .= '_' . $element;
                }
            }
        }
        else {
            $concat .= '_' . $key . '_' . $params{$key};
        }
        $concat = lc($concat);
        $concat =~ s/\s*//g;
    }
    my (%holidays);
    if ( ( exists $cached{$concat} ) && ( exists $cached{$concat}{$year} ) ) {
        foreach my $date ( keys %{ $cached{$concat}{$year} } ) {
            $holidays{$date} = $cached{$concat}{$year}{$date};
        }
    }
    else {
        if ( $state eq 'TAS' ) {
            if ( exists $params{holidays} ) {
                if (   ( ref $params{holidays} )
                    && ( ( ref $params{holidays} ) eq 'ARRAY' ) )
                {
                    foreach my $allowed ( @{ $params{holidays} } ) {
                        $allowed = lc($allowed);
                        $allowed =~ s/\s*//g;
                        if ( $allowed eq 'devonportcup' ) {
                            foreach
                              my $holiday ( _compute_devonport_cup($year) )
                            {    # TAS devonport cup
                                $holidays{$holiday} = 'Devonport Cup';
                            }
                        }
                    }
                }
                else {
                    croak(
                        "Holidays parameter must be a reference to an array\n");
                }
            }
        }
        foreach my $holiday ( _compute( 1, 1, $year, { 'day_in_lieu' => 1 } ) )
        {    # new years day
            if ( $holiday eq '0101' ) {
                $holidays{$holiday} = 'New Years Day';
            }
            else {
                $holidays{$holiday} = 'New Years Day Holiday';
            }
        }
        foreach my $holiday ( _compute( 26, 1, $year, { 'day_in_lieu' => 1 } ) )
        {    # australia day
            if ( $holiday eq '2601' ) {
                $holidays{$holiday} = 'Australia Day';
            }
            else {
                $holidays{$holiday} = 'Australia Day Holiday';
            }
        }
        if ( $state eq 'VIC' ) {
            foreach my $holiday ( _compute_vic_labour_day($year) )
            {    # VIC labour day
                $holidays{$holiday} = 'Labour Day';
            }
        }
        elsif ( $state eq 'WA' ) {
            foreach my $holiday ( _compute_wa_labour_day($year) )
            {    # WA labour day
                $holidays{$holiday} = 'Labour Day';
            }
        }
        elsif ( $state eq 'SA' ) {
            foreach my $holiday ( _compute_sa_adelaide_cup_day($year) )
            {    # adelaide cup day
                $holidays{$holiday} = 'Adelaide Cup Day';
            }
        }
        elsif ( $state eq 'ACT' ) {
            foreach my $holiday ( _compute_canberra_day($year) )
            {    # canberra day
                $holidays{$holiday} = 'Canberra Day';
            }
        }
        elsif ( $state eq 'TAS' ) {
            if ( exists $params{holidays} ) {
                if (   ( ref $params{holidays} )
                    && ( ( ref $params{holidays} ) eq 'ARRAY' ) )
                {
                    foreach my $allowed ( @{ $params{holidays} } ) {
                        $allowed = lc($allowed);
                        $allowed =~ s/\s*//g;
                        if ( $allowed eq 'devonportcup' ) {
                            foreach
                              my $holiday ( _compute_devonport_cup($year) )
                            {    # TAS devonport cup
                                $holidays{$holiday} = 'Devonport Cup';
                            }
                        }
                        elsif ( $allowed eq 'hobartregatta' ) {
                            foreach
                              my $holiday ( _compute_hobart_regatta($year) )
                            {    # TAS hobart regatta
                                $holidays{$holiday} = 'Hobart Regatta';
                            }
                        }
                        elsif ( $allowed eq 'launcestoncup' ) {
                            foreach
                              my $holiday ( _compute_launceston_cup($year) )
                            {    # TAS launceston cup
                                $holidays{$holiday} = 'Launceston Cup';
                            }
                        }
                        elsif ( $allowed eq 'kingislandshow' ) {
                            foreach
                              my $holiday ( _compute_king_island_show($year) )
                            {    # TAS king island show
                                $holidays{$holiday} = 'King Island Show';
                            }
                        }
                    }
                }
                else {
                    croak(
                        "Holidays parameter must be a reference to an array\n");
                }
            }
            foreach my $holiday ( _compute_eight_hours_day($year) )
            {                    # TAS eight hours day
                $holidays{$holiday} = 'Eight Hours Day';
            }
        }
        my ($count) = 0;
        foreach my $holiday ( _compute_easter( $year, $state ) ) {    # easter
            if ( $count == 0 ) {
                $holidays{$holiday} = 'Good Friday';
            }
            elsif ( $count == 1 ) {
                $holidays{$holiday} = 'Easter Saturday';
            }
            elsif ( $count == 2 ) {
                $holidays{$holiday} = 'Easter Sunday';
            }
            elsif ( $count == 3 ) {
                $holidays{$holiday} = 'Easter Monday';
            }
            elsif ( ( $count == 4 ) && ( $state eq 'TAS' ) ) {
                $holidays{$holiday} = 'Easter Tuesday';
            }
            else {
                croak("Too many days in easter\n");
            }
            $count += 1;
        }
        if ( ( $state eq 'VIC' ) || ( $state eq 'TAS' ) ) {
            foreach my $holiday ( _compute( 25, 4, $year ) ) {    # ANZAC day
                $holidays{$holiday} = 'Anzac Day';
            }
        }
        else {
            foreach
              my $holiday ( _compute( 25, 4, $year, { 'day_in_lieu' => 1 } ) )
            {                                                     # ANZAC day
                if ( $holiday eq '2504' ) {
                    $holidays{$holiday} = 'Anzac Day';
                }
                else {
                    $holidays{$holiday} = 'Anzac Day Holiday';
                }
            }
        }
        if ( $state eq 'SA' ) {
            foreach my $holiday ( _compute_sa_volunteers_day($year) )
            {    # SA Volunteers day
                $holidays{$holiday} = 'Volunteers Day';
            }
        }
        elsif ( $state eq 'NT' ) {
            foreach my $holiday ( _compute_nt_may_day($year) ) {    # NT May day
                $holidays{$holiday} = 'May Day';
            }
        }
        elsif ( $state eq 'TAS' ) {
            if ( exists $params{holidays} ) {
                if (   ( ref $params{holidays} )
                    && ( ( ref $params{holidays} ) eq 'ARRAY' ) )
                {
                    foreach my $allowed ( @{ $params{holidays} } ) {
                        $allowed = lc($allowed);
                        $allowed =~ s/\s*//g;
                        if ( $allowed eq 'agfest' ) {
                            foreach my $holiday ( _compute_agfest($year) )
                            {    # TAS Agfest
                                $holidays{$holiday} = 'Agfest';
                            }
                        }
                    }
                }
                else {
                    croak(
                        "Holidays parameter must be a reference to an array\n");
                }
            }
        }
        if ( $state eq 'WA' ) {
            foreach my $holiday ( _compute_wa_foundation_day($year) )
            {    # WA Foundation day
                $holidays{$holiday} = 'Foundation Day';
            }
        }
        else {
            foreach my $holiday ( _compute_queens_bday($year) )
            {    # Queens Birthday day
                $holidays{$holiday} = 'Queens Birthday';
            }
        }
        my ($holiday_hashref);
        if ( $state eq 'VIC' ) {
            unless ( ( exists $params{no_melbourne_cup} )
                && ( $params{no_melbourne_cup} ) )
            {
                foreach my $holiday ( _compute_melbourne_cup_day($year) )
                {    # Melbourne Cup day
                    $holidays{$holiday} = 'Melbourne Cup Day';
                }
            }
        }
        elsif ( $state eq 'QLD' ) {
            unless ( ( exists $params{no_show_day} )
                && ( $params{no_show_day} ) )
            {
                foreach my $holiday ( _compute_qld_show_day($year) )
                {    # Queensland Show day
                    $holidays{$holiday} = 'Queensland Show Day';
                }
            }
        }
        elsif ( $state eq 'NSW' ) {
            if (   ( exists $params{include_bank_holiday} )
                && ( $params{include_bank_holiday} ) )
            {
                foreach my $holiday ( _compute_nsw_act_bank_holiday($year) )
                {    # NSW bank holiday
                    $holidays{$holiday} = 'Bank Holiday';
                }
            }
            foreach my $holiday ( _compute_nsw_sa_act_labour_day($year) )
            {        # NSW labour day
                $holidays{$holiday} = 'Labour Day';
            }
        }
        elsif ( $state eq 'SA' ) {
            foreach my $holiday ( _compute_nsw_sa_act_labour_day($year) )
            {        # SA labour day
                $holidays{$holiday} = 'Labour Day';
            }
        }
        elsif ( $state eq 'NT' ) {
            foreach my $holiday_hashref (
                _compute_nt_show_day_hash( $year, \%params ) )
            {        # NT regional show days
                $holidays{ $holiday_hashref->{date} } =
                  $holiday_hashref->{name};
            }
            foreach my $holiday ( _compute_nt_picnic_day($year) )
            {        # NT picnic day
                $holidays{$holiday} = 'Picnic Day';
            }
        }
        elsif ( $state eq 'WA' ) {
            foreach my $holiday ( _compute_wa_queens_bday($year) )
            {        # WA Queens Birthday day
                $holidays{$holiday} = 'Queens Birthday';
            }
        }
        elsif ( $state eq 'ACT' ) {
            if (   ( exists $params{include_bank_holiday} )
                && ( $params{include_bank_holiday} ) )
            {
                foreach my $holiday ( _compute_nsw_act_bank_holiday($year) )
                {    # ACT bank holiday
                    $holidays{$holiday} = 'Bank Holiday';
                }
            }
            foreach my $holiday ( _compute_nsw_sa_act_labour_day($year) )
            {        # ACT labour day
                $holidays{$holiday} = 'Labour Day';
            }
        }
        elsif ( $state eq 'TAS' ) {
            if ( exists $params{holidays} ) {
                if (   ( ref $params{holidays} )
                    && ( ( ref $params{holidays} ) eq 'ARRAY' ) )
                {
                    foreach my $allowed ( @{ $params{holidays} } ) {
                        $allowed = lc($allowed);
                        $allowed =~ s/\s*//g;
                        if ( $allowed eq 'burnieshow' ) {
                            foreach my $holiday ( _compute_burnie_show($year) )
                            {    # TAS burnie show day
                                $holidays{$holiday} = 'Burnie Show';
                            }
                        }
                        elsif ( $allowed eq 'launcestonshow' ) {
                            foreach
                              my $holiday ( _compute_launceston_show($year) )
                            {    # TAS launceston show day
                                $holidays{$holiday} = 'Launceston Show';
                            }
                        }
                        elsif ( $allowed eq 'flindersislandshow' ) {
                            foreach my $holiday (
                                _compute_flinders_island_show($year) )
                            {    # TAS flinders island show day
                                $holidays{$holiday} = 'Flinders Island Show';
                            }
                        }
                        elsif ( $allowed eq 'hobartshow' ) {
                            foreach my $holiday ( _compute_hobart_show($year) )
                            {    # TAS hobart show day
                                $holidays{$holiday} = 'Hobart Show';
                            }
                        }
                        elsif ( $allowed eq 'recreationday' ) {
                            foreach
                              my $holiday ( _compute_recreation_day($year) )
                            {    # TAS recreation day
                                $holidays{$holiday} = 'Recreation Day';
                            }
                        }
                        elsif ( $allowed eq 'devonportshow' ) {
                            foreach
                              my $holiday ( _compute_devonport_show($year) )
                            {    # TAS devonport show day
                                $holidays{$holiday} = 'Devonport Show';
                            }
                        }
                    }
                }
                else {
                    croak(
                        "Holidays parameter must be a reference to an array\n");
                }
            }
        }
        foreach my $holiday_hashref ( _compute_christmas_hash( $year, $state ) )
        {    # christmas day + boxing day
            $holidays{ $holiday_hashref->{date} } = $holiday_hashref->{name};
        }
        foreach my $date ( keys %holidays ) {
            $cached{$concat}{$year}{$date} = $holidays{$date};
        }
    }
    return ( \%holidays );
}

sub is_holiday {
    my ( $year, $month, $day, $state, $params ) = @_;
    my ($concat) = $state ||= DEFAULT_STATE;
    foreach my $key (%$params) {
        next unless ( $params->{$key} );
        if ( ref $params->{$key} ) {
            if ( ( ref $params->{$key} ) eq 'ARRAY' ) {
                $concat .= '_' . $key;
                foreach my $element ( @{ $params->{$key} } ) {
                    $concat .= '_' . $element;
                }
            }
        }
        else {
            $concat .= '_' . $key . '_' . $params->{$key};
        }
        $concat = lc($concat);
        $concat =~ s/\s*//g;
    }
    unless ( ( exists $cached{$concat} ) && ( exists $cached{$concat}{$year} ) )
    {
        holidays( 'year' => $year, 'state' => $state, %$params );
    }
    my ($date) = sprintf( "%02d%02d", $month, $day );
    if (   ( exists $cached{$concat} )
        && ( exists $cached{$concat}{$year}{$date} ) )
    {
        return 1;
    }
    else {
        return 0;
    }
}

our (@daysInMonth) = ( 31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 )
  ;    # feb will be calculated locally

sub _compute_christmas_hash {
    my ( $year, $state ) = @_;
    my ($day)   = 25;
    my ($month) = 12;
    my ($date) = Time::Local::timelocal( 0, 0, 0, $day, ( $month - 1 ), $year );
    my ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
      localtime($date);
    my ($boxingDay) = 'Boxing Day';
    if ( $state eq 'SA' ) {
        $boxingDay = 'Proclamation Day';
    }
    my (@holidays);
    push @holidays,
      {
        'name' => 'Christmas Day',
        'date' => sprintf( "%02d%02d", $month, $day ),
      };
    push @holidays,
      {
        'name' => $boxingDay,
        'date' => sprintf( "%02d%02d", $month, ( $day + 1 ) ),
      };
    if ( $wday == 5 ) {    # Christmas is on a Friday
        push @holidays,
          {
            'name' => "$boxingDay Holiday",
            'date' => sprintf( "%02d%02d", $month, ( $day + 2 ) ),
          };
    }
    elsif ( $wday == 6 ) {    # Christmas is on a Saturday
        push @holidays,
          {
            'name' => 'Christmas Day Holiday',
            'date' => sprintf( "%02d%02d", $month, ( $day + 2 ) ),
          };
        push @holidays,
          {
            'name' => "$boxingDay Holiday",
            'date' => sprintf( "%02d%02d", $month, ( $day + 3 ) ),
          };
    }
    elsif ( $wday == 0 ) {    # Christmas is on a Sunday
        push @holidays,
          {
            'name' => 'Christmas Day Holiday',
            'date' => sprintf( "%02d%02d", $month, ( $day + 2 ) ),
          };
    }
    return (@holidays);
}

sub _compute_nt_show_day_hash {
    my ( $year, $params ) = @_;
    my ( $month, $numFridays, $name );
    if ( ( exists $params->{region} ) && ( defined $params->{region} ) ) {
        my ($region) = lc( $params->{region} );
        $region =~ s/\s*//g;
        if ( $region eq 'alicesprings' ) {
            $name       = 'Alice Springs Show Day';
            $month      = 6;
            $numFridays = 1;
        }
        elsif ( $region eq 'tennantcreek' ) {
            $name       = 'Tennant Creek Show Day';
            $month      = 6;
            $numFridays = 2;
        }
        elsif ( $region eq 'katherine' ) {
            $name       = 'Katherine Show Day';
            $month      = 6;
            $numFridays = 3;
        }
        elsif ( $region eq 'darwin' ) {
            $name       = 'Darwin Show Day';
            $month      = 6;
            $numFridays = 4;
        }
        elsif ( $region eq 'borroloola' ) {
            $name       = 'Borrolooda Show Day';
            $month      = 7;
            $numFridays = 4;
        }
        else {
            croak("Unknown region\n");
        }
    }
    else {
        $name       = 'Darwin Show Day';
        $month      = 6;
        $numFridays = 4;
    }
    my ($day)     = 1;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($fridays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $fridays < $numFridays ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 5 ) {
            $fridays += 1;
        }
        if ( $fridays < $numFridays ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    my (@holidays) = (
        {
            'name' => $name,
            'date' => sprintf( "%02d%02d", ( $month + 1 ), $day ),
        }
    );
    return (@holidays);
}

sub _compute_qld_show_day
{ # second wednesday in august, except when there are five wednesdays in august when it is the third wednesday
    my ($year)       = @_;
    my ($day)        = 1;
    my ($month)      = 7;
    my ($date)       = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($wednesdays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    my ($numWednesdays);
    ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
      localtime($date);

    if ( ( $wday >= 1 ) && ( $wday <= 3 ) ) {
        $numWednesdays = 3;
    }
    else {
        $numWednesdays = 2;
    }
    while ( $wednesdays < $numWednesdays ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 3 ) {
            $wednesdays += 1;
        }
        if ( $wednesdays < $numWednesdays ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_devonport_show
{ # friday nearest last day in november, but not later than first day in december
    my ($year)  = @_;
    my ($month) = 10;
    my ($day)   = $daysInMonth[$month];
    my ($date)  = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
      localtime($date);
    if ( $wday == 4 ) {    # thursday
        $day   = 1;
        $month = 11;
    }
    elsif ( $wday == 5 ) {    # friday
    }
    elsif ( $wday == 6 ) {    # saturday
        $day -= 1;
    }
    elsif ( $wday == 0 ) {    # sunday
        $day -= 2;
    }
    elsif ( $wday == 1 ) {    # monday
        $day -= 3;
    }
    elsif ( $wday == 2 ) {    # tuesday
        $day -= 4;
    }
    elsif ( $wday == 3 ) {    # wednesday
        $day -= 5;
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_devonport_cup
{  # wednesday not earlier than fifth and not later than the eleventh of January
    my ($year)  = @_;
    my ($day)   = 5;
    my ($month) = 0;
    my ($date)  = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
      localtime($date);
    while ( $wday != 3 ) {
        $day += 1;
        $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_launceston_cup {    # last wednesday in feb
    my ($year)  = @_;
    my ($month) = 1;
    my ($day);
    if ( ( $year % 4 ) && ( ( not( $year % 100 ) ) || ( $year % 400 ) ) ) {
        $day = 28;
    }
    else {
        $day = 29;
    }

    my ($date) = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($wednesdays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $wednesdays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 3 ) {
            $wednesdays += 1;
        }
        if ( $wednesdays < 1 ) {
            $day -= 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_eight_hours_day {    # second monday in march
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 2;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 2 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 2 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_king_island_show {    # first tuesday in march
    my ($year)     = @_;
    my ($day)      = 1;
    my ($month)    = 2;
    my ($date)     = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($tuesdays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $tuesdays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 2 ) {
            $tuesdays += 1;
        }
        if ( $tuesdays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_hobart_regatta {    # second monday in feb
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 1;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 2 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 2 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_canberra_day {    # third monday in march
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 2;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 3 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 3 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_recreation_day {    # first monday in november
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 10;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_melbourne_cup_day {    # first tuesday in november
    my ($year)     = @_;
    my ($day)      = 1;
    my ($month)    = 10;
    my ($date)     = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($tuesdays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $tuesdays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 2 ) {
            $tuesdays += 1;
        }
        if ( $tuesdays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_wa_foundation_day {    # first monday in june
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 5;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_queens_bday {    # second monday in june
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 5;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 2 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 2 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_sa_volunteers_day {    # third monday in may up excluding 2006
    my ($year) = @_;
    if ( $year == 2006 ) {
        return ();
    }
    my ($day)     = 1;
    my ($month)   = 4;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 3 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 3 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_sa_adelaide_cup_day {    # second monday in march in 2006
    my ($year) = @_;
    if ( $year != 2006 ) {
        return ();
    }
    my ($day)     = 1;
    my ($month)   = 2;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 2 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 2 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_vic_labour_day {    # second monday in march
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 2;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 2 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 2 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_wa_labour_day {    # first monday in march
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 2;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_nt_may_day {    # first monday in may
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 4;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_agfest {    # friday following first thursday in may
    my ($year)      = @_;
    my ($day)       = 1;
    my ($month)     = 4;
    my ($date)      = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($thursdays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $thursdays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 4 ) {
            $thursdays += 1;
        }
        if ( $thursdays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), ( $day + 1 ) ) );
}

sub _compute_burnie_show {    # friday preceding first saturday in october
    my ($year)      = @_;
    my ($day)       = 1;
    my ($month)     = 9;
    my ($date)      = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($saturdays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $saturdays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 6 ) {
            $saturdays += 1;
        }
        if ( $saturdays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    if ( $day == 1 ) {
        return ( sprintf( "%02d%02d", $month, $daysInMonth[ $month - 1 ] ) );
    }
    else {
        return ( sprintf( "%02d%02d", ( $month + 1 ), ( $day - 1 ) ) );
    }
}

sub _compute_launceston_show {   # thursday preceding second saturday in october
    my ($year)      = @_;
    my ($day)       = 1;
    my ($month)     = 9;
    my ($date)      = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($saturdays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $saturdays < 2 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 6 ) {
            $saturdays += 1;
        }
        if ( $saturdays < 2 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), ( $day - 2 ) ) );
}

sub _compute_flinders_island_show { # friday preceding third saturday in october
    my ($year)      = @_;
    my ($day)       = 1;
    my ($month)     = 9;
    my ($date)      = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($saturdays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $saturdays < 3 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 6 ) {
            $saturdays += 1;
        }
        if ( $saturdays < 3 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), ( $day - 1 ) ) );
}

sub _compute_hobart_show {    # thursday preceding fourth saturday in october
    my ($year)      = @_;
    my ($day)       = 1;
    my ($month)     = 9;
    my ($date)      = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($saturdays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $saturdays < 4 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 6 ) {
            $saturdays += 1;
        }
        if ( $saturdays < 4 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), ( $day - 2 ) ) );
}

sub _compute_nt_picnic_day {    # first monday in august
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 7;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_nsw_act_bank_holiday {    # first monday in august
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 7;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_nsw_sa_act_labour_day {    # first monday in october
    my ($year)    = @_;
    my ($day)     = 1;
    my ($month)   = 9;
    my ($date)    = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
    my ($mondays) = 0;
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    while ( $mondays < 1 ) {
        ( $sec, $min, $hour, undef, undef, undef, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 1 ) {
            $mondays += 1;
        }
        if ( $mondays < 1 ) {
            $day += 1;
            $date = Time::Local::timelocal( 0, 0, 0, $day, $month, $year );
        }
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_wa_queens_bday
{ # monday closest to 30 september???  Formula unknown. Seems to have a 9 day spread???
    my ($year) = @_;
    my ( $day, $month );
    if ( $year == 2004 ) {
        $day   = 4;
        $month = 9;
    }
    elsif ( $year == 2005 ) {
        $day   = 26;
        $month = 8;
    }
    elsif ( $year == 2006 ) {
        $day   = 2;
        $month = 9;
    }
    elsif ( $year == 2007 ) {
        $day   = 1;
        $month = 9;
    }
    elsif ( $year == 2008 ) {
        $day   = 29;
        $month = 8;
    }
    elsif ( $year == 2009 ) {
        $day   = 28;
        $month = 8;
    }
    elsif ( $year == 2010 ) {
        $day   = 27;
        $month = 8;
    }
    elsif ( $year == 2011 ) {
        $day   = 28;
        $month = 9;
    }
    elsif ( $year == 2012 ) {
        $day   = 1;
        $month = 9;
    }
    elsif ( $year == 2013 ) {
        $day   = 30;
        $month = 8;
    }
    elsif ( $year == 2014 ) {
        $day   = 29;
        $month = 8;
    }
    elsif ( $year == 2015 ) {
        $day   = 28;
        $month = 8;
    }
    elsif ( $year == 2016 ) {
        $day   = 26;
        $month = 8;
    }
    else {
        croak(
            "Don't know how to calculate Queen's Birthday in WA for this year\n"
        );
    }
    return ( sprintf( "%02d%02d", ( $month + 1 ), $day ) );
}

sub _compute_easter {
    my ( $year,  $state ) = @_;
    my ( $month, $day )   = Date::Easter::gregorian_easter($year);
    my ($date) = Time::Local::timelocal( 0, 0, 0, $day, ( $month - 1 ), $year );
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    ( $sec, $min, $hour, $day, $month, $year, $wday, $yday, $isdst ) =
      localtime($date);
    unless ( $wday == 0 ) {
        croak("Easter must fall on a Sunday\n");
    }
    my (@holidays);

    # good friday + easter saturday
    if ( $month == 2 ) {    # march
        push @holidays, sprintf( "%02d%02d", ( $month + 1 ), ( $day - 2 ) );
        push @holidays, sprintf( "%02d%02d", ( $month + 1 ), ( $day - 1 ) );
    }
    elsif ( $month == 3 ) {    # april
        if ( $day == 2 ) {
            push @holidays,
              sprintf( "%02d%02d", $month, $daysInMonth[ $month - 1 ] );
            push @holidays, sprintf( "%02d%02d", ( $month + 1 ), 1 );
        }
        elsif ( $day == 1 ) {
            push @holidays,
              sprintf( "%02d%02d", $month, ( $daysInMonth[ $month - 1 ] - 1 ) );
            push @holidays,
              sprintf( "%02d%02d", $month, ( $daysInMonth[ $month - 1 ] ) );
        }
        else {
            push @holidays, sprintf( "%02d%02d", ( $month + 1 ), ( $day - 2 ) );
            push @holidays, sprintf( "%02d%02d", ( $month + 1 ), ( $day - 1 ) );
        }
    }
    else {
        croak("Easter has to fall in march or april\n");
    }

    # easter sunday
    push @holidays, sprintf( "%02d%02d", ( $month + 1 ), $day );

    # easter monday
    if ( $month == 2 ) {    # march
        if ( $day == $daysInMonth[$month] ) {
            push @holidays, sprintf( "%02d%02d", ( $month + 2 ), 1 );
        }
        else {
            push @holidays, sprintf( "%02d%02d", ( $month + 1 ), ( $day + 1 ) );
        }
    }
    elsif ( $month == 3 ) {
        push @holidays, sprintf( "%02d%02d", ( $month + 1 ), ( $day + 1 ) );
    }
    if ( $state eq 'TAS' ) {
        if ( $month == 2 ) {    # march
            if ( $day == $daysInMonth[$month] ) {
                push @holidays, sprintf( "%02d%02d", ( $month + 2 ), 2 );
            }
            elsif ( ( $day + 1 ) == $daysInMonth[$month] ) {
                push @holidays, sprintf( "%02d%02d", ( $month + 2 ), 1 );
            }
            else {
                push @holidays,
                  sprintf( "%02d%02d", ( $month + 1 ), ( $day + 2 ) );
            }
        }
        elsif ( $month == 3 ) {
            push @holidays, sprintf( "%02d%02d", ( $month + 1 ), ( $day + 1 ) );
        }
    }
    return (@holidays);
}

sub _compute {
    my ( $day, $month, $year, $params ) = @_;
    my ($date) = Time::Local::timelocal( 0, 0, 0, $day, ( $month - 1 ), $year );
    my ( $sec, $min, $hour, $wday, $yday, $isdst );
    my (@holidays);
    push @holidays, sprintf( "%02d%02d", $month, $day );
    if ( $params->{day_in_lieu} ) {
        ( $sec, $min, $hour, $day, $month, $year, $wday, $yday, $isdst ) =
          localtime($date);
        if ( $wday == 0 ) {
            if ( $daysInMonth[$month] == $day ) {
                if ( $month == 11 ) {
                    $day   = 1;
                    $month = 0;
                    $year += 1;
                }
                else {
                    $day = 1;
                    $month += 1;
                }
            }
            else {
                $day += 1;
            }
            push @holidays, sprintf( "%02d%02d", ( $month + 1 ), $day );
        }
        elsif ( $wday == 6 ) {
            if ( $daysInMonth[$month] == $day ) {
                if ( $month == 11 ) {
                    $day   = 1;
                    $month = 0;
                    $year += 1;
                }
                else {
                    $day = 1;
                    $month += 1;
                }
            }
            elsif ( $daysInMonth[$month] == ( $day + 1 ) ) {
                if ( $month == 11 ) {
                    $day   = 1;
                    $month = 0;
                    $year += 1;
                }
                else {
                    $day = 1;
                    $month += 1;
                }
            }
            else {
                $day += 2;
            }
            push @holidays, sprintf( "%02d%02d", ( $month + 1 ), $day );
        }
    }
    return (@holidays);
}

1;
