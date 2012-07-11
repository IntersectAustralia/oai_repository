module OAI::Provider::Response
  class RecordResponse < Base

  private

    def identifier_for(record)
      if record.respond_to?(:oai_dc_identifier)
        record.oai_dc_identifier
      else
        "#{provider.prefix}/#{record.id}"
      end
    end

  end

end
