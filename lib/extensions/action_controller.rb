require File.join(File.dirname(__FILE__), '/../route_segment_hash.rb')
module ActionController
  module Routing

    class << self
      @url_keypair_delimiter = '_'
      attr_reader :url_keypair_delimiter
    end

    def self.add_separator(separator)
      SEPARATORS <<  separator unless SEPARATORS.include?(separator)
    end

    def self.url_keypair_delimiter=(value)
      @url_keypair_delimiter = value
      add_separator(value)
    end

    # Class that represents a simple route. NOTE: Be sure to init_segments on
    # ActionController::Routing::Routes before instantiating a SimpleRoute.
    class SimpleRoute
      attr_reader :value, :name, :path, :segment, :segments

      def initialize(path)
        @segments = []
        @value = path

        delim = ActionController::Routing.url_keypair_delimiter
        segments = ActionController::Routing::Routes.segments
        segment = nil
        parts = path.split('/')
        parts = ['home'] if path == '/' # code to support the index page
        segment_paths = []
        pre_path = []
        pos = 1

        parts.each do |part|
          segment = segments[part]
          segment = segments['/'] if path == '/' # code to support the index page
          @segments << segment
          segment_paths << String.new(part)

          if pos == parts.length
            pre_path << part
          else
            val = part
            if !segment.model.nil? || segment.options[:genesis]
              item_name = segment.model.name.underscore if segment.model
              item_name ||= segment.path.underscore
              val << "#{delim}:#{item_name}_id"
            end
            pre_path << val
          end

          pos += 1
        end

        new_path = pre_path.join('/')
        route_name = segment_paths.join('_').gsub(/-/, '_')


        @name = route_name
        #@segment = segments[parts[-1]]
        @segment = segment

        if segment.model || segment.options[:genesis]
          @path = "#{new_path}#{delim}:id"
        else
          @path = new_path
        end

        # code to support the index page
        # this allows us to apply the CMS magic to the index page
        if path == '/'
          @name = 'home'
          @segment = segments['/']
          @path = path
        end
      end
    end

    class SimpleRouteCollection < Array
      attr_reader :verticals, :by_path, :by_name

      def initialize
        @by_path = {}
        @by_name = {}
      end

      # Instantiates and appends a new simple route to the collection.
      def add(path, vertical=nil)
        sr = path
        sr = SimpleRoute.new(path) unless path.is_a?(SimpleRoute)
        self << sr
        @by_path[path] = sr
        @by_name[sr.name] = sr
        add_to_vertical(sr, vertical) if vertical
      end
      
      def add_simple_bulk(path_hash)
        path_hash.each{|vertical, paths|
          paths.each_key{|path|
            add(path, vertical.intern)
          }
        }
      end

      #--Deprecated------------------------------------------------------#
      def add_gaos(path)
        add(path, :gaos)
      end

      def add_online_education(path)
        add(path, :online_education)
      end

      def add_school_online(path)
        add(path, :school_online)
      end

      def add_school_campus(path)
        add(path, :school_campus)
      end

      def add_geo_targeted(path)
        add(path, :geo_targeted)
      end

      def add_state(path)
        add(path, :state)
      end

      def add_misc(path)
        add(path, :misc)
      end
      #-------End of Deprecated methods----------------------------------#
      # Gets all the route names associated with the passed vertical path.
      def get_names(vertical)
        @names ||= {}
        @names[vertical] = [] unless @names.has_key?(vertical)
        return @names[vertical] if @names[vertical].length > 0

        verticals[vertical].each do |simple_route|
          @names[vertical] << simple_route.name
        end
        @names[vertical]
      end

      private

      def add_to_vertical(simple_route, vertical)
        @verticals ||= {}
        @verticals[vertical] ||= []
        @verticals[vertical] << simple_route
      end
    end

    class RouteSet
      attr_reader :segments
      attr_reader :simple_routes
      attr_reader :static_routes

      def add_segments_from_config(config)
        s = config['segments']
        @segments = RouteSegmentHash.new
        #puts s.inspect
        @segments.add_segments_bulk(s)
      end
      
      def add_routes_from_config(config)
        simple_routes = config['simple_routes']
        static_routes = config['static_routes']
        @static_routes = static_routes.keys
        @simple_routes = SimpleRouteCollection.new
        @simple_routes.add_simple_bulk(simple_routes)
      end
        
      def init_segments
        @segments = RouteSegmentHash.new
        yield @segments
      end

      def init_simple_routes
        @simple_routes = SimpleRouteCollection.new
        yield @simple_routes
      end

      def init_static_routes
        @static_routes = []
        yield @static_routes
      end

    end
  end


end
