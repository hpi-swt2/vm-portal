function filter_table(input_id, table_id, doc) {
  // Declare variables 
  var input, filter, table, tr, td, i, j, txtValue;
  input = doc.getElementById(input_id);
  filter = input.value.toUpperCase();
  table = doc.getElementById(table_id);
  tr = table.getElementsByTagName("tr");
  
  // Loop through all table rows, and hide those who don't match the search query
  for (i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td");
    for (j = 0; j < td.length; j++) {
        txtValue = td[j].textContent || td[j].innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            tr[i].style.display = "";
            break;
        }
        tr[i].style.display = "none";
    }
  }
}