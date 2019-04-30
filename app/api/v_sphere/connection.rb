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
      initialize_settings
      not_empty?(@server_ip) && not_empty?(@server_user) && not_empty?(@server_password)
    end

    private

    def not_empty?(string)
      !string.nil? && !string.empty?
    end

    def initialize_settings
      @server_ip = AppSetting.instance.vsphere_server_ip
      @server_user = AppSetting.instance.vsphere_server_user
      @server_password = AppSetting.instance.vsphere_server_password
      @root_folder_name = AppSetting.instance.vsphere_root_folder
    end

    def connect
      return unless configured?

      # only create new connection if there is no other valid, because otherwise it will allocate more and more tcp
      # connections until it is not possible to create more and thus the server will throw an error
      create_connection if @vim.nil? || !connected?
    end

    # currentSession is nil if session does not exist, e.g. because it disconnected
    def connected?
      !@vim.serviceContent.sessionManager.currentSession.nil?
    end

    def create_connection
      @vim = RbVmomi::VIM.connect(host: @server_ip, user: @server_user, password: @server_password, insecure: true)
      @dc = @vim.serviceInstance.find_datacenter('Datacenter') || raise('datacenter not found')
      @vm_folder = VSphere::Folder.new(@dc.vmFolder)
      @vm_folder = @vm_folder.ensure_subfolder(@root_folder_name) if not_empty?(@root_folder_name)
      @cluster_folder = VSphere::Folder.new @dc.hostFolder
    end
  end
end
