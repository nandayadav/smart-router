class RoutesGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      #m.class_collisions "#{class_name}Controller"
      #m.template('controller.rb', "app/controllers/#{file_name}_controller.rb")
      m.directory 'lib/tasks'
      m.template  'tasks/generate_files.rake.erb', 'lib/tasks/generate_files.rake'
      m.template 'config/routes.yml.erb', 'config/routes.yml'
    end
  end
end
