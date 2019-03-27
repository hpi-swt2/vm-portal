//= require datatables/jquery.dataTables
//= require datatables/dataTables.bootstrap4

// Global settings and initializer for all datatables
$.extend( $.fn.dataTable.defaults, {
  // https://datatables.net/reference/option/responsive
  responsive: true,
  // https://datatables.net/reference/option/pagingType
  pagingType: 'simple_numbers'
  // https://datatables.net/reference/option/dom
  //dom:
  //  "<'row'<'col-sm-4 text-left'f><'right-action col-sm-8 text-right'<'buttons'B> <'select-info'> >>" +
  //  "<'row'<'dttb col-12 px-0'tr>>" +
  //  "<'row'<'col-sm-12 table-footer'lip>>"
});

// Initialization on turbolinks load
$(document).on('turbolinks:load', function() {
  if (!$.fn.DataTable.isDataTable('table[data-toggle="datatable"]')) {
    $('table[data-toggle="datatable"]').DataTable();
  }
});

// Turbolinks cache fix
// https://stackoverflow.com/questions/41070556
$(document).on('turbolinks:before-cache', function() {
  $($.fn.dataTable.tables(true)).DataTable().destroy();
});

