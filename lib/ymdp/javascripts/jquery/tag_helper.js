/* TAG HELPERS */


  // DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  // The way they are cached makes it not safe to do so.

var Tags;

function tagHelper(tag_name, text, options) {
  var m, opts;
  
  m = "";
  opts = "";
  
  Object.keys(options).each(function(key) {
    opts = opts + " " + key + "='" + options[key] + "'";
  });
  
  m = m + "<" + tag_name + " " + opts + ">";
  m = m + text;
  m = m + "<\/" + tag_name + ">";
  return m;
}

function optionTag(text, options) {
  return tagHelper("option", text, options);
}

function selectTag(text, options) {
  return tagHelper("select", text, options);
}

function spanTag(text, options) {
  return tagHelper("span", text, options);
}

function liTag(text, options) {
	return tagHelper("li", text, options);
}

function divTag(text, options) {
  return tagHelper("div", text, options);
}

function tdTag(text, options) {
  return tagHelper("td", text, options);
}

function inputTag(value, options) {
  options['value'] = value;
  return tagHelper("input", "", options);
}

function textField(value, options) {
  return inputTag(value, options);
}

function submitTag(value, options) {
  options['type'] = 'submit';
  return inputTag(value, options);
}

function optionsForSelect(options, selected) {
  var m;
  m = "";
  options.each(function(option) {
    var key, value, opts;
    
    if (Object.isArray(option)) {
      key = option[0];
      value = option[1];
    } else {
      key = option;
      value = option;
    }
    
    opts = {
      value: value
    };
    
    if (key === selected) {
      opts.selected = 'selected';
    }
    
    m = m + optionTag(key, opts);
  });
  return m;
}

Tags = {
	create: function(tag_name, text, options) {
		options = options || {};
		var m, opts;
		
		m = "";
	  opts = "";
  
		Object.keys(options).each(function(key) {
			if (options[key]) {
		    opts = opts + " " + key + "='" + options[key] + "'";
			}
	  });
  
	  m = m + "<" + tag_name + " " + opts + ">";
	  m = m + text;
	  m = m + "<\/" + tag_name + ">";
	  return m;
	},
	
	input: function(value, options) {
		options = options || {};
		options["value"] = value;
		options["name"] = options["name"] || "";
		options["id"] = options["id"] || options["name"];
				
		return Tags.create("input", "", options);
	},
	
	hiddenInput: function(value, options) {
		options = options || {};
		options["type"] = "hidden";
		return Tags.input(value, options);
	},
	
	checkBox: function(name, options) {
		options = options || {};
		var check_box, hidden_options, hidden_check_box;
		
		options["type"] = "checkbox";
		options["name"] = name;
		
		if (options["checked"]) {
			options["checked"] = "checked";
		} else {
			options["checked"] = undefined;
		}
		
		check_box = Tags.input("1", options);
		
		hidden_options = {
			"name": name
		};
		hidden_check_box = Tags.hiddenInput("0", hidden_options);
		
		return check_box + " " + hidden_check_box;
	},
	
	submit: function(value, options) {
	  options = options || {};
	  options["value"] = value;
	  options["id"] = options["id"] || options["name"];
	  options["type"] = "submit";
	  return Tags.input(value, options);
	},
	
	linkToFunction: function(value, onclick, options) {
	  options = options || {};
	  var jv;
	  
	  jv = "#";
    options["href"] = options["href"] || jv;
	  options["onclick"] = onclick;
	  return Tags.a(value, options);
	},
	
	div: function(text, options) {
	  return new Element('div', options).update(text);
	},
	
	init: function() {
		for (tag_name in ["li", "ol", "ul", "span", "div", "p", "a", "option", "select", "strong", "table", "th", "tr", "td"]) {
			Tags[tag_name] = function(text, options) {
				options = options || {};
				return Tags.create(tag_name, text, options);
			};
		};
	}
};

/* END TAG HELPERS */
