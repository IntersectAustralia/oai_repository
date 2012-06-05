require 'oai_dc_record'
class Person < ActiveRecord::Base
  include OAIDCRecord
  attr_accessible :key, :title, :given_name, :family_name, :email, :group

  def full_name
    [title, given_name, family_name].join(' ')
  end

  def self.name_of_set
    'person'
  end

  def self.map_oai_dc
    {
      :identifier => :key,
      :title => :given_name,
      :subject => :group,
      :description => :email
    }
  end
end
