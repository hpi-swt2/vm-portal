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

    # Warning:
    # This method may return nil, if no connection could be established!
    def root_folder
      connect

      @vm_folder
    end

    # Warning:
    # This method may return nil, if no connection could be established!
    def clusters_folder
      connect

      @cluster_folder
    end

    def configured?
      !@server_ip.nil? && !@server_user.nil? && !@server_password.nil?
    end

    private

    def initialize_settings
      @server_ip = AppSetting.instance.vsphere_server_ip
      @server_user = AppSetting.instance.vsphere_server_user
      @server_password = AppSetting.instance.vsphere_server_password
    end

    def connect
      initialize_settings
      return unless configured?

      @vim = RbVmomi::VIM.connect(host: @server_ip, user: @server_user, password: @server_password, insecure: true)
      @dc = @vim.serviceInstance.find_datacenter('Datacenter') || raise('datacenter not found')
      @vm_folder = VSphere::Folder.new @dc.vmFolder
      @cluster_folder = VSphere::Folder.new @dc.hostFolder
    end
  end
end
