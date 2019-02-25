function filter_table(input_id, table_id, doc) {
  let input = doc.getElementById(input_id);
  let filters = input.value.toUpperCase().split(/[ ,]+/);
  let table = doc.getElementById(table_id);
  let tableBody = table.getElementsByTagName("tbody")[0];
  let tr = tableBody.getElementsByTagName("tr");
  
  // Loop through all table rows, and hide those who don't match the search query
  for (let rowIndex = 0; rowIndex < tr.length; rowIndex++) {
    let td = tr[rowIndex].getElementsByTagName("td");
    let remainingFilters = filters;
    for (let columnIndex = 0; columnIndex < td.length; columnIndex++) {
      let txtValue = td[columnIndex].textContent || td[columnIndex].innerText;
      remainingFilters = remainingFilters.filter((filter) => txtValue.toUpperCase().indexOf(filter) < 0);
    }
    tr[rowIndex].style.display = remainingFilters.length > 0 ? "none" : "";
  }
}