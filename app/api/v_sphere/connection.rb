# frozen_string_literal: true

require 'rbvmomi'
require 'singleton'
require_relative 'virtual_machine'
require_relative 'folder'
require_relative 'cluster'

# This module is responsible for communicating with vSphere
# It creates wrapper objects for Virtual Machines and Folders which allow easy access to all tasks and information
# rbvmomi methods or other underlying vSphere API methods should NOT be called directly outside of this module!
# If you need additional vSphere features, implement them as methods on classes of the VSphere module
#
# To instantiate VMs, please use the VSphere::VirtualMachine static methods
module VSphere
  # This class manages a connection to the VSphere backend
  # For rbvmomi documentation see: https://github.com/vmware/rbvmomi/tree/master/examples
  # For documentation of API objects have a look at this:
  # https://code.vmware.com/apis/196/vsphere#/doc/vim.VirtualMachine.html
  class Connection
    include Singleton

    API_SERVER_IP = '192.168.30.3'
    API_SERVER_USER = 'administrator@swt.local'
    API_SERVER_PASSWORD = 'Vcsaswt"2018'

    def root_folder
      connect

      @vm_folder
    end

    def clusters_folder
      connect

      @cluster_folder
    end

    private

    def connect
      @vim = RbVmomi::VIM.connect(host: API_SERVER_IP, user: API_SERVER_USER, password: API_SERVER_PASSWORD, insecure: true)
      @dc = @vim.serviceInstance.find_datacenter('Datacenter') || raise('datacenter not found')
      @vm_folder = VSphere::Folder.new @dc.vmFolder
      @cluster_folder = VSphere::Folder.new @dc.hostFolder
      @resource_pool = VSphere::Cluster.all.first.resource_pool
    end
  end
end
