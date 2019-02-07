# frozen_string_literal: true

require 'rbvmomi'
require_relative 'connection'
require_relative 'host'

# This class wraps a rbvmomi ComputeResource or ClusterComputeResource and provides easy access to common operations
module VSphere
  class Cluster
    def self.all
      VSphere::Connection.instance.clusters_folder&.clusters(recursive: true) || []
    end

    def initialize(rbvmomi_cluster)
      @cluster = rbvmomi_cluster
    end

    def hosts
      @cluster.host.map { |each| VSphere::Host.new each }
    end

    def resource_pool
      @cluster.resourcePool
    end

    def name
      @cluster.name
    end

    def equal?(other)
      other.is_a?(VSphere::Cluster) && name == other.name
    end

    def ==(other)
      equal? other
    end

    private

    def managed_folder_entry
      @cluster
    end
  end
end
