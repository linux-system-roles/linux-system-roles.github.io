function getGetVariable(name) {
    'use strict';
    var query = window.location.search.substr(1);
    var variables = query.split("&");
    var chrmap = { '>': '&gt;', '<': '&lt;', '&': '&amp;', '"': '&quot;',
                   "'": '&#39;', '/': '&#x2F;' };
    for (var i=0; i<variables.length; i++) {
	if (variables[i].indexOf("=") != -1) {
            var splits = variables[i].split("=");
            if (splits[0] == name) {
		return decodeURIComponent(splits[1].replace(/\+/g, '%20'))
		    .replace(/[&<>"'\/]/g, function(x) { return chrmap[x];})
            }
	}
    }
    return null;
}

function getExcerpt(text, regex, excerpt_length) {
    var start = text.search(regex);
    start = text.lastIndexOf(" ", start-10);
    if (start < 0) {
        start = 0;
    }

    var end = start + excerpt_length;
    if (end > text.length || end < 0) {
        end = text.length;
        if (start > 0) {
            start = end - excerpt_length;
            start = text.lastIndexOf(" ", start-2);
            if (start < 0) {
                start = 0;
            }
        }
    }
    end = text.indexOf(" ", end);
    if (end < 0) {
        end = text.length;
    }
    
    excerpt = text.substr(start, end-start);
    excerpt = excerpt.replace(regex, "<b>$&</b>");
    
    if (start > 0) {
        excerpt = "... " + excerpt;
    }
    if (end < text.length) {
        excerpt = excerpt + " ...";
    }

    return excerpt;
}

function htmlDecode(value) {
    return $('<div/>').html(value).text();
}
