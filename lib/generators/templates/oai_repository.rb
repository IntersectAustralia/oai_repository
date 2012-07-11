require 'rifcs_format'
OaiRepository.setup do |config|

  config.repository_name = 'NAME YOUR REPOSITORY'

  # The URL from which this OAI Repository is served.
  # If you're deploying to different hostnames (e.g. development, QA and
  # production environments, each with different hostnames), you could
  # conditionally set this.
  config.repository_url = 'URL OF THE REPOSITORY'

  # By default the (unique) identifier of each record will be composed as
  # #{record_prefix}/#{record.id}
  # This is probably not want you want, especially if you have multiple record
  # sets (i.e. this provider serves multiple ActiveRecord models)
  #
  # Most probably you'll create an oai_dc_identifier attribute or method in
  # the AR models you intend to serve. That value will supplant the default.
  config.record_prefix = 'http://localhost:3000/'

  config.admin_email = 'change_me@example.com'

  # Map the name of the set to the ActiveRecord (or other) class name that
  # will provide (at a minimum) the required oai_dc attributes/methods.
  # E.g.
  # config.sets = [
  #   {
  #     spec: 'class:party',
  #     name: 'Parties',
  #     model: Person
  #   },
  #   {
  #     spec: 'class:service',
  #     name: 'Services',
  #     description: 'Things that are services',
  #     model: Instrument
  #   }
  # ]
  config.sets = []

  config.additional_formats = [
    OAI::Provider::Metadata::RIFCS
  ]

end
