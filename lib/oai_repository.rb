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

  mattr_accessor :models
  @@models = {}

  mattr_accessor :sets
  @@sets = {}

  mattr_accessor :additional_formats
  @@formats = []
  ##OAI::Provider::Metadata::RIFCS.instance

  mattr_accessor :limit
  @@limit = 100

  mattr_accessor :timestamp_field
  @@timestamp_field = 'updated_at'

  module Set

    def sets
      OaiRepository.sets.select {|s| s[:model] == self.class}.map{|set_obj|
        OAI::Set.new(
          {
            name: set_obj[:name],
            spec: set_obj[:spec],
            description: set_obj[:description]
          }
        )
      }
    end

  end
end
