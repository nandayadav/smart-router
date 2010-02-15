module SmartRouter
  class RouteSegment

    attr_reader :path, :model, :options

    def initialize(path, model=nil, options={})
      @path = path.to_s
      @model = model
      @options = options
    end

    def controller
      value = model.name.underscore if model
      value.to_s
    end

    def to_s
      "path:#{path}, model:#{controller}"
    end

  end
end
