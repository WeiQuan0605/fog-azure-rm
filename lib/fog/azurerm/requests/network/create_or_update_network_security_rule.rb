module Fog
  module Network
    class AzureRM
      # Real class for Network Request
      class Real
        def create_or_update_network_security_rule(security_rule_hash)
          msg = "Creating/Updating Network Security Rule #{security_rule_hash[:name]} in Resource Group #{security_rule_hash[:resource_group]}."
          Fog::Logger.debug msg
          security_rule_params = get_security_rule_params(security_rule_hash)
          begin
            security_rule = @network_client.security_rules.create_or_update(security_rule_hash[:resource_group], security_rule_hash[:network_security_group_name], security_rule_hash[:name], security_rule_params)
          rescue MsRestAzure::AzureOperationError => e
            raise_azure_exception(e, msg)
          end
          Fog::Logger.debug "Network Security Rule #{security_rule_hash[:name]} Created/Updated Successfully!"
          security_rule
        end

        def get_security_rule_params(security_rule_hash)
          security_rule = Azure::ARM::Network::Models::SecurityRule.new
          security_rule.protocol = security_rule_hash[:protocol]
          security_rule.source_port_range = security_rule_hash[:source_port_range]
          security_rule.destination_port_range = security_rule_hash[:destination_port_range]
          security_rule.source_address_prefix = security_rule_hash[:source_address_prefix]
          security_rule.destination_address_prefix = security_rule_hash[:destination_address_prefix]
          security_rule.access = security_rule_hash[:access]
          security_rule.priority = security_rule_hash[:priority]
          security_rule.direction = security_rule_hash[:direction]
          security_rule
        end
      end
      class Mock
      end
    end
  end
end

