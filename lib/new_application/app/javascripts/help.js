// popup help text
//
var Help = function(content) {
  try {
    this.content = content;
  
    // instance method
    this.show = function(event) {
      var x = event.clientX + 20;
      var y = event.clientY - 10;
      this.create(x,y);
    };
    
    this.create = function(x, y) {
      try {
        if (!$(this.css_id)) {
          var popup = new Element('div', {
            "id": this.css_id, 
            "class": "popup"
          });
          popup.update(this.content);
          popup.setStyle({
            "display": "none",
            "left": x + "px",
            "top": y + "px"
          });
          $$('body').first().insert(popup);
          setTimeout("$(\"" + this.css_id + "\").show();", 500);
        }
      } catch(e) {
        // alert(e);
      }
    };
  
    this.destroy = function() {
      setTimeout("$('" + this.css_id + "').remove();", 4000);
    };
  
    this.link = function(text) {
      text = text || "?";
      return Tags.linkToFunction(text, "", {
        "onmouseover": "Help.show(event, " + this.id + ");",
        "onmouseout": "Help.destroy(" + this.id + ")"
  	  });
    };
  
    Help.popups = Help.popups || [];
    Help.popups.push(this);
  
    this.id = Help.popups.size() - 1;
    this.css_id = "popup_" + this.id;
  } catch(e) {
    // alert(e);
  }
};

Help.show = function(event, id) {
  var help = Help.popups[id];
  help.show(event);
};

Help.destroy = function(id) {
  var help = Help.popups[id];
  help.destroy();
};

Help.closeAll = function() {
  $$('.popup').each(function(p) {
    p.remove();
  });
};

Help.init = function() {
  // initialize any help popups. Overwrite this locally.
};

