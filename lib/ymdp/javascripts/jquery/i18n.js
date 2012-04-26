// DO NOT USE the @view instance variable in any files in /app/javascripts/base.
// The way they are cached makes it not safe to do so.

/*
	  I18N
  
	  global to every view.  
	
	  Methods and constants dealing with internationalization.
*/

var I18n;

/* set asset version */

I18n = {
  "keys": {}
};

I18n.init = function() {
  Debug.log("about to call I18n.init");

  I18n.assets_path = "<%= @assets_path %>/yrb";

  I18n.availableLanguages = <%= supported_languages.to_json %>;

  I18n.currentLanguage = OpenMailIntl.findBestLanguage(I18n.availableLanguages);
  
  I18n.setResources();

  Debug.log("finished calling I18n.init");
};

I18n.setResources = function() {
  var asset_path;
  
  Debug.log("begin I18n.setResources for language " + I18n.currentLanguage);
  asset_path = "<%= @assets_directory %>/yrb/";
	I18n.keys = OpenMailIntl.getResources(asset_path, "keys", I18n.currentLanguage) || {};
  if (I18n.currentLanguage !== "en-US") {
		I18n.default_keys = OpenMailIntl.getResources(asset_path, "keys", "en-US") || {};
	} else {
	  I18n.default_keys = I18n.keys;
	}
};

I18n.english = function() {
  return I18n.currentLanguage.match(/^en/);
};

I18n.translate_element = function(element) {
  element = $(element);
  
  var e;
  // 
  //   e = element.inspect();
  //   if (e.match(/<input/)) {
  //     I18n.v(element.attr("id"));
  //   } else {
  //     if (e.match(/<img/)) {
  //       I18n.src(element.attr("id"));
  //     } else {
  //    I18n.u(element.attr("id");
  //  }
  // }
  I18n.u(element.attr("id"));
};

// I18n.translate(key, [args])
// I18n.t(key, [args])
//
// Using .translate with a single key argument will return the simple translated string for that key
//
// Using a key argument with values after it will insert the values into the placeholders in
// the returned translated string
//
I18n.translate = function(key, args) {
	key = key.toUpperCase();
	key = key.replace(" ", "_");
	if (args) {
		var m;
		m = I18n.translate_sentence(key, args);
	} else
	{
		m = I18n.translate_phrase(key);
		if (!m) {
			m = I18n.default_keys[key];
		}
	}
	return m;
};
I18n.t = I18n.translate;

I18n.translate_phrase = function(key) {
	return I18n["keys"][key];
};

I18n.translate_sentence = function(key, args) {
  return OpenMailIntl.formatMessage(I18n.t(key), args, I18n.currentLanguage);
};

// I18n.update(id, scope, key, args)
//
// updates an element with the given _id_ with the
// translation from scope, key and optional args
//
// only updates the element if the translation is not blank
//
I18n.update = function(id, key, args) {
  if (typeof(id) === "string") {
    I18n.updateById(id, key, args);
  } else {
    I18n.updateByElement(id, key, args);
  }
};

I18n.updateById = function(id, key, args) {
  var message;
  
  message = I18n.t(key, args);
  $("#" + id).html(message);
};

I18n.updateByElement = function(id, key, args) {
  var message;

  message = I18n.t(key, args);
  if (message) {
    $(id).html(message);
  }
}

// I18n.u(id, args)
//
// updates an element with a local YRB key of the same name
//
// given an id of "messages" it will look for a YRB key named "MESSAGES"
// within the local scope of the current view, and update the element with
// that translation
//
I18n.u = function(id, args) {
  if ($.isArray(id)) {
    $(id).each(function(i, element) {
      I18n.u(element);
    });
  } else {
    var key;
    key = id.toUpperCase();
    I18n.update(id, key, args);
  }
};

		
// I18n.updateValue(id, key, args)
//
// updates an element with the given _id_ with the
// translation from scope, key and optional args
//
// only updates the element if the translation is not blank
//
I18n.updateValue = function(id, key, args) {
  var message;
  message = I18n.t(key, args);
  if (message) {
    $("#" + id).val(message);
  }
};		

		
// I18n.v(id, args)
//
// updates the value of an element with a local YRB key of the same name
//
// given an id of "messages" it will look for a YRB key named "MESSAGES"
// within the local scope of the current view, and update the element's value with
// that translation
//
I18n.v = function(elements, args) {
  $(elements).each(function(i, element) {
    var key;
    
    element = $(element);
    key = element.val();
    element.val(I18n.t(key));
  });
};

// Specific to Organizer
I18n.translateSidebar = function() {
	I18n.u('faq_q1');
	var link;
	link = Tags.a(I18n.t('faq_link1'), {"href": 'http://go.otherinbox.com/q-custom-sender', "target": "_blank"});
	I18n.u('faq_a1', [link]);
	
	I18n.u('faq_q2');
	link = Tags.a(I18n.t('faq_link2'), {"href": 'http://go.otherinbox.com/q-stop-sender', "target": "_blank"});
	I18n.u('faq_a2', [link]);
};

// Specific to Organizer
I18n.translateError = function() {
  I18n.update('error_1', 'ERROR_1');
  I18n.update('error_2', 'ERROR_2');
  I18n.update('retry', 'RETRY');
};

// Specific to Organizer
I18n.translateLoading = function() {
  I18n.update('loading_subhead', 'LOADING_SUBHEAD');
  I18n.update('loading_paragraph_1', 'LOADING_PARAGRAPH_1');
};

I18n.addLanguageToBody = function() {
  $('body').addClass(I18n.currentLanguage);
};

I18n.p = function(element) {
  element = $(element);
  var key;
  
  key = element.html();
  
  I18n.update(element, key);
};

I18n.findAndTranslateAll = function() {
  Debug.log("I18n.findAndTranslateAll");
  
  $('.p').each(function(i) {
    var element = $(this);
    I18n.p(element);
  });
	
	$('.t').each(function(i) {
	  var element = $(this);
    I18n.translate_element(element);
  });
  
  $('.v').each(function(i) {
    var element = $(this);
    I18n.v(element);
  });
	
	Debug.log("End I18n.findAndTranslateAll");
};

I18n.localTranslations = function() {};
