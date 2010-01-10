/**
 * The OpenMailIntl class provides minimal internationalization
 * support for OpenMail.
 * @module openmailintl
 */

 /**
 * The OpenMailIntl class provides minimal internationalization
 * support for OpenMail.
 * @class OpenMailIntl
 */
 
/*global window, YAHOO, ActiveXObject, XMLHttpRequest */

var OpenMailIntl = function () {
    
    var openmailintl = {};
    
    /**
     * Returns the user's preferred languages as a list of
     * RFC 4646 language tags in decreasing priority order.
     * @method getPreferredLanguages
     * @private
     * @return {String[]} A list of RFC 4646 language tags.
     */
    var getPreferredLanguages = function () {
        // this is a stub until OpenMail can synchronously provide
        // a complete and accurate language list
        var intl, match;
        intl = "us";
        match = window.location.href.match(/[\?&]\.intl=([a-z0-9]{2})/);
        if (match) {
            intl = match[1];
        }
        switch (intl) {
            // only support Mail INTLs
            case "aa": return ["en-AA"];
            case "ar": return ["es-AR"];
            case "au": return ["en-AU"];
            case "br": return ["pt-BR"];
            case "ca": return ["en-CA"];
            case "cf": return ["fr-CA"];
            case "cl": return ["es-CL"];
            case "cn": return ["zh-Hans-CN"];
            case "co": return ["es-CO"];
            case "de": return ["de-DE"];
            case "dk": return ["da-DK"];
            case "e1": return ["es-US"];
            case "es": return ["es-ES"];
            case "fr": return ["fr-FR"];
            case "hk": return ["zh-Hant-HK"];
            case "cn": return ["zh-Hant-CN"];
            case "in": return ["en-IN"];
            case "it": return ["it-IT"];
            case "jp": return ["ja-JP"];
            case "kr": return ["ko-KR"];
            case "mx": return ["es-MX"];
            case "my": return ["en-MY"];
            case "nl": return ["nl-NL"];
            case "no": return ["nb-NO"];
            case "nz": return ["en-NZ"];
            case "pe": return ["es-PE"];
            case "ph": return ["en-PH"];
            case "pl": return ["pl-PL"];
            case "ru": return ["ru-RU"];
            case "se": return ["sv-SE"];
            case "sg": return ["en-SG"];
            case "th": return ["th-TH"];
            case "tr": return ["tr-TR"];
            case "tw": return ["zh-Hant-TW"];
            case "uk": return ["en-GB"];
            case "us": return ["en-US"];
            case "ve": return ["es-VE"];
            case "vn": return ["vi-VN"];
            case "id": return ["id-ID"];
            default: return ["en-US"];
        }
    };
    
    /**
     * Returns the language among those available that
     * best matches the user's preferences, using the Lookup
     * algorithm of RFC 4647.
     * If none of the available languages meets the user's preferences,
     * then <code>availableLanguages[0]</code> is returned.
     * @method findBestLanguage
     * @param {String[]} availableLanguages The list of languages
     * that the application supports, represented as RFC 4646 language
     * tags.
     * @return {String} The available language that best matches the
     * user's preferences.
     */
    openmailintl.findBestLanguage = function (availableLanguages) {
        
        var preferencesList, i, language, normalized, result, index, normalization;
    
        preferencesList = getPreferredLanguages();
        
        // check whether the list of available languages
        // contains language; if so return it
        function scan(language) {
            var i;
            for (i = 0; i < availableLanguages.length; i += 1) {
                if (language.toLowerCase() === availableLanguages[i].toLowerCase()) {
                    return availableLanguages[i];
                }
            }
        }
        
        normalization = {
            "zh-hk": "zh-Hant-TW",
            "zh-cn": "zh-Hant-CN",
            "zh-tw": "zh-Hant-TW",
            "zh": "zh-Hant-CN",
            "hk": "zh-Hant-TW",
            "en": "en-US",
            "es": "es-ES",
            "fr": "fr-FR",
            "hi": "hi-IN",
            "id": "id-ID",
            "it": "it-IT",
            "ja": "ja-JP",
            "kr": "ko-KR",
            "nb": "nb-NO",
            "nl": "nl-NL",
            "pl": "pl-PL",
            "pt": "pt-BR",
            "ru": "ru-RU",
            "sv": "sv-SE",
            "th": "th-TH",
            "tr": "tr-TR",
            "vi": "vi-VN",
            "zh": "zh-Hans-CN",
            "zh-cn": "zh-Hans-CN",
            "zh-hk": "zh-Hant-HK",
            "zh-tw": "zh-Hant-TW"
        };
        if (YAHOO.lang.isString(preferencesList)) {
            preferencesList = preferencesList.split(/[, ]/);
        }
        for (i = 0; i < preferencesList.length; i += 1) {
            language = preferencesList[i];
            if (!language) {
                continue;
            }
            normalized = normalization[language.toLowerCase()];
            if (normalized) {
                language = normalized;
            }
            // check the fallback sequence for one language
            while (language.length > 0) {
                result = scan(language);
                if (result) {
                    return result;
                } else {
                    index = language.lastIndexOf("-");
                    if (index >= 0) {
                        language = language.substring(0, index);
                        // one-character subtags get cut along with the following subtag
                        if (index >= 2 && language.charAt(index - 2) === "-") {
                            language = language.substring(0, index - 2);
                        }
                    } else {
                        // nothing available for this language
                        break;
                    }
                }
            }
        }
        
        // we use the first available language as the default
        return availableLanguages[0];
    };
    
    
    var getFile = function (url) {
        var XHR;
        if (window.XMLHttpRequest) {
            XHR = new XMLHttpRequest();
        } else {
            XHR = new ActiveXObject("Microsoft.XMLHTTP");
        }
        if (XHR) {
            XHR.open("GET", url, false);
            XHR.send(null);
            if (XHR.status === 200) {
                return XHR.responseText;
            }
        }
    };

    /**
     * Retrieves a language specific JSON file that's part of the application's assets,
     * and returns the decoded JSON object. 
     * The method first looks for the asset with the name <code>assetPath + baseName + "_" + language + ".json"</code>.
     * If that asset doesn't exist, it looks for the asset with the name <code>assetPath + baseName + ".json"</code>.
     * @method getResources
     * @param {String} assetPath The path to the assets of the application.
     * @param {String} baseName The base name of a resource bundle.
     * @param {String} language The language for which resources are needed, as an RFC 4646 language tag.
     * @return {Object} The object decoded from the JSON file found.
     */
    openmailintl.getResources = function (assetPath, baseName, language) {
        var url, contents;
        
        if (assetPath.charAt(assetPath.length - 1) !== "/") {
            assetPath += "/";
        }
        if (language) {
            url = assetPath + baseName + "_" + language + ".json";
        } else {
            url = assetPath + baseName + ".json";
        }
       
        contents = getFile(url);
        if (contents) {
            try {
                return YAHOO.lang.JSON.parse(contents);
            } catch (x) {
            }
        }
        if (language) {
            return this.getResources(assetPath, baseName);
        } else {
            throw new Error("bundle " + baseName + " for language " + language + " not found.");
        }
    };

    /**
     * Formats a string by substituting parameters into the pattern.
     * The pattern syntax is similar to that of the Java
     * <a href="http://java.sun.com/j2se/1.5.0/docs/api/java/text/MessageFormat.html">MessageFormat class</a>,
     * but currently only the following format elements are supported:
     * <ul>
     * <li>{ <i>ArgumentIndex</i> }
     * <li>{ <i>ArgumentIndex</i> , number }
     * <li>{ <i>ArgumentIndex</i> , date }
     * </ul>
     * Quote characters do not escape braces; if you want to use
     * a literal brace, write it as &amp;#x007b; or &amp;#x007d;.
     * @method formatMessage
     * @param {String} pattern The pattern string into which the arguments are inserted.
     * @param {Object[]} arguments The objects to insert into the pattern string.
     * @param {String} language The language for which arguments such as numbers and dates
     * should be formatted.
     * @return {String} The pattern string with substituted parameters.
     */
    openmailintl.formatMessage = function (pattern, args, language) {
        var i, j, k, token, key, value, meta;

        for (;;) {
            i = pattern.lastIndexOf('{');
            if (i < 0) {
                break;
            }
            j = pattern.indexOf('}', i);
            if (i + 1 >= j) {
                break;
            }

            // extract format element information
            token = pattern.substring(i + 1, j);
            key = token;
            meta = null;
            k = key.indexOf(',');
            if (k > -1) {
                meta = key.substring(k + 1);
                key = key.substring(0, k);
            }

            // lookup the value
            value = args[key];
            
            if (meta !== null) {
                if (meta.indexOf("date") === 0 && value instanceof Date) {
                    value = value.toLocaleString();
                } else if (meta.indexOf("number") === 0 && typeof value === "number") {
                    value = value.toLocaleString();
                }
            }

            pattern = pattern.substring(0, i) + value + pattern.substring(j + 1);
        }

        return pattern;
    };
    
    return openmailintl;

}();

