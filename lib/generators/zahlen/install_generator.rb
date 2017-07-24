module Zahlen
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def install_initializer
      initializer 'zahlen.rb', File.read(File.expand_path('../templates/initializer.rb', __FILE__))
    end

    def install_js
      inject_into_file 'app/assets/javascripts/application.js', after: "//= require jquery\n" do <<-'JS'
//= require zahlen
      JS
      end
    end

    def install_route
      route "mount Zahlen::Engine => '/zahlen', as: :zahlen"
    end
  end
end
