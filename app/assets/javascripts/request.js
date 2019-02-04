$('#request_template_selection').click(function (){
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