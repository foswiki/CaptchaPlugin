# Visual Confirmation Plugin for Foswiki Collaboration
# Platform, http://Foswiki.org/
#
# Copyright (C) 2011-2024 Michael Daum, http://michaeldaumconsulting.com
# Copyright (C) 2005-2007 Koen Martens, kmartens@sonologic.nl
# Copyright (C) 2007 KwangErn Liew, kwangern@musmo.com
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

package Foswiki::Plugins::CaptchaPlugin;

=begin TML

---+ package Foswiki::Plugins::CaptchaPlugin

base class to hook into the foswiki core

=cut

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Plugins ();
use Foswiki::OopsException ();
use Foswiki::Contrib::JsonRpcContrib ();
use Foswiki::Plugins::JQueryPlugin ();

our $VERSION = '2.30';
our $RELEASE = '%$RELEASE%';
our $SHORTDESCRIPTION = 'A visual challenge-response test to prevent automated scripts from using the wiki';
our $LICENSECODE = '%$LICENSECODE%';
our $NO_PREFS_IN_TOPIC = 1;
our $core;
our $origValidateRegistration;    # used for pre 2.3 foswikis

BEGIN {
  if ($Foswiki::Plugins::VERSION < 2.3) {
    # monkey-patch our version

    require Foswiki::UI::Register;

    no warnings 'redefine'; ## no critic
    $origValidateRegistration = \&Foswiki::UI::Register::_validateRegistration;
    *Foswiki::UI::Register::_validateRegistration = \&Foswiki::Plugins::CaptchaPlugin::validateRegistration;
    use warnings 'redefine';
  }
}

=begin TML

---++ initPlugin($topic, $web, $user) -> $boolean

initialize the plugin, automatically called during the core initialization process

=cut

sub initPlugin {

  # register macros
  Foswiki::Func::registerTagHandler('CAPTCHA', sub { return getCore(shift)->CAPTCHA(@_); });
  Foswiki::Func::registerTagHandler('CAPTCHAFORM', sub { return getCore(shift)->CAPTCHAFORM(@_); });
  Foswiki::Func::registerTagHandler('CAPTCHACHECK', sub { return getCore(shift)->CAPTCHACHECK(@_); });

  # register rest backends
  Foswiki::Func::registerRESTHandler("validate", \&restValidate, 
    authenticate => 0,
    validate => 0,
    http_allow => 'GET, POST',
  );

  # register jsonrpc backends
  Foswiki::Contrib::JsonRpcContrib::registerMethod(
    "CaptchaPlugin",
    "create",
    sub {
      return getCore(shift)->jsonRpcCreate(@_);
    }
  );

  # register jquery plugin
  Foswiki::Plugins::JQueryPlugin::registerPlugin("captcha", "Foswiki::Plugins::CaptchaPlugin::JQueryPlugin");

  # enter CaptchaEnableSave context
  Foswiki::Func::getContext()->{CaptchaEnableSave} = 1
    if $Foswiki::cfg{Plugins}{CaptchaPlugin}{EnableSave};

  return 1;
}

=begin TML

---++ finishPlugin

finish the plugin and the core if it has been used,
automatically called during the core initialization process

=cut

sub finishPlugin {
  undef $core;
}

=begin TML

---++ ObjectMethod beforeSaveHandler()


=cut

sub beforeSaveHandler {
  return unless $Foswiki::cfg{Plugins}{CaptchaPlugin}{EnableSave};

  getCore()->beforeSaveHandler(@_);
}

=begin TML

---++ getCore() -> $core

returns a singleton Foswiki::Plugins::CaptchaPlugin::Core object for this plugin; a new core is allocated 
during each session request; once a core has been created it is destroyed during =finishPlugin()=

=cut

sub getCore {
  my $session = shift;

  $session ||= $Foswiki::Plugins::SESSION;

  unless ($core) {
    require Foswiki::Plugins::CaptchaPlugin::Core;
    $core = new Foswiki::Plugins::CaptchaPlugin::Core($session, @_);
  }

  return $core;
}

=begin TML

---++ ObjectMethod validateRegistrationHandler()

Handler for $Foswiki::Plugins::VERSION >= 2.3 and later

=cut

sub validateRegistrationHandler {
  return getCore()->validateRegistration(@_);
}

=begin TML

---++ ObjectMethod validateRegistration()

only used for $Foswiki::Plugins::VERSION < 2.3

=cut

sub validateRegistration {
  my ($session, $data, $requireForm) = @_;

  # only do it for non-bulk-registration
  if ($requireForm) {

    my $query = Foswiki::Func::getCgiQuery();
  
    # not using $data ... using url params directly
    my $challenge = $query->param("captcha_challenge");
    my $response = $query->param("captcha_response");

    unless(getCore($session)->isValidCaptcha($challenge, $response, 1)) {
      throw Foswiki::OopsException(
        'captcha',
        web => $Foswiki::cfg{SystemWebName}, # SMELL: these aren't set properly after a register cgi call
        topic => 'UserRegistration',
        def => 'captcha::invalid_response',
      );
    }
  }

  &$origValidateRegistration($session, $data, $requireForm);
}

=begin TML

---++ ObjectMethod restValidate()

=cut

sub restValidate {
  my $session = shift;

  my $query = Foswiki::Func::getCgiQuery();
  my $challenge = $query->param("challenge");
  my $response = $query->param("response");

  return ($challenge && $response && getCore($session)->isValidCaptcha($challenge, $response)) ? "true" : "false";
}

1;
