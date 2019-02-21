function hide(htmlElm) {
    htmlElm.style.display = 'none';
}

function unhide(htmlElm) {
    htmlElm.style.display = '';
}

function someCellInRowContains(row, searchedText) {
    return Array.prototype.some.call(row, cell => cell.textContent.toUpperCase().indexOf(searchedText) !== -1)
}

function filterTable(inputId, tableId) {
    const input = document.getElementById(inputId);
    const table = document.getElementById(tableId);

    const filter = input.value.toUpperCase();
    const rows = table.getElementsByTagName('tr');
    let invisible = 0;

    // Loop through all table rows, and hide those who don't match the search query ignoring the headline
    for (let i = 1; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName('td');

        if(someCellInRowContains(cells, filter)) {
            unhide(rows[i]);
        }
        else {
            hide(rows[i]);
            invisible++;
        }
    }

    if(invisible === rows.length - 1) {
        hide(table);
    }
    else {
        unhide(table);
    }
}

function filterTables(inputId, tableIds){
    for(const tableID of tableIds){
        filterTable(inputId, tableID)
    }
}