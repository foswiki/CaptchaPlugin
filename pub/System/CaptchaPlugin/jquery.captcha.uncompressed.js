/*
 * Captcha Plugin 2.20
 *
 * Copyright (c) 2011-2024 Michael Daum http://michaeldaumconsulting.com
 *
 * Licensed under the GPL licenses http://www.gnu.org/licenses/gpl.html
 *
 *
 */
"use strict";
(function($) {

  var defaults = {
    endpoint: null,
    template: "<img src='{{:url}}' height='{{:height}}' width='{{:width}}' /><input type='hidden' name='captcha_challenge' value='{{:challenge}}' />",
    captchaContainer: '.jqCaptchaContainer',
    reloadButton: '.jqCaptchaReload',
    challengeName: 'captcha_challenge',
    responseName: 'captcha_response',
    createParams: {
      width:170,
      height:65
    },
    validateOnSubmit: true,
    disableOnSuccess: false
  };

  // Captcha object
  function Captcha(element, options) {
    var captcha = this;

    captcha.element = element;
    captcha.options = $.extend( {}, defaults, options) ;

    captcha.init();
  }

  Captcha.prototype.load = function(async) {
    var captcha = this,
        $container = $(captcha.element).find(captcha.options.captchaContainer);

    //console.log("load container=",$container);
    if (typeof(async) === 'undefined') {
      async = true;
    }

    $.jsonRpc(
      captcha.options.endpoint, {
        async: async,
        method:"create",
        params: captcha.options.createParams,
        success: function(json) {
          //console.log(json.result);
          $container.html(captcha.template.render(json.result));
        },
        error: function(json) {
          // TODO
          alert("Error: "+json.error.message);
        }
      }
    );
  };

  Captcha.prototype.init = function() {
    var captcha = this,
        $captcha = $(captcha.element);

    //console.log("init");

    // compile template
    captcha.template = $.templates(captcha.options.template);
    
    // loading img
    captcha.load(false);

    // reload behavior
    $captcha.find(captcha.options.reloadButton).each(function() {
      var $btn = $(this);

      $btn.click(function() {
        captcha.unflagError();
        captcha.unflagSuccess();
        captcha.load(false);
        $captcha.find("input[name='"+captcha.options.challengeName+"']").val("").focus();
        return false;
      });
    });

    // event handler
    $captcha.bind("reload.captcha", function() {
      var captcha = $captcha.data("captcha");
      captcha.unflagError();
      captcha.unflagSuccess();
      captcha.load();      
    });

    // add to submit event
    if (this.options.validateOnSubmit) {
      $captcha.parents("form:first").on("submit", function() {
        //console.log("captcha got a submit event");
        return captcha.validate();
      });
    }

    // setting captcha height and width to prevent flickering
    $captcha.find(captcha.options.captchaContainer).css({
      width:captcha.options.createParams.width,
      height:captcha.options.createParams.height
    });

  };

  Captcha.prototype.params = function(options) {
    if (typeof(options) === 'undefined') {
      return this.options.createParams;
    } else {
      return $.extend(this.options.createParams, options);
    }
  };

  Captcha.prototype.validate = function() {
    var captcha = this,
        $captcha = $(captcha.element),
        $challenge = $captcha.find("input[name='"+captcha.options.challengeName+"']"),
        challenge = $challenge.val(),
        $response = $captcha.find("input[name='"+captcha.options.responseName+"']"),
        response = $response.val(),
        isValid = false;

    //console.log("challenge="+challenge+" response="+response);

    if (challenge && response) {
      $.ajax({
        url: foswiki.getScriptUrl("rest", "CaptchaPlugin", "validate"),
        async: false,
        data: {
          t: (new Date()).getTime(),
          challenge: challenge,
          response: response
        },
        success: function(data) {
          isValid = (data === 'true');
        }
      });
    }

    //console.log("isValid=",isValid);
    if (isValid) {
      captcha.flagSuccess();
      if (captcha.options.disableOnSuccess) {
        $response.attr("disabled", "disabled");
        $challenge.attr("disabled", "disabled");
      }
    } else {
      captcha.load(false);
      captcha.flagError();
      $response.val("").focus();
    }

    return isValid;
  };

  Captcha.prototype.flagError = function() {
    var captcha = this, $captcha = $(captcha.element);

    //console.log("flagError for ",$captcha);
    captcha.unflagSuccess();
    $captcha.find("input[name='"+captcha.options.responseName+"']").addClass("error");
    $captcha.find("label.error").show();
  };

  Captcha.prototype.unflagError = function() {
    var captcha = this, $captcha = $(captcha.element);

    $captcha.find("input[name='"+captcha.options.responseName+"']").removeClass("error");
    $captcha.find("label.error").hide();
  };

  Captcha.prototype.flagSuccess = function() {
    var captcha = this, $captcha = $(captcha.element);

    captcha.unflagError();
    $captcha.find("label.success").show();
  };

  Captcha.prototype.unflagSuccess = function() {
    var captcha = this, $captcha = $(captcha.element);

    $captcha.find("label.success").hide();
  };

  // extend jQuery
  $.fn.captcha = function(options) {
    //console.log("plugin called");
    return this.each(function() {
      if(!$.data(this, 'captcha')) {
        $.data(this, 'captcha', new Captcha(this, options));
      }
    });
  };
   
  // integrate into page
  $(function() {
    defaults.endpoint = foswiki.getScriptUrl("jsonrpc", "CaptchaPlugin");

    $(".jqCaptcha").livequery(function() {
      var $this = $(this),
          options = $.extend({}, $this.data());

      $this.captcha(options);
    });
  });

})(jQuery);
