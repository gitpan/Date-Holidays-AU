
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
                ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
                (ABSTRACT_FROM  => 'lib/Date/Holidays/AU.pod', # retrieve abstract from module
                 AUTHOR         => 'David Dick <ddick@cpan.org>') : ()),
                ($ExtUtils::MakeMaker::VERSION ge '6.30_00' ? # shamelessly copied this from Template Toolkit
                (LICENSE           => 'perl') : ()),
);
