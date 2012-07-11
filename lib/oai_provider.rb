require 'oai'
require 'patched_record_response'
require 'ar_wrapper_model'
module OAIProvider

  @@provider = nil

  def self.provider
    @@provider ||= build_set_provider 
  end

  private

  def self.build_set_provider

    provider_name = "ARProvider"
    provider_class = Object.const_set(provider_name, Class.new(OAI::Provider::Base))
    provider_class.repository_name OaiRepository.repository_name
    provider_class.repository_url OaiRepository.repository_url
    provider_class.record_prefix OaiRepository.record_prefix
    provider_class.admin_email 'root@localhost'
    provider_class.source_model ARWrapperModel.new(:sets => OaiRepository.sets)
    OaiRepository.additional_formats.each do |format|
      provider_class.register_format(format.instance)
    end
    provider_class

  end

end
