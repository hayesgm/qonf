module Qonf
  class Railtie < Rails::Railtie
    initializer "Initialize Qonf" do
      Qonf::Config.load_defaults # load defaults by default
    end
  end
end