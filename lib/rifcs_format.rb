require 'oai'
module OAI::Provider::Metadata

  class RIFCS < Format
    def initialize
      @prefix = 'rif'
      @schema = 'http://services.ands.org.au/documentation/rifcs/1.3/schema/registryObjects.xsd'
      @namespace = 'http://ands.org.au/standards/rif-cs/registryObjects'
      @element_namespace = 'rif-cs'
    end

    def header_specification
      {
        'xmlns' => "http://ands.org.au/standards/rif-cs/registryObjects" ,
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance" ,
        'xsi:schemaLocation' => "http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/1.3/schema/registryObjects.xsd"
      }
    end

  end

end
