class EbayClient::Configuration
  attr_accessor :version, :siteid, :routing, :url, :appid, :devid, :certid, :token, :warning_level, :error_language

  def initialize presets
    presets.each do |key, val|
      instance_variable_set "@#{key}", val
    end
  end

  def wsdl_file
    @wsdl_file ||= File.expand_path "../../../vendor/ebay/#{version}.wsdl", __FILE__
  end

  def preload?
    !!@preload
  end

  class << self
    def load file
      defaults = load_defaults
      configs = YAML.load_file file

      configs.each_pair do |env, presets|
        env_defaults = defaults[env] || {}
        presets = presets || {}

        configs[env] = new env_defaults.merge(presets)
      end

      configs
    end

    protected
    def load_defaults
      YAML.load_file defaults_file
    end

    def defaults_file
      File.expand_path '../../../config/defaults.yml', __FILE__
    end
  end
end
