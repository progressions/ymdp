
  // DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  // The way they are cached makes it not safe to do so.

var ABTesting;

ABTesting = {
  on: true,
  languages: <%= english_languages.to_json %>,
  
  enable: function() {
    ABTesting.on = true;
  },
  
  disable: function() {
    ABTesting.on = false;
  },
  
  randomAB: function() {
    return Math.floor(Math.random()*2) ? "a" : "b";
  },
  
  get: function(content_id) {
    var url, host;
    
    url = "ymdp/experiment";
    
    OIB.get(url, {
      "domain": View.domain
    }, function(response) {
      ABTesting.success(content_id, response);
    }, function(response) {
      ABTesting.error(response);
    });
  },
  
  post: function(params) {
    params = params || {};
    OIB.post("ymdp/view", params, function(response) {
      Debug.log("ABTesting.post success", response);
    }, function(response) {
      Debug.error("ABTesting.post error", response);
    });
  },
  
  postView: function(experimentId) {
    var params;
    
    params = {
      "var": ABTesting.variable
    };
    if (experimentId) {
      params["experiment_id"] = experimentId;
    }
    Debug.log("ABTesting.postView: ", params);
    ABTesting.post(params);
  },
  
  setVariable: function(value) {
    ABTesting.variable = value;
  },
 
  apply: function(content_id, language) {
    try {
      if (ABTesting.on && $.inArray(language, ABTesting.languages) >= 0) {
        var index;
      
        index = ABTesting.randomAB();
        ABTesting.setVariable(index);
      
        ABTesting.get(content_id);
      } else {
        YMDP.Init.showAndFinish();
      }
    }
    catch(e) {
      Debug.log(e);
      YMDP.Init.showAndFinish();
    }
  },
 
  error: function(data) {
    Debug.log("applyError", data);
    if (data.error !== 3002) {
      Debug.error("Received body contents fetch error on page " + View.name + ": " + data.error + ' - ' + data.errorMsg);
    }
    YMDP.Init.showAndFinish();
  },
 
  success: function(content_id, response) {
    try {
      var content, experiment, experimentId;
      Debug.log("ABTesting.success", response);
      
      experiment = response.experiment;
      
      if (experiment) {
        content = ABTesting.content(experiment);
        experimentId = response.experiment.id;

        ABTesting.postView(experimentId);
        ABTesting.replaceContents(content_id, content);        
      } else {
        Debug.log("No experiment running");
      }
      
      YMDP.Init.showAndFinish();
    } catch(e) {
      Debug.log("ABTesting.success error" + e);
    }
  },
  
  replaceContents: function(content_id, content) {
    openmail.Application.filterHTML({html: content}, function(response) {
      if (response.html && response.html !== '') {
        try {
          $("#" + content_id).html(response.html);
        } catch(omg) {
          Debug.error(omg);
        }
      }
      YMDP.Init.showAndFinish();
    });
  },
  
  content: function(experiment) {
    return experiment["content_" + ABTesting.variable];
  }
};

