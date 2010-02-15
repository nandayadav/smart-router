require 'route_segment'
module SmartRouter
  class RouteSegmentHash < Hash

    def add(args)
      if args[0].is_a?(RouteSegment)
        self[args[0].path] = args[0]
      else
        path = args[0]
        model = args[1]
        options = args[2] if args.length >= 3
        options ||= {}
        self[path] = RouteSegment.new(path, model, options)
      end
    end
    
    def add_segments_bulk(hash)
      hash.each{|key, value|
        args = [key]
        unless value.nil?
          if model = value['model']
            args << Object.const_get(model)
          end
          if value['options']
            args << nil unless model
            options = value['options']
            opts_symbolized = {}
            options.each{|key, val| opts_symbolized[key.intern] = val}
            args << opts_symbolized
          end
        end
        add(args)
      }
    end

  end
end
