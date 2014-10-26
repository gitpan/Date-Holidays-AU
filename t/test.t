#! /usr/bin/perl -I/home/dave/Date-Holidays-AU-0.01/lib -w

use Date::Holidays::AU qw( is_holiday holidays );
use Test::More(tests => 105 );
use strict;

# VIC http://www.info.vic.gov.au/resources/publichols.htm
# NT http://www.nt.gov.au/ocpe/public_holidays.shtml
# WA http://www.whatsthenumber.com/oz/know/dates/holiday-wa.htm
# QLD http://www.wageline.qld.gov.au/publicholidays/list_pubhols.html
# NSW http://www.industrialrelations.nsw.gov.au/holidays/
# SA http://www.eric.sa.gov.au/show_page.jsp?id=2483
# ACT http://www.workcover.act.gov.au/labourreg/publicholidays.html
# TAS http://www.wst.tas.gov.au/attach/stathol2004.pdf

eval { holidays(); };
ok($@ ne '', "Year must exist");
eval { holidays( 'year' => undef); };
ok($@ ne '', "Year must be defined");
eval { holidays( 'year' => 'd144'); };
ok($@ ne '', "Year must be be numeric");
eval { holidays( 'year' => 2004, 'state' => 'V1C' ); };
ok($@ ne '', "State must exist");
my ($holidays);
eval { $holidays = holidays( 'year' => 2004, 'state' => 'VIC' ); };
ok($@ eq '', "Holidays retrieved");
ok(((ref $holidays) && ((ref $holidays) eq 'HASH')), "holidays returns a hashref");
ok(((exists $holidays->{1225}) && (defined $holidays->{1225})), "Found Christmas");
ok($holidays->{1225} =~ /\w+/, "Christmas has a text representation (" . $holidays->{1225} . ")");
ok(is_holiday(2005, 1, 3, 'VIC'), "Extra New Years Day 2005");
ok(is_holiday(2005, 1, 1, 'VIC'), "New Years Day 2005");
ok(is_holiday(2004, 1, 7, 'TAS', { 'holidays' => ['Devonport Cup']}), "Devonport Cup 2004");
ok(is_holiday(2006, 1, 11, 'TAS', { 'holidays' => ['Devonport Cup']}), "Devonport Cup 2006");
ok(not(is_holiday(2004, 1, 7, 'TAS', { 'holidays' => ['Recreation Day']})), "Not Devonport Cup 2004");
ok(is_holiday(2005, 1, 26, 'VIC'), "Australia Day 2005");
ok(is_holiday(2004, 2, 9, 'TAS', { 'holidays' => [ 'Hobart Show','Hobart Regatta' ]}), "Hobart Regatta 2004");
ok(not(is_holiday(2004, 2, 9, 'TAS', { 'holidays' => [ 'Hobart Show' ]})), "Not Hobart Regatta 2004");
ok(is_holiday(2004, 2, 25, 'TAS', { 'holidays' => [ 'Launceston Cup' ]}), "Launceston Cup 2004");
ok(not(is_holiday(2004, 2, 25, 'TAS', { 'holidays' => [ 'Devonport Cup' ]})), "Not Launceston Cup 2004");
ok(is_holiday(2004, 3, 2, 'TAS', { 'holidays' => [ 'King Island Show' ]}), "King Island Show 2004");
ok(not(is_holiday(2004, 3, 2, 'TAS', { 'holidays' => [ 'Devonport Cup' ]})), "Not King Island Show 2004");
ok(is_holiday(2004, 3, 8, 'TAS'), "Eight Hours Day 2004");
ok(is_holiday(2005, 3, 7, 'WA'), "WA Labour Day 2005");
ok(is_holiday(2004, 3, 15, 'ACT'), "Canberra Day 2004");
ok(is_holiday(2004, 3, 15, 'ACT'), "Canberra Day 2004");
ok(is_holiday(2005, 3, 21, 'ACT'), "Canberra Day 2004");
ok(not(is_holiday(2005, 3, 8, 'WA')), "Not WA Labour Day 2005");
ok(is_holiday(2004, 4, 9, 'VIC'), "Good Friday 2004");
ok(is_holiday(2004, 4, 10, 'WA'), "Easter Saturday 2004");
ok(is_holiday(2004, 4, 11, 'NT'), "Easter Sunday 2004");
ok(is_holiday(2005, 3, 28, 'VIC'), "Easter Monday 2005");
ok(not(is_holiday(2005, 3, 29, 'VIC')), "No Easter Tuesday in VIC");
ok(is_holiday(2005, 3, 29, 'TAS'), "Easter Tuesday 2005 in TAS");
ok(is_holiday(2005, 3, 14, 'VIC'), "Victorian Labour Day 2005");
ok(is_holiday(2006, 3, 13, 'SA'), "Adelaide Cup Day 2006");
ok(not(is_holiday(2005, 3, 14, 'SA')), "No Adelaide Cup Day in 2005");
ok(not(is_holiday(2005, 3, 14, 'NSW')), "Not NSW Labour Day 2005");
ok(is_holiday(2004, 4, 25, 'VIC'), "ANZAC Day 2004");
ok(is_holiday(2004, 4, 25, 'WA'), "ANZAC Day 2004");
ok(not(is_holiday(2004, 4, 26, 'VIC')), "No extra holiday for ANZAC Day 2004 in VIC");
ok(not(is_holiday(2004, 4, 26, 'TAS')), "No extra holiday for ANZAC Day 2004 in TAS");
ok(is_holiday(2004, 4, 26, 'WA'), "Extra holiday for ANZAC Day 2004 everywhere else");
ok(is_holiday(2005, 5, 16, 'SA'), "Volunteers Day 2005");
ok(is_holiday(2003, 5, 5, 'NT'), "May Day 2003");
ok(is_holiday(2005, 5, 2, 'NT'), "May Day 2005");
ok(not(is_holiday(2004, 5, 7, 'TAS')), "Not Agfest 2003");
ok(is_holiday(2004, 5, 7, 'TAS', { 'holidays' => [ 'Agfest' ]}), "Agfest 2004");
ok(not(is_holiday(2004, 5, 7, 'TAS', { 'holidays' => [ 'Devonport Cup' ]})), "Not Agfest 2004");
ok(not(is_holiday(2004, 5, 7, 'TAS')), "Not Agfest anywhere else in 2004");
ok(not(is_holiday(2005, 5, 15, 'SA')), "No Volunteers Day in 2006");
ok(is_holiday(2005, 6, 6, 'WA'), "Foundation Day 2005");
ok(is_holiday(2004, 6, 14, 'TAS'), "Queens Birthday 2004");
ok(is_holiday(2005, 6, 13, 'VIC'), "Queens Birthday 2005");
ok(is_holiday(2005, 6, 13, 'ACT'), "Queens Birthday 2005");
ok(is_holiday(2005, 6, 13, 'NT'), "Queens Birthday 2005");
ok(is_holiday(2007, 6, 11, 'QLD'), "Queens Birthday 2007");
ok(is_holiday(2006, 6, 12, 'NSW'), "Queens Birthday 2007");
ok(is_holiday(2006, 6, 12, 'SA'), "Queens Birthday 2007");
ok(not(is_holiday(2006, 6, 12, 'WA')), "Not WA Queens Birthday 2007");
ok(not(is_holiday(2005, 7, 1, 'NT')), "Not Alice Springs Show Day 2005");
ok(is_holiday(2005, 7, 1, 'NT', { 'region' => 'Alice Springs' }), "Alice Springs Show Day 2005");
ok(is_holiday(2005, 7, 8, 'NT', { 'region' => 'Tennant Creek' }), "Tennant Creek Show Day 2005");
ok(is_holiday(2005, 7, 15, 'NT', { 'region' => 'Katherine' }), "Katherine Show Day 2005");
ok(is_holiday(2005, 7, 22, 'NT', { 'region' => 'Darwin' }), "Darwin Show Day 2005");
ok(is_holiday(2005, 7, 22, 'NT'), "Darwin Show Day 2005 (default)");
ok(not(is_holiday(2005, 7, 15, 'NT')), "Not Katherine Show Day 2005");
ok(not(is_holiday(2005, 8, 1, 'NSW')), "No NSW Bank Holiday 2005");
ok(is_holiday(2005, 8, 1, 'NSW', { 'include_bank_holiday' => 1 }), "NSW Bank Holiday 2005");
ok(not(is_holiday(2005, 8, 1, 'ACT')), "No ACT Bank Holiday 2005");
ok(is_holiday(2005, 8, 1, 'ACT', { 'include_bank_holiday' => 1 }), "ACT Bank Holiday 2005");
ok(not(is_holiday(2005, 8, 1, 'NSW', { 'include_bank_holiday' => 0 })), "No NSW Bank Holiday 2005");
ok(is_holiday(2005, 8, 1, 'NT'), "Picnic Day 2005");
ok(not(is_holiday(2005, 8, 2, 'NT')), "Not Picnic Day 2005");
ok(is_holiday(2004, 8, 11, 'QLD'), "Queensland Show 2004");
ok(not(is_holiday(2005, 8, 17, 'QLD', { 'no_show_day' => 1 })), "No Queensland Show 2005");
ok(is_holiday(2005, 8, 17, 'QLD', { 'no_show_day' => 0 }), "Queensland Show 2005");
ok(is_holiday(2005, 8, 17, 'QLD'), "Queensland Show 2005");
ok(is_holiday(2006, 8, 16, 'QLD'), "Queensland Show 2006");
ok(is_holiday(2007, 8, 15, 'QLD'), "Queensland Show 2007");
ok(is_holiday(2004, 10, 4, 'WA'), "WA Queens Birthday 2004");
ok(is_holiday(2005, 9, 26, 'WA'), "WA Queens Birthday 2005");
ok(is_holiday(2006, 10, 2, 'WA'), "WA Queens Birthday 2006");
ok(is_holiday(2007, 10, 1, 'WA'), "WA Queens Birthday 2007");
my ($year) = (localtime(time))[5] + 1900 + 1;
eval { is_holiday($year, 1, 1, 'WA'); };
ok($@ eq '', "WA Queens Birthday next year ($year)");
ok(is_holiday(2004, 10, 1, 'TAS', { 'holidays' => [ 'Burnie Show' ]}), "Burnie Show 2004");
ok(not(is_holiday(2004, 10, 1, 'TAS', { 'holidays' => [ 'Agfest' ]})), "Not Burnie Show 2004");
ok(is_holiday(2005, 10, 3, 'NSW'), "NSW Labour Day 2005");
ok(is_holiday(2005, 10, 3, 'NSW'), "ACT Labour Day 2005");
ok(is_holiday(2006, 10, 2, 'SA'), "SA Labour Day 2005");
ok(is_holiday(2004, 10, 7, 'TAS', { 'holidays' => ['Launceston Show','Burnie Show']}), "Launceston Show 2004");
ok(not(is_holiday(2004, 10, 7, 'TAS', { 'holidays' => ['Burnie Show']})), "Not Launceston Show 2004");
ok(is_holiday(2004, 10, 15, 'TAS', { 'holidays' => ['Burnie Show','Flinders Island Show']}), "Flinders Island Show 2004");
ok(not(is_holiday(2004, 10, 15, 'TAS', { 'holidays' => ['Burnie Show']})), "Not Flinders Island Show 2004");
ok(is_holiday(2004, 10, 21, 'TAS', { 'holidays' => ['Burnie Show','Hobart Show']}), "Hobart Show 2004");
ok(not(is_holiday(2004, 10, 21, 'TAS', { 'holidays' => ['Burnie Show']})), "Not Hobart Show 2004");
ok(is_holiday(2004, 11, 1, 'TAS', { 'holidays' => ['Recreation Day']}), "Recreation Day 2004 in Northern Tasmania");
ok(not(is_holiday(2004, 11, 1, 'TAS', { 'holidays' => ['Devonport Show']})), "Not Recreation Day anywhere else in 2004");
ok(not(is_holiday(2004, 11, 1, 'TAS')), "Not Recreation Day 2004");
ok(is_holiday(2005, 11, 1, 'VIC'), "Melbourne Cup 2005");
ok(not(is_holiday(2005, 11, 1, 'VIC', { 'no_melbourne_cup' => 1 })), "No Melbourne Cup 2005");
ok(is_holiday(2006, 11, 7, 'VIC', { 'no_melbourne_cup' => 0 }), "Melbourne Cup 2006");
ok(is_holiday(2004, 11, 26, 'TAS', { 'holidays' => ['Devonport Show']}), "Devonport Show 2004");
ok(is_holiday(2005, 11, 25, 'TAS', { 'holidays' => ['Devonport Show']}), "Devonport Show 2005");
ok(is_holiday(2006, 12, 1, 'TAS', { 'holidays' => ['Devonport Show']}), "Devonport Show 2006");
ok(not(is_holiday(2006, 12, 1, 'TAS', { 'holidays' => ['Recreation Day']})), "Not Devonport Show 2006");
ok(is_holiday(2005, 12, 27, 'VIC'), "Extra Christmas 2005");
