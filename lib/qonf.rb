require "qonf/version"

# A simple module to get information quickly out of config files
module Qonf
  @@cache = {} # note, we're caching the config in memory

  module Config
    @@environments = []
    @@base_dir = nil
    @@env = nil
    @@use_cache = true

    [:environments,:env,:base_dir,:use_cache].each do |var|
      self.class_eval("def self.#{var}=(value); @@#{var} = value; end")
      self.class_eval("def self.#{var}; @@#{var}; end")
    end

    def self.load_defaults
      if defined?(Rails) # Rails defaults
        self.environments = Dir.glob("#{Rails.root}/config/environments/*.rb").map { |filename| File.basename(filename, ".rb") } # for extraction
        self.base_dir = "#{Rails.root}/config"
        self.env = Rails.env
        self.use_cache = Rails.env != "development"
      end
    end

    load_defaults # load defaults by default
  end

  def self.configure(&block)
    Qonf::Config.instance_eval(&block)
  end

  # Qonf.name -> Qonf.get(:qonf, [:name]) for quick short-hand
  def self.method_missing(method)
    self.get(:qonf, method)
  end

  def self.[](item)
    # Use Figaro is defined, otherwise ENV, otherwise try to get from `config/qonf.{json,yml}`
    if defined?(Figaro) && Figaro.env[item.to_s.upcase]
      return Figaro.env[item.to_s.upcase]
    elsif ENV[item.to_s.upcase]
      ENV[item.to_s.upcase]
    end

    self.get(:qonf, item.to_s.downcase)
  end

  def self.get(config, route=[])
    route = [route] if route.is_a?(Symbol) || route.is_a?(String)
    raise "Invalid config" unless config =~ /^\w+$/
    config = config.to_sym

    # Do we just use cached version?
    if !Qonf::Config.use_cache || !@@cache.has_key?(config.to_sym)
      base_path = "#{Qonf::Config.base_dir}/#{config}"

      formats={}

      formats[:json] = ->(f){ JSON(f.read) } if defined?(JSON)
      formats[:yml] = ->(f){ YAML.load(f) } if defined?(YAML)
      formats[:yaml] = ->(f){ YAML.load(f) } if defined?(YAML)
      
      raise "Must include JSON or YAML parser" if formats.keys.count == 0

      formats.each do |ext,parser|
        if File.exists?("#{base_path}.#{ext}")
          cache = parser.call(File.open("#{base_path}.#{ext}"))
          raise "Invalid Qonf; must be hash" unless cache.is_a?(Hash)
          cache = symbolize_keys(cache) # Let's do this as symbols

          # Do we use env key? (e.g. "development")
          if Qonf::Config.env
            # TODO: This should be a deep merge?
            cache.merge!(cache.delete(Qonf::Config.env.to_sym)) if cache.has_key?(Qonf::Config.env.to_sym) # Now merge anything under current env
          end

          # Remove any other envs (e.g. "staging")
          Qonf::Config.environments.each do |environment|
            cache.delete(environment.to_sym)
          end
          
          @@cache[config.to_sym] = cache # Store

          break # And exit
        end
      end
      
      raise "Unable to find config for #{config} in #{base_path}.{#{formats.keys.join(',')}}" if @@cache[config.to_sym].nil?
    end
    
    return get_route(@@cache[config.to_sym], route)
  end

  def self.reset!
    @@cache = {} # Clear the cache
  end 

  private

    def self.get_route(hash, route)
      return hash if route.nil? || route.length == 0
      raise "Unable to get route (#{route}) in Qonf, please check config file" unless hash.is_a?(Hash)
      # TODO: Do we want to accept _ for -?
      return Qonf.get_route(hash[route.shift.to_sym], route) # Recursive, yo!
    end

    def self.symbolize_keys(hash)
      hash.inject({}) do |result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      end
    end
end
