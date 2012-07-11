module OaiRepository
  class ServicesController < ApplicationController
    require 'oai_provider'

    def show

      options = params.delete_if { |k,v| %w{controller action}.include?(k) }
      response = get_provider.process_request(options)
      render :xml => response
      
    end

    def get_provider
      @provider ||= OAIProvider::provider.new
    end

  end
end
