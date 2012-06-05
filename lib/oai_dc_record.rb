require 'oai'
module OAIDCRecord

  @@models = []
  @@providers_map = {}

  def self.included(base)
    #puts "#{base.name} included OAIDCRecord"
    Rails.logger.debug("#{base.name} included OAIDCRecord")
    @@models << base
  end

  def self.models
    @@models
  end

  def self.provides?(set_name)
    get_list_of_providers.has_key?(set_name)
  end

  def self.get_providers(set_name)
    get_list_of_providers()[set_name]
  end

  def self.get_list_of_providers
    return @@providers_map unless @@providers_map.empty?
    @@models.each do |m|
      #name_of_set = Object.const_get(m).send(:name_of_set)
      name_of_set = m.send(:name_of_set)
      if @@providers_map.has_key?(name_of_set)
        @@providers_map[name_of_set] << get_provider_for(m, name_of_set)
      else
        @@providers_map[name_of_set] = [ get_provider_for(m, name_of_set) ]
      end
    end
    @@providers_map
  end

  def self.get_provider_for(m, set_name)
    provider_name = "#{m}Provider"
    #puts "Creating provider: #{provider_name} for set_name: #{set_name}"
    Rails.logger.debug("Creating provider: #{provider_name} for set_name: #{set_name}")
    provider_class = Object.const_set(provider_name, Class.new(OAI::Provider::Base))
    provider_class.repository_name 'Test OAI Repository'
    provider_class.repository_url 'http://localhost:3000/oai_repository'
    provider_class.record_prefix set_name
    provider_class.admin_email 'root@localhost'
    provider_class.source_model OAI::Provider::ActiveRecordWrapper.new(m)
    provider_class
  end

end
