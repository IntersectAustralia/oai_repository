require 'oai_provider'
require 'rif-cs'
class Instrument < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include RIFCS::Service

  attr_accessible :key, :name, :description

  def sets
    [
      OAI::Set.new({:name => 'class:service', :spec => 'class:service'}),
      OAI::Set.new({:name => 'Intersect Australia Ltd', :spec => 'group:Intersect Australia Ltd'})
    ]
  end

  def oai_dc_identifier
    instrument_url(id)
  end

  def oai_dc_title
    name
  end

  def oai_dc_description
    description
  end

  def oai_dc_publisher
    'Intersect'
  end

  def service_key
    key
  end

  def service_group
    'Intersect'
  end

  def service_originating_source
    'http://www.intersect.org.au'
  end

  def service_date_modified
    updated_at
  end

  def service_type
    'create'
  end

end
