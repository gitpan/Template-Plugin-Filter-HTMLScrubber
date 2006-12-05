#!perl -T

use Test::Base;
use Template;
use Template::Plugin::Filter::HTMLScrubber;

plan tests => 7;

my $tt = Template->new({
		INTERPOLATE  => 1,
		PLUGINS => {
				HTMLScrubber => 'Template::Plugin::Filter::HTMLScrubber'
		}
});

ok($tt);
ok(UNIVERSAL::isa($tt, 'Template'));

sub expand_sanitize {
		my $input = $_[0];
		my $output;

		my $config = {
				base => {
					allow => [qw/a br del /],
					rule => [
						a => {
							'*' => 1,
						},
						br => 1,
						del => 1,
					],
					default => [
						0 => {
							'*' => 1,
							'href' => 1,
							'src' => 1,
						}
					]
				},
				strict => {
					allow => [qw/a br/],
					rule => [
						a => {
							'*' => 1,
						},
						br => 1,
						del => 1,
					],
					default => [
						0 => {
							'*' => 1,
							'href' => 1,
							'src' => 1,
						}
					]
				},
				loose => {
					allow => [qw/a br del i/],
					rule => [
						a => {
							'*' => 1,
						},
						br => 1,
						del => 1,
					],
					default => [
						0 => {
							'*' => 1,
							'href' => 1,
							'src' => 1,
						}
					]
				},
			
		};

		my $test_str = '<a href="test">test</a><br><del>del</del>';
		$tt->process(\$input, {config => $config, test_str => $test_str }, \$output);
		return $output;
}

run_is 'input' => 'expected';

__END__
=== Expand sanitize test
--- input expand_sanitize
[% USE HTMLScrubber config %][% FILTER html_scrubber('base') %]<a href="test">test</a><br><del>del</del>[% END %]
--- expected
<a href="test">test</a><br><del>del</del>
=== Expand sanitize test2
--- input expand_sanitize
[% USE HTMLScrubber config %][% FILTER html_scrubber('strict') %]<a href="test">test</a><br><del>del</del>[% END %]
--- expected
<a href="test">test</a><br>del
=== Expand sanitize test3
--- input expand_sanitize
[% USE HTMLScrubber config %][% FILTER html_scrubber('strict',['+del']) %]<a href="test">test</a><br><del>del</del>[% END %]
--- expected
<a href="test">test</a><br><del>del</del>
=== Expand sanitize test4
--- input expand_sanitize
[% USE HTMLScrubber config %][% FILTER html_scrubber('loose',['-a','-del']) %]<a href="test">test</a><br><del>del</del>[% END %]
--- expected
test<br>del
=== Expand sanitize test5
--- input expand_sanitize
[% USE HTMLScrubber config %][% test_str | html_scrubber('loose',['-a','-del']) %]
--- expected
test<br>del

