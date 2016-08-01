module Fog
  module Network
    class AzureRM
      # NetworkInterface model class for Network Service
      class NetworkInterface < Fog::Model
        identity :name
        attribute :id
        attribute :location
        attribute :resource_group
        attribute :virtual_machine_id
        attribute :mac_address
        attribute :network_security_group_id
        attribute :ip_configuration_name
        attribute :ip_configuration_id
        attribute :subnet_id
        attribute :private_ip_allocation_method
        attribute :private_ip_address
        attribute :public_ip_address_id
        attribute :load_balancer_backend_address_pools_ids
        attribute :load_balancer_inbound_nat_rules_ids
        attribute :dns_servers
        attribute :applied_dns_servers
        attribute :internal_dns_name_label
        attribute :internal_fqd

        def self.parse(nic)
          nic_properties = nic['properties']
          nic_ip_configuration = nic_properties['ipConfigurations'][0]
          hash = {}
          hash['id'] = nic['id']
          hash['name'] = nic['name']
          hash['location'] = nic['location']
          hash['resource_group'] = nic['id'].split('/')[4]
          hash['virtual_machine_id'] = nic_properties['virtualMachine']['id'] unless nic_properties['virtualMachine'].nil?
          hash['mac_address'] = nic_properties['macAddress'] unless nic_properties['macAddress'].nil?
          hash['network_security_group_id'] = nil
          hash['network_security_group_id'] = nic_properties['networkSecurityGroup']['id'] unless nic_properties['networkSecurityGroup'].nil?
          unless nic_ip_configuration.nil?
            nic_ip_configuration_properties = nic_ip_configuration['properties']
            hash['ip_configuration_name'] = nic_ip_configuration['name']
            hash['ip_configuration_id'] = nic_ip_configuration['id']
            hash['subnet_id'] = nic_ip_configuration_properties['subnet']['id'] unless nic_ip_configuration_properties['subnet'].nil?
            hash['private_ip_allocation_method'] = nic_ip_configuration_properties['privateIPAllocationMethod']
            hash['private_ip_address'] = nic_ip_configuration_properties['privateIPAddress']
            hash['public_ip_address_id'] = nil
            hash['public_ip_address_id'] = nic_ip_configuration_properties['publicIPAddress']['id'] unless nic_ip_configuration_properties['publicIPAddress'].nil?
            hash['load_balancer_backend_address_pools_ids'] = nic_ip_configuration_properties['loadBalancerBackendAddressPools'].map { |item| item['id'] } unless nic_ip_configuration_properties['loadBalancerBackendAddressPools'].nil?
            hash['load_balancer_inbound_nat_rules_ids'] = nic_ip_configuration_properties['loadBalancerInboundNatRules'].map { |item| item['id'] } unless nic_ip_configuration_properties['loadBalancerInboundNatRules'].nil?
          end

          hash['dns_servers'] = nic_properties['dnsSettings']['dnsServers']
          hash['applied_dns_servers'] = nic_properties['appliedDnsServers']
          hash['internal_dns_name_label'] = nic_properties['internalDnsNameLabel']
          hash['internal_fqd'] = nic_properties['internalFqd']
          hash
        end

        def save
          requires :name
          requires :location
          requires :resource_group
          requires :subnet_id
          requires :ip_configuration_name
          requires :private_ip_allocation_method
          nic = service.create_or_update_network_interface(resource_group, name, location, subnet_id, public_ip_address_id, ip_configuration_name, private_ip_allocation_method, private_ip_address)
          merge_attributes(Fog::Network::AzureRM::NetworkInterface.parse(nic))
        end

        def update(updated_attributes = {})
          validate_update_attributes!(updated_attributes)
          merge_attributes(updated_attributes)
          nic = service.create_or_update_network_interface(resource_group, name, location, subnet_id, public_ip_address_id, ip_configuration_name, private_ip_allocation_method, private_ip_address)
          merge_attributes(Fog::Network::AzureRM::NetworkInterface.parse(nic))
        end

        def attach_subnet(subnet_id)
          raise 'Subnet ID can not be nil.' if subnet_id.nil?
          nic = service.attach_resource_to_nic(resource_group, name, SUBNET, subnet_id)
          merge_attributes(Fog::Network::AzureRM::NetworkInterface.parse(nic))
        end

        def attach_public_ip(public_ip_id)
          raise 'Public-IP ID can not be nil.' if public_ip_id.nil?
          nic = service.attach_resource_to_nic(resource_group, name, PUBLIC_IP, public_ip_id)
          merge_attributes(Fog::Network::AzureRM::NetworkInterface.parse(nic))
        end

        def attach_network_security_group(network_security_group_id)
          raise 'Network-Security-Group ID can not be nil.' if network_security_group_id.nil?
          nic = service.attach_resource_to_nic(resource_group, name, NETWORK_SECURITY_GROUP, network_security_group_id)
          merge_attributes(Fog::Network::AzureRM::NetworkInterface.parse(nic))
        end

        def detach_public_ip
          raise "Error detaching Public IP. No Public IP is attached to Network Interface #{name}" if public_ip_address_id.nil?
          nic = service.detach_resource_from_nic(resource_group, name, PUBLIC_IP)
          merge_attributes(Fog::Network::AzureRM::NetworkInterface.parse(nic))
        end

        def detach_network_security_group
          raise "Error detaching Network Security Group. No Security Group is attached to Network Interface #{name}" if network_security_group_id.nil?
          nic = service.detach_resource_from_nic(resource_group, name, NETWORK_SECURITY_GROUP)
          merge_attributes(Fog::Network::AzureRM::NetworkInterface.parse(nic))
        end

        def destroy
          service.delete_network_interface(resource_group, name)
        end

        def validate_update_attributes!(hash)
          restricted_attributes = [:name, :id, :resource_group, :location, :ip_configuration_name, :ip_configuration_id]
          hash_keys = hash.keys
          invalid_attributes = restricted_attributes & hash_keys
          raise "Attributes #{invalid_attributes.join(', ')} can not be updated." unless invalid_attributes.empty?
        end
      end
    end
  end
end
