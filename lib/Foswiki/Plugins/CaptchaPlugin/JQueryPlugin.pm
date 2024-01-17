# Visual Confirmation Plugin for Foswiki Collaboration
# Platform, http://Foswiki.org/
#
# Copyright (C) 2011-2024 Michael Daum, http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html
#

package Foswiki::Plugins::CaptchaPlugin::JQueryPlugin;

=begin TML

---+ package Foswiki::Plugins::CaptchaPlugin::JQueryPlugin

stub for the jQuery module

=cut

use strict;
use warnings;

use Foswiki::Plugins::CaptchaPlugin ();
use Foswiki::Plugins::JQueryPlugin::Plugin ();
our @ISA = qw( Foswiki::Plugins::JQueryPlugin::Plugin );

=begin TML

---++ ClassMethod new() -> $core

constructor for the jQuery object

=cut

sub new {
  my $class = shift;

  my $this = bless(
    $class->SUPER::new(
      name => 'Captcha',
      version => $Foswiki::Plugins::CaptchaPlugin::VERSION,
      author => 'Michael Daum',
      homepage => 'http://foswiki.org/Extensions/CaptchaPlugin',
      javascript => ['jquery.captcha.js'],
      css => ['jquery.captcha.css'],
      documentation => 'CaptchaPlugin',
      puburl => '%PUBURLPATH%/%SYSTEMWEB%/CaptchaPlugin',
      dependencies => ['render', 'jsonrpc', ],
    ),
    $class
  );

  return $this;
}

1;

