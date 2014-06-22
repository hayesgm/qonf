require "qonf/version"

# A simple module to get information quickly out of config files
module Qonf
  @@cache = {} # note, we're caching the config in memory
  @@environments = Dir.glob("./config/environments/*.rb").map { |filename| File.basename(filename, ".rb") } # for extraction

  # Qonf.name -> Qonf.get(:qonf, [:name]) for quick short-hand
  def self.method_missing(method)
    self.get(:qonf, method)
  end

  def self.[](item)
    Figaro.env[item.to_s.upcase] || self.get(:qonf, item.to_s.downcase)
  end

  def self.get(config, route=[])
    route = [route] if route.is_a?(Symbol) || route.is_a?(String)
    raise "Invalid config" unless config =~ /^\w+$/
    config = config.to_sym

    if !Rails.env.development? && @@cache[config.to_sym] # don't cache in development

    else
      base_path = "#{Rails.root}/config/#{config}"

      formats = {
        yml: ->(f){ YAML.load(f) },
        json: ->(f){ JSON(f.read) }
      }

      formats.each do |ext,parser|
        if File.exists?("#{base_path}.#{ext}")
          cache = parser.call(File.open("#{base_path}.#{ext}"))
          raise "Invalid Qonf; must be hash" unless cache.is_a?(Hash)
          cache = cache.deep_symbolize_keys! # Let's do this as symbols
          cache.deep_merge!(cache.delete(Rails.env.to_sym)) if cache.has_key?(Rails.env.to_sym) # Now merge anything under current env
          @@environments.each { |env| cache.delete(env.to_sym) } # And remove any other env keys
          
          @@cache[config.to_sym] = cache # Store

          break # And exit
        end
      end
      
      raise "Unable to find config for #{config} in #{Rails.root}/config/*.{#{formats.keys.join(',')}}" if @@cache[config.to_sym].nil?
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
end
