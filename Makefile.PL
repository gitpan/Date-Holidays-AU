
use ExtUtils::MakeMaker;

WriteMakefile(
                'NAME'          => 'Date::Holidays::AU',
                'VERSION_FROM'  => 'lib/Date/Holidays/AU.pm',
                'PREREQ_PM'     => {
                                'Test::More' => 0,
				'Time::Local' => 0,
				'Date::Easter' => 0,
				'Carp' => 0,
                                        },
);
