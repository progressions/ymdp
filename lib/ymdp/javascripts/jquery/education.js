var Education;

Education = {
  init: function(name) {
    try {
      Debug.log("Education.init", name);
      var m;
    
      Education.name = name;
      
      m = "";
      m = m + Tags.linkToFunction("Close", "Education.educate(); return false;", {"class": "close"});
      m = m + Education.educationModule();
      
      Education.container().insert(m);
      Education.container().insert({"after": Education.forcedEducation()});
      
      Education.load();
    } catch(omg) {
      Debug.error(omg);
    }
  },
  
  educationModule: function() {
    var m;
    
    m = Tags.div(Education.ol(), {"id": Education.name, "class": "education_module"});
    
    return m;
  },
  
  forcedEducation: function() {
    var m;
    
    m = Tags.div(Education.minForcedEducation(), {"id": "forced_education", "style": "display: none;"});
    
    return m;
  },
  
  minForcedEducation: function() {
    var m, id;
    
    id = "min_" + Education.name + "_education";
    Debug.log("getting min forced education key", id);
    m = Tags.div(I18n.t(id), {"id": id});
    
    Debug.log("got key", m);
    
    return m;
  },
  
  ol: function() {
    var m, entries;
    
    entries = Education.entries();
    
    entries = entries.join("");
    m = Tags.ol(entries);
    
    return m;
  },
  
  entries: function() {
    var m, entries, entry, i;
    entries = [];
    
    i = 0;
    
    do {
      i = i + 1;
      entry = Education.entry(i);
      entries.push(entry);
    } while(entry);
    
    return entries;
  },
  
  entry: function(index) {
    var m, text, id;
    
    id = Education.name + "_" + String(index);
    text = I18n.t(id);
    
    if (text) {
      m = Tags.li(text, {"id": id});
    }
    return m;
  },
  
  show: function(educations) {
    Debug.log('Education.init');
    Education.educations = educations;
    Debug.log("Educations.educations: ", educations);
    if (Education.container() !== null) {
      Education.getModules();
    }
  },
  
  get: function(params, success_function, error_function) {
    Debug.log('Education.get. About to call OIB.get');
    OIB.get("educations/", params, success_function, error_function);
  },
  
  post: function(params, success_function, error_function) {
    Debug.log('Education.post');
    OIB.post("educations/create", params, success_function, error_function);
  },
  
  educate: function() {
    // Grab the children divs of $('education') with the class education_module that are NOT HIDDEN
    // For each education module returned, post the id and view as params[:title] and params[:page_name]
    
    $('.education_module').each(function(index, element) {
      element = $(element);
      if (!element.hasClass('educated')) {
        Education.post({"page_name": View.name, "title": element.attr("id")}, function(response) {
          Debug.log("Response: " + response);
        });
      }
    });
    Education.container().hide();
    $('#forced_education').show();
  },
  
  getModules: function() {
    var showContainer = false;
    $('.education_module').each(function(index, element) {
      Education.educations.each(function(education) {
        if (element.attr("id") === education.title && View.name.toLowerCase() === education.page_name.toLowerCase()) {
          element.addClass('educated');
        }
      });
    });
    
    $('.education_module').each(function(i) {
      var element = $(this);
      if(!element.hasClass('educated')) {
        showContainer = true;
      }
    });
    
    if (showContainer) {
      Education.container().show();
    } else {
      $('forced_education').show();
    }
  },
  
  container: function() {
    return $('#education');
  },
  
  load: function() {
    try {
      Debug.log('Education.load');
      Education.get({}, function(response) {
        Education.show(response);
      });
    } catch(err) {
      YMDP.showError({
        "method": "Education.load",
        "type": "exception caught",
        "error": err
      });
      Debug.error(err);
    }
  }
};