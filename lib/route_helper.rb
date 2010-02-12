module RouteHelper

  # Returns a hash of parameter info for the passed controller/model. This allows us to
  # find relevant parameter meta information without coding against the actual names
  # used in the routes in the URL. For example, we can query for 'general_area_of_study'
  # rather than for 'degrees', which is a good thing because 'degrees' may change. It
  # also keeps the controllers agnostic regarding the routes.
  #
  # Example usage:
  #  url_param_info_for(:general_area_of_study)
  #  url_param_info_for('general_area_of_study')
  #  url_param_info_for(GeneralAreaOfStudy)
  def url_param_info_for(controller)
    name = controller if controller.is_a?(String)
    name = controller.name.underscore if name.blank? && controller.ancestors.include?(ActiveRecord::Base)
    name = controller.to_s unless name

    url_params.each do |key, value|
      return value if value[:controller] == name
    end

    nil
  end

  # Parses the URL and maps the key/value pairs into a hash.
  #
  # Example:
  #   online-degrees_business/programs_accounting
  #   # would return
  #   {'online-degrees' => {:type => GeneralAreaOfStudy, :id => 'business'}, 'programs' => {:type => CommonName, :id => 'accounting'}}
  #
  # NOTE: This method is tied closely to the routes file and may need to be updated when
  # routes get modified.
  def url_params(url=nil)
    url = correct_url(url)
    path_parts = url.split('/').delete_if {|part| part.strip.blank? }
    value = []

    path_parts.each do |part|
      keypair = part.split(ActionController::Routing.url_keypair_delimiter)
      what = keypair[0]
      segment = ActionController::Routing::Routes.segments[what]
      if segment
        param = {:what => what, :controller => segment.controller, :type => segment.model, :segment => segment}

        if keypair.length == 2
          which = keypair[1].split('.')
          format = which[1] if which.length > 1
          id = which[0]
          param.merge!({:id => id})
        end
        
        value << param
      end
    end

    value
  end

  # Returns the requested simple route.
  def requested_simple_route(url=nil)
    url = correct_url(url)
    value = url if url == '/'
    unless value
      segment_names = []
      url_params(url).each {|param| segment_names << param[:what]}
      value = segment_names.join('/')
    end

    ActionController::Routing::Routes.simple_routes.by_path[value]

    #simple_route = nil
    #ActionController::Routing::Routes.simple_routes.each do |route|
    #  break if simple_route
    #  simple_route = route if route.value == value
    #end
    #simple_route
  end

  # Returns the requested route name.
  def requested_route_name(url=nil)
    simple_route = requested_simple_route(url)
    return simple_route.name if simple_route
    nil
  end

  private

  def correct_url(url)
    url ||= request.path
    url = '/' if url.blank?
    url
  end

end
