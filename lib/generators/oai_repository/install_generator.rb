module OaiRepository
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates an OAI Repository initializer."
      def copy_initializer
        template "oai_repository.rb", "config/initializers/oai_repository.rb"
      end
    end
  end
end
