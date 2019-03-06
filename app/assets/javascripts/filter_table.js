function hide(htmlElm) {
    htmlElm.style.display = 'none';
}

function unhide(htmlElm) {
    htmlElm.style.display = '';
}

function someCellInRowContains(row, searchTexts) {
    let remainingFilters = searchTexts.filter(searchText =>
        !Array.prototype.some.call(row, cell => {
            let txtValue = (cell.dataset && cell.dataset.filterValue) || cell.textContent || cell.innerText;
            return txtValue.toUpperCase().includes(searchText);
        })
    );
    return remainingFilters.length === 0;
}


function filterTable(inputId, tableId) {
    const input = document.getElementById(inputId);
    const table = document.getElementById(tableId);
    if (!table || !input) {
        return;
    }

    const filters = input.value.toUpperCase().split(/[ ,]+/);
    const rows = table.getElementsByTagName('tr');
    let invisible = 0;

    // Loop through all table rows, and hide those who don't match the search query ignoring the headline
    for (let i = 1; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName('td');

        if (someCellInRowContains(cells, filters)) {
            unhide(rows[i]);
        } else {
            hide(rows[i]);
            invisible++;
        }
    }

    if (invisible === rows.length - 1) {
        hide(table);
    } else {
        unhide(table);
    }
}

function filterTables(inputId, tableIds) {
    for (const tableID of tableIds) {
        filterTable(inputId, tableID)
    }
}