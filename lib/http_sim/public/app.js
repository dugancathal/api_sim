(function () {
    var prettifyJson = function prettifyJson(obj) {
        return JSON.stringify(obj, null, 2);
    };

    var prettyPrintAllThings = function prettyPrintAllThings() {
        var elements = document.querySelectorAll('[data-prettify]');
        for (var i = 0; i < elements.length; i++) {
            var el = elements[i];
            try {
                obj = JSON.parse(el.value);
                el.value = prettifyJson(obj)
            } catch (e) {
            }
        }
    };

    var allowCollapseOfTableRows = function allowCollapseOfTableRows() {
        var elements = document.querySelectorAll('tr');
        for (var i = 0; i < elements.length; i++) {
            var el = elements[i];

            el.onclick = function collapseTableRow(event) {
                var tr = event.target.parentNode;
                var lastTds = Array.prototype.slice.apply(tr.children).slice(1);
                lastTds.forEach(function (td) {
                    var tdContent = Array.prototype.slice.apply(td.children);
                    tdContent.forEach(function (innerElement) {
                        if (innerElement.style.display) {
                            innerElement.style.display = null;
                        } else {
                            innerElement.style.display = 'none';
                        }
                    });
                });
            }
        }
    };

    prettyPrintAllThings();
    allowCollapseOfTableRows();
})();