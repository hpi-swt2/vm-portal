document.addEventListener("turbolinks:before-visit", function (event) {
    var origin = window.location.href;
    var destination = event.data.url;
    if (origin.match(/#/) === null) {
        if (origin[origin.length - 1] === "/") {
            origin = origin.substring(0, origin.length - 1);
        }
    }
    else {
        var hashIndex = origin.indexOf('#');
        if (hashIndex > 0 && origin[hashIndex - 1] === "/")
            origin = "" + origin.substring(0, (hashIndex - 1)) + origin.substring(hashIndex);
    }
    if (destination.match(/#/) === null) {
        if (destination[destination.length - 1] === "/") {
            destination = destination.substring(0, destination.length - 1);
        }
    }
    else {
        var hashIndex = destination.indexOf('#');
        if (hashIndex > 0 && destination[hashIndex - 1] === "/")
            destination = "" + destination.substring(0, (hashIndex - 1)) + destination.substring(hashIndex);
    }

    if (origin === destination)
        return;

    var shorterLength = Math.min(origin.length, destination.length);
    if (((origin.match(/#/) !== null) && (destination.match(/#/) !== null)) &&
        (origin.indexOf("#") === destination.indexOf("#"))) {
        shorterLength = Math.min(origin.indexOf("#"), destination.indexOf("#"));
    }
    if (origin.substring(0, shorterLength) !== destination.substring(0, shorterLength)) {
        return;
    }
    if (destination.length > shorterLength && destination[shorterLength] === "#") {
        event.preventDefault();
        var urlHashMinusHash = destination.substring(destination.indexOf('#')).substring(1);
        var elem = document.getElementById(urlHashMinusHash);
        if (elem != null)
            elem.scrollIntoView();
        return;
    }

    if (origin.length > shorterLength && origin[shorterLength] === "#") {
        event.preventDefault();
        $("html, body").animate({ scrollTop: 0 }, "slow");
        return;
    }
});
