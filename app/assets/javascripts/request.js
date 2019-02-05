$('#request_template_id').click(function (){
    cpus = document.getElementById('cpu');
    ram = document.getElementById('ram');
    storage = document.getElementById('storage');
    os = document.getElementById('operating_system');

    if(this.value === 'none') {
        cpus.value = "";
        ram.value = "";
        storage.value = "";
        os.value = "none";
    }
    else {
        value = this.value;
        clean_value = value.replace(/[[\]']+/g,'');
        requirements = clean_value.split(/, /);
        cpu_cores = requirements[0];
        ram_mb = requirements[1];
        storage_mb = requirements[2];
        operating_system = requirements[3];
        operating_system_clean = operating_system.replace(/[""]+/g,'');
        cpus.value = cpu_cores;
        ram.value = ram_mb;
        storage.value = storage_mb;
        os.value = operating_system_clean;
    }
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
