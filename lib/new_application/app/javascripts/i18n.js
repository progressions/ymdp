/*
	  I18N
  
	  global to every view.  
	
	  Methods and constants dealing with internationalization.
*/

var I18N, I18n;

/* set asset version */

I18N = {
  VERSION: "<%= @hash %>",
  MESSAGE: "<%= @message %>",
  DEPLOYED: <%= Time.now.to_i %>,
  DEPLOYED_STRING: "<%= Time.now.to_s %>"
};


I18n = {};

I18n.setResources = function() {
  var scope, asset_path;
  
  scope = "keys";
  
  Debug.log("begin I18n.setResources for language " + I18n.currentLanguage);
  try {
	  asset_path = "<%= @assets_directory %>/yrb/";
		I18n[scope] = I18n[scope] || OpenMailIntl.getResources(asset_path, scope, I18n.currentLanguage);
	  if (I18n.currentLanguage !== "en-US") {
  		I18n.default_keys = OpenMailIntl.getResources(asset_path, scope, "en-US");
		} else {
		  I18n.default_keys = I18n[scope];
		}
	} catch(err) {
	  Debug.error("error in I18n.setResources: " + err);
	}
	I18n.scope = scope;
  Debug.log("end I18n.setResources");
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
  return OpenMailIntl.formatMessage(I18n["keys"][key], args, I18n.currentLanguage);
};

// I18n.update(id, scope, key, args)
//
// updates an element with the given _id_ with the
// translation from scope, key and optional args
//
// only updates the element if the translation is not blank
//
I18n.update = function(id, key, args) {
  Try.these(function() {
    var message;
    message = I18n.t(key, args);
    if (message) {
      $(id).update(message);
    }
  }, function() {
    Debug.error("Error in i18n.update: " + Object.toJSON({
      id: id,
      key: key,
      args: args
    }));
  });
};		

// I18n.u(id, args)
//
// updates an element with a local YRB key of the same name
//
// given an id of "messages" it will look for a YRB key named "MESSAGES"
// within the local scope of the current view, and update the element with
// that translation
//
I18n.u = function(id, args) {
  Try.these(
	function() {
	  id.each(I18n.u);
	},
	function() {
    var key;
    key = id.toUpperCase();
    I18n.update(id, key, args);
  },
  function() {
    Debug.error("Error in i18n.u: " + Object.toJSON({
      id: id,
      args: args
    }));
  });
};

		
// I18n.updateValue(id, key, args)
//
// updates an element with the given _id_ with the
// translation from scope, key and optional args
//
// only updates the element if the translation is not blank
//
I18n.updateValue = function(id, key, args) {
  Try.these(function() {
    var message;
    message = I18n.t(key, args);
    if (message) {
      $(id).value = message;
    }
  }, function() {
    Debug.error("Error in i18n.updateValue: " + Object.toJSON({
      id: id,
      key: key,
      args: args
    }));
  });
};		

		
// I18n.v(id, args)
//
// updates the value of an element with a local YRB key of the same name
//
// given an id of "messages" it will look for a YRB key named "MESSAGES"
// within the local scope of the current view, and update the element's value with
// that translation
//
I18n.v = function(id, args) {
  Try.these(
	function() {
		id.each(I18n.v);
	},
	function() {
    var key;
    key = id.toUpperCase();
    I18n.updateValue(id, key, args);
  },
  function() {
    Debug.error("Error in i18n.v: " + Object.toJSON({
      id: id,
      args: args
    }));
  });
};

I18n.translateError = function() {
  I18n.update('error_1', 'ERROR_1');
  I18n.update('error_2', 'ERROR_2');
  I18n.update('retry', 'RETRY');
};

I18n.translateLoading = function() {
  I18n.update('loading_heading', 'LOADING_HEADING');
  I18n.update('loading_subhead', 'LOADING_SUBHEAD');
  I18n.update('loading_paragraph_1', 'LOADING_PARAGRAPH_1');
};

I18n.addLanguageToBody = function() {
  Try.these(function() {
    $$('body').first().addClassName(I18n.currentLanguage);
  });
};

I18n.findAndTranslateAll = function() {
  Element.addMethods({
    translate: function(element) {
      element = $(element);
      
      var e;
      e = element.inspect();
      if (e.match(/<input/)) {
        I18n.v(element.identify());
      } else {
        if (e.match(/<img/)) {
          I18n.src(element.identify());
        } else {
    			I18n.u(element.identify());
  			}
			}
    }
  });
  
	$$('.t').each(function(element) {
	  try {
     element.translate();
    } catch(e) {
      Debug.error("Translation error for element: " + e);
    }
	});
};

I18n.translateSidebar = function() {
	I18n.u('faq_q1');
	var link;
	link = Tags.a(I18n.t('faq_link1'), {"href": 'http://go.otherinbox.com/q-stop-sender', "target": "_blank"});
	I18n.u('faq_a1', [link]);
	
	I18n.u('faq_q2');
	link = Tags.a(I18n.t('faq_link2'), {"href": 'http://go.otherinbox.com/q-custom-sender', "target": "_blank"});
	I18n.u('faq_a2', [link]);
};


