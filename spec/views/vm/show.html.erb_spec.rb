# frozen_string_literal: true
# TODO: klären, inwieweit View tests gemacht werden sollen

require 'rails_helper'

RSpec.describe 'vm/show.html.erb', type: :view do
  let(:vm) do
    { name:'My insanely cool vm', 
        state: true, 
        boot_time: 'Thursday', 
        guest: {
          disk: {
            capacity: 100,
            freeSpace: 50
          },
          guestFamily: 'Windows',
          guestFullName: 'Win10 Enterprise',
          guestState: 'running',
          hostName: 'aHost',
          ipAddress: '0.0.0.0'
        },
        guestHeartbeatStatus: 'green',
        resourceConfig: {
          cpuAllocation: 100,
          memoryAllocation: 2048
        },
        resourcePool: {
          summary: {
            configuredMemoryMB: 2048,
            quickStats: {
              overallCpuUsage: 50,
              guestMemoryUsage: 1024
            }
          }
        }
      }
  end

  before do
    assign(:vm, [vm])
    render
  end

  it 'shows vm name' do
    expect(rendered).to include vm[:name]
  end

  it 'shows vm boot time' do
    expect(rendered).to include vm[:boot_time]
  end

  it 'shows vm OS' do
    expect(rendered).to include vm[:guest[:guestFamily]]
  end

  it 'shows vm OS version' do
    expect(rendered).to include vm[:guest[:ipAddress]]
  end

  it 'shows vm IP address' do
    expect(rendered).to include vm[:guest[:ipAddress]]
  end

  it 'shows vm disk capacity' do
    expect(rendered).to include vm[:guest[:disk[:capacity]]]
  end
  
  it 'shows vm disk free space' do
    expect(rendered).to include vm[:guest[:disk[:freeSpace]]]
  end
  
  it 'shows vm disk capacity' do
    expect(rendered).to include vm[:guest[:disk]]
  end

end

