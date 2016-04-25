(function () {
    prettifyJson = function prettifyJson(obj) {
        return JSON.stringify(obj, null, 2);
    };


    var elements = document.querySelectorAll('[data-prettify]');
    for (var i = 0; i < elements.length; i++) {
        var el = elements[i];
        try {
            obj = JSON.parse(el.value)
            el.value = prettifyJson(obj)
        } catch (e) {
        }
    }
})();