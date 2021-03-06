require 'rifcs_format'
OaiRepository.setup do |config|

  config.repository_name = 'Test repository'
  config.repository_url = 'http://localhost:3000/oai_repository'
  config.record_prefix = 'http://localhost:3000/'
  config.admin_email = 'root@localhost'

  config.limit = 2

  config.models = [ Person, Instrument ]

  config.sets = [
    {
      spec: 'class:party',
      name: 'Parties',
      model: Person
    },
    {
      spec: 'class:service',
      name: 'Services',
      description: 'Things that are services',
      model: Instrument
    },
    {
      name: 'Intersect Australia Ltd',
      spec: 'group:Intersect Australia Ltd',
      model: Instrument
    }
  ]

  config.additional_formats = [
    OAI::Provider::Metadata::RIFCS
  ]

end
