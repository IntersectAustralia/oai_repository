require "oai_repository/engine"

module OaiRepository

  def self.setup
    yield self
  end

  mattr_accessor :repository_name
  @@repository_name = 'Unspecified'

  mattr_accessor :repository_url
  @@repository_url = nil

  mattr_accessor :record_prefix
  @@record_prefix = 'PREFIX'

  mattr_accessor :admin_email
  @@admin_email = 'root@localhost'

  mattr_accessor :sets
  @@sets = {}
=begin
  {
    'class:party' => Person,
    'class:service' => Instrument
  }
=end

  mattr_accessor :additional_formats
  @@formats = []
  ##OAI::Provider::Metadata::RIFCS.instance

end
