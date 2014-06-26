require 'spec_helper'
require 'json'

describe 'qonf examples' do

  it 'should configure correctly' do
    Qonf.configure do
      self.base_dir = "."
    end

    expect(Qonf::Config.base_dir).to eq(".")
    expect(Qonf::Config.environments).to eq([])
  end

  it 'should use Rails config if available' do
    begin
      Rails = double("rails", root: 'root', env: 'staging')
      Qonf::Config.load_defaults

      expect(Qonf::Config.base_dir).to eq("root/config")
      expect(Qonf::Config.environments).to eq([]) # TODO: Test "environments"
      expect(Qonf::Config.env).to eq("staging")
      expect(Qonf::Config.use_cache).to eq(true)
    ensure
      Object.send(:remove_const, 'Rails')
    end
  end

  it 'should read from correct file path' do
    Qonf.configure do
      self.base_dir = "./examples"
    end

    expect(Qonf.get(:simple, :name)).to eq("Bob Jones")
  end

  it 'should work with environments' do
    Qonf.configure do
      self.base_dir = "./examples"
      self.environments = ['test','production']
      self.env = 'production'
    end

    expect(Qonf.get(:environed, :name)).to eq("Steve")
  end

end