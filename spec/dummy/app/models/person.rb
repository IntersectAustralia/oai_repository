require 'oai_repository'
require 'rif-cs'
require 'oai'
class Person < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include RIFCS::Party
  # Supplies "sets" method applying the sets mapped in the configuration to all
  # records.
  include OaiRepository::Set

  attr_accessible :key, :title, :given_name, :family_name, :email, :organisation

  def full_name
    [title, given_name, family_name].join(' ')
  end

  def oai_dc_identifier
    person_url(id)
  end

  def oai_dc_title
    full_name
  end

  def oai_dc_subject
    organisation
  end

  def oai_dc_description
    email
  end

  def party_key
    key
  end

  def party_group
    organisation
  end

  def party_originating_source
    'tomato'
  end

  def party_type
    'person'
  end

  def party_date_modified
    updated_at
  end

  def party_names
    [
      {
        type: 'primary',
        name_parts: [
          { type: 'title', value: title },
          { type: 'given', value: given_name },
          { type: 'family', value: family_name }
        ]
      },
    ]
  end


end
