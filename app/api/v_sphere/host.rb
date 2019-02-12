# frozen_string_literal: true

require 'rbvmomi'
require_relative 'connection'
require_relative 'cluster'

# This class wraps a rbvmomi Host and provides easy access to common operations
module VSphere
  class Host
    def self.all
      VSphere::Cluster.all.map(&:hosts).flatten
    end

    def self.get_host(name)
      VSphere::Host.all.each do |host|
        return host if host.name == name
      end
      nil
    end

    def initialize(rbvmomi_host)
      @host = rbvmomi_host
    end

    def vms
      @host.vm.map { |each| VSphere::VirtualMachine.new each }
    end

    def name
      @host.name
    end

    def model
      @host.hardware.systemInfo.model
    end

    def vendor
      @host.hardware.systemInfo.vendor
    end

    def boot_time
      @host.runtime.bootTime
    end

    def connection_state
      @host.runtime.connectionState
    end

    def summary
      @host.summary
    end

    def equal?(other)
      other.is_a?(VSphere::Host) && name == other.name
    end

    def ==(other)
      equal? other
    end

    def cpu_cores
      @host.summary.hardware&.numCpuCores || 0
    end

    def ram_gb
      ((@host.summary.hardware&.memorySize&.to_f || 0) / 1024**3).round(2)
    end

    def free_storage_gb
      ((@host&.datastore&.sum { |datastore| datastore.summary.freeSpace }&.to_f || 0) / 1024**3).round(2)
    end

    def storage_gb
      ((@host&.datastore&.sum { |datastore| datastore.summary.capacity }&.to_f || 0) / 1024**3).round(2)
    end

    def enough_resources?(cpu_cores, ram_gb, storage_gb)
      cpu_cores <= self.cpu_cores && ram_gb <= self.ram_gb && storage_gb <= free_storage_gb
    end

    private

    def managed_folder_entry
      @host
    end
  end
end
