$('#request_template_id').change(function (){
    // The '(none)' option is selected
    if(this.value === '') {
        var params = {cpu_cores: '', ram_gb: '', storage_gb: '', operating_system: '(none)'};
    }
    else {
        var params = JSON.parse(this.value);
    }
    document.getElementById('cpu').value = params.cpu_cores;
    document.getElementById('ram').value = params.ram_gb;
    document.getElementById('storage').value = params.storage_gb;
    document.getElementById('operating_system').value = params.operating_system;
 });

 if($('#request_port_forwarding_checkbox').prop("data-port_forwarding") == "true" ||
    $('#request_port_forwarding_checkbox').prop("checked") ||
    $('#port_field').val() ||
    $('#application_name_field').val()) {
    $('#request_port_forwarding_checkbox').prop('checked', true);
    $('#request_port_forwarding_info').addClass('show')
  }
  else{
     $('#request_port_forwarding_checkbox').prop('checked', false);
     $('#request_port_forwarding_info').addClass('remove')
  } 
