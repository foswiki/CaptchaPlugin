# ---+ Extensions

# ---++ JQueryPlugin
# ---+++ Extra plugins

# **STRING**
$Foswiki::cfg{JQueryPlugin}{Plugins}{Captcha}{Module} = 'Foswiki::Plugins::CaptchaPlugin::JQueryPlugin';

# **BOOLEAN**
$Foswiki::cfg{JQueryPlugin}{Plugins}{Captcha}{Enabled} = 1;

# ---++ CaptchaPlugin

# **NUMBER CHECK='nullok'**
# Time in seconds after which a captcha will expire and be removed
$Foswiki::cfg{Plugins}{CaptchaPlugin}{Expiry} = 600;

# **NUMBER CHECK='nullok'**
# Default width of a captcha 
$Foswiki::cfg{Plugins}{CaptchaPlugin}{ImageWidth} = 170;

# **NUMBER CHECK='nullok'**
# Default height of a captcha 
$Foswiki::cfg{Plugins}{CaptchaPlugin}{ImageHeight} = 65;

# **STRING CHECK='nullok'**
# List of installed fonts. These are located in <code>{pubDir}/System/CaptchaPlugin/fonts/</code>.
# See http://www.allfreefonts.com/ for more custom fonts to be installed there.
$Foswiki::cfg{Plugins}{CaptchaPlugin}{KnownFonts} = 'AbscissaBold, AcklinRegular, Activa, BleedingCowboys, FreeMonoBoldOblique, MacType, ManaMana, StayPuft, Vera';

# **STRING CHECK='nullok'** 
# Default font of the characters in the captcha. This must be one of the fonts listed in <code>{KnownFonts}</code> or "random".
$Foswiki::cfg{Plugins}{CaptchaPlugin}{Font} = 'random';

# **NUMBER CHECK='nullok'**
# Default font size of the characters displayed in the captcha 
$Foswiki::cfg{Plugins}{CaptchaPlugin}{FontSize} = 20;

# **STRING CHECK='nullok'**
# Default particle settings. This setting controls the kind of noise added to the image by specifying two integers 
# for <code>density</code> and <code>maxdots</code>. Setting it to <code>on</code> will produce a dotted noise layer;
# Setting it to <code>off</code> disables the feature.
$Foswiki::cfg{Plugins}{CaptchaPlugin}{Particles} = "100 100";

# **NUMBER CHECK='nullok'**
# Default number of horizontal lines added to the captcha image. This setting has no effect when the <code>style</code> is set to <code>blank</code>.
$Foswiki::cfg{Plugins}{CaptchaPlugin}{NumberOfLines} = 6;

# **STRING CHECK='nullok'**
# Default background color of the captcha
$Foswiki::cfg{Plugins}{CaptchaPlugin}{BackgroundColor} = 'transparent';  

# **STRING CHECK='nullok'**
# Default text color of the captcha
$Foswiki::cfg{Plugins}{CaptchaPlugin}{TextColor} = '#000000';  

# **STRING CHECK='nullok'**
# Default color of the lines added to the captcha
$Foswiki::cfg{Plugins}{CaptchaPlugin}{LineColor} = 'random';  

# **STRING CHECK='nullok'**
# List of captcha styles known by the captcha backend.
$Foswiki::cfg{Plugins}{CaptchaPlugin}{KnownStyles} = 'default, blank, rect, box, circle, ellipse, ec';

# **STRING CHECK='nullok'** 
# Default style of the captcha. This must be one of the <code>{KnownStyles}</code> or <code>random</code>.
$Foswiki::cfg{Plugins}{CaptchaPlugin}{Style} = 'blank';  

# **BOOLEAN CHECK='nullok'**
# Default scrambling setting.
$Foswiki::cfg{Plugins}{CaptchaPlugin}{Scramble} = 1;

# **BOOLEAN CHECK='nullok'**
# Default frame setting.
$Foswiki::cfg{Plugins}{CaptchaPlugin}{Frame} = 0;

# **STRING CHECK='nullok'**
# Number of characters on a captcha. 
$Foswiki::cfg{Plugins}{CaptchaPlugin}{NumberOfCharacters} = 6;  

# **STRING CHECK='nullok'**
# Set of characters to be used
$Foswiki::cfg{Plugins}{CaptchaPlugin}{Characters} = 'abcdefghijklmnopqrstuvwxyz';  

# **BOOLEAN CHECK='nullok'**
# Enable captcha for topic save. By default ony WikiGuests need to provide a valid captcha.
# Enable {SaveForAll} to require even normal users to validate their input.
$Foswiki::cfg{Plugins}{CaptchaPlugin}{EnableSave} = 0;

# **BOOLEAN CHECK='nullok'**
# Enable captcha for all users, not just WikiGuest
$Foswiki::cfg{Plugins}{CaptchaPlugin}{SaveForAll} = 0;  

# **BOOLEAN CHECK='nullok'**
# Enable debug mode
$Foswiki::cfg{Plugins}{CaptchaPlugin}{Debug} = 0;

1;
