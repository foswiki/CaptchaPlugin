# Visual Confirmation Plugin for Foswiki Collaboration
# Platform, http://Foswiki.org/
#
# Copyright (C) 2011-2025 Michael Daum, http://michaeldaumconsulting.com
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

package Foswiki::Plugins::CaptchaPlugin::Core;

=begin TML

---+ package Foswiki::Plugins::CaptchaPlugin::Core

core class for this plugin

an singleton instance is allocated on demand

=cut

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Contrib::JsonRpcContrib::Error ();
use Error qw(:try);
use JSON ();


=begin TML

---++ ClassMethod new() -> $core

constructor for a Core object

=cut

sub new {
  my $class = shift;
  my $session = shift;

  my $this = bless({
    session => $session,
    debug => $Foswiki::cfg{Plugins}{CaptchaPlugin}{Debug},
    saveForAll => $Foswiki::cfg{Plugins}{CaptchaPlugin}{SaveForAll} || 0,
    @_
  }, $class);

  return $this;
}

=begin TML

---++ ObjectMethod finish()

=cut

sub finish {
  my $this = shift;

  undef $this->{json};
  undef $this->{store};
}

=begin TML

---++ ObjectMethod getStore() -> $store

creates a store delegate

=cut

sub getStore {
  my $this = shift;

  unless ($this->{store}) {
    require Foswiki::Plugins::CaptchaPlugin::Store;
    $this->{store} = Foswiki::Plugins::CaptchaPlugin::Store->new();
  };

  return $this->{store};
}

=begin TML

---++ ObjectMethod json() -> $json

creat3es a JSON delegate

=cut

sub json {
  my $this = shift;

  unless (defined $this->{json}) {
    $this->{json} = JSON->new; 
  }

  return $this->{json};
}


=begin TML

---++ ObjectMethod CAPTCHACHECK($params, $topic, $web) -> $string

implements the %CAPTCHACHECK macro

=cut

sub CAPTCHACHECK {
  my ($this, $params, $topic, $web) = @_;

  my $theError = $params->{error};
  $theError = 'error' unless defined $theError;

  my $theSuccess = $params->{success};
  $theSuccess = 'success' unless defined $theSuccess;

  my $theChallenge = $params->{challenge};
  my $theResponse = $params->{response};

  return '' unless $theChallenge && $theResponse;

  my $format = $this->isValidCaptcha($theChallenge, $theResponse, 1)?$theSuccess:$theError;

  return Foswiki::Func::decodeFormatTokens($format);
}

=begin TML

---++ ObjectMethod jsonRpcCreate($requesst)

JSON-RPC backend for the create method

=cut

sub jsonRpcCreate {
  my ($this, $request) = @_;

  require Foswiki::Plugins::CaptchaPlugin::Captcha;
  return Foswiki::Plugins::CaptchaPlugin::Captcha->new(
    $this->getStore,
    params => $request->params,
  )->toHash();
}

=begin TML

---++ ObjectMethod CAPTCHAFORM($params, $topic, $web) -> $string

implements the %CAPTCHAFORM macro

=cut

sub CAPTCHAFORM {
  my ($this, $params, $topic, $web) = @_;

  Foswiki::Func::readTemplate("captcha");

  my $data = Foswiki::Func::expandTemplate("captcha");
  my $validateOnSubmit = Foswiki::Func::isTrue($params->{validateonsubmit}, 1)?"true":"false";
  my $disableOnSuccess = Foswiki::Func::isTrue($params->{disableonsuccess}, 0)?"true":"false";

  $data =~ s/%validateOnSubmit%/$validateOnSubmit/g;
  $data =~ s/%disableOnSuccess%/$disableOnSuccess/g;

  return $data;
}

=begin TML

---++ ObjectMethod CAPTCHA($params, $topic, $web) -> $string

implements the %CAPTCHA macro

=cut

sub CAPTCHA {
  my ($this, $params, $topic, $web) = @_;

  Foswiki::Plugins::JQueryPlugin::createPlugin("captcha");
  return "<span class='jqCaptcha' ".$this->toHtml5Data($params)."'><a href='#' class='jqTooltip jqCaptchaReload jqCaptchaContainer' title='%MAKETEXT{\"click to reload\"}%'></a></span>";
}
=begin TML

---++ ObjectMethod toHtml5Data($data) -> $string

converts the $data hash into a HTML5 data representation

=cut

sub toHtml5Data {
  my ($this, $params) = @_;

  my @data = ();
  foreach my $key (keys %$params) {
    next if $key =~ /^_/;
    my $val = $params->{$key};
    if (ref($val)) {
      $val = $this->json->encode($val);
    } else {
      $val = Foswiki::entityEncode($val);
    }
    push @data, "data-$key='$val'";
  }

  return join(" ", @data);
}

=begin TML

---++ ObjectMethod isValidCaptcha($challenge, $responce, $forceDelete) -> $boolean

returns true if the given challenge matches the captcha as stored

=cut

sub isValidCaptcha {
  my ($this, $challenge, $response, $forceDelete) = @_;

  my $captcha = $this->getStore()->readCaptcha($challenge);
  unless ($captcha) {
    my $remoteAddress = Foswiki::Func::getRequestObject()->remoteAddress();
    $challenge ||= '???';
    my $msg = "Warning: Requesting check on unknown captcha $challenge from $remoteAddress";
    Foswiki::Func::writeWarning($msg);
    print STDERR $msg."\n";
    return 0;
  }

  return $captcha->isValid($response, $forceDelete);
}

=begin TML

---++ ObjectMethod validateRegistration($data)

throws a captcha exception if the captcha is invalid

=cut

sub validateRegistration {
  my ($this, $data) = @_;

  # not using $data as it requires special names on form fields

  my $query = Foswiki::Func::getRequestObject();
  my $challenge = $query->param('captcha_challenge');
  my $response = $query->param('captcha_response');

  if(!defined($challenge) || !defined($response) || !$this->isValidCaptcha($challenge, $response, 1)) {
    throw Foswiki::OopsException(
      'captcha',
      web    => $data->{webName},
      topic  => $this->{session}->{topicName},
      def => 'captcha::invalid_response',
    );
  }
}

1;
