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

    def get_num_cpu
      @host.summary.hardware.numCpuCores
    end

    def get_ram_gb
      @host.summary.hardware.memorySize.to_i / 1024**2
    end

    def get_storage_gb
      @host.summary.host.datastore.sum { |datastore| datastore.summary.freeSpace }.to_i / 1024**2
    end

    private

    def managed_folder_entry
      @host
    end
  end
end
