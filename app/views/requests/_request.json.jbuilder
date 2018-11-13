json.extract! request, :id, :operating_system, :ram_mb, :cpu_cores, :software, :comment, :status, :created_at, :updated_at
json.url request_url(request, format: :json)
