module OaiRepository
  class ServicesController < ApplicationController
    require 'oai_dc_record'
    def show
      # TODO: use the set param to determine provider (and hence record/model type)
      # providers should be dynamically created?
      verb = params[:verb]
      record_set = params[:set]
puts "SMC record_set=#{record_set.inspect}"
puts "SMC models=#{OAIDCRecord.models.inspect}"
#puts "SMC providers=#{OAIDCRecord.get_list_of_providers.inspect}"
      format = params[:metadataPrefix]

      if format =~ /oai_dc/
        if record_set.blank?
          # Get everything
        else
          if OAIDCRecord.provides?(record_set)
            options = params.delete_if { |k,v| %w{controller action}.include?(k) }
OAIDCRecord.get_providers(record_set).map {|p| puts p.new.list_records}
            #providers = OAIDCRecord.get_providers(record_set).process_request(options)
            #response = 
            #render :xml => response
          else
            #TODO: unknown set
          end
        end
      else
        #TODO: unsupported format
        render :status => 404
      end
    end

  end
end
