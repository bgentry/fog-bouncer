require "fog"
require "fog/bouncer/group"
require "fog/bouncer/protocols"
require "fog/bouncer/security"
require "fog/bouncer/sources"
require "fog/bouncer/version"

require "fog/bouncer/ip_permissions"
require "fog/bouncer/group_manager"
require "fog/bouncer/source_manager"

require "scrolls"

module Fog
  module Bouncer
    def self.aws_account_id
      ENV['AWS_ACCOUNT_ID']
    end

    def self.doorlists
      @doorlists ||= {}
    end

    def self.fog
      @fog ||= Fog::Compute.new(
        :provider => "AWS",
        :region => (ENV['PROVIDER_REGION'] || 'us-east-1'),
        :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
        :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
      )
    end

    def self.log(data, &block)
      log! unless logging?
      Scrolls.log({ 'fog-bouncer' => true, 'pretending' => pretending? }.merge(data), &block)
    end

    def self.log!
      Scrolls::Log.start(logger)
      @logging = true
    end

    def self.logger
      @logger ||= STDOUT
    end

    def self.logger=(logger)
      @logger = logger
    end

    def self.logging?
      @logging ||= false
    end

    def self.load(file)
      if file && File.exists?(file)
        Fog::Bouncer.log(load: true, file: file) do
          instance_eval(File.read(file))
        end
      end
    end

    def self.pretend(&block)
      if block_given?
        @pretend = true
        yield
        @pretend = false
      else
        @pretend ||= false
      end
    end

    def self.pretend=(value)
      @pretend = value
    end

    def self.pretend!
      @pretend = true
    end

    def self.pretending?
      !!pretend
    end

    def self.reset
      @doorlists = {}
    end

    def self.security(name, &block)
      Fog::Bouncer.log(security: true, name: name) do
        doorlists[name] = Fog::Bouncer::Security.new(name, &block)
      end
    end
  end
end
