require 'secret_garden/secret'

module SecretGarden

  class Map

    attr_accessor :root

    def initialize(root: Dir.pwd, env: nil)
      self.root = root
    end

    def defined?(name)
      entries.key?(name)
    end

    def [](name)
      entries[name]
    end

    def secretfile_path
      @secretfile_path ||= File.join(root, 'Secretfile')
    end

    def entries
      @entries ||= File.readlines(secretfile_path).
        map(&:strip).
        reject { |l| l =~ /^#/ }.
        map do |l|
          name, path, property = parse_secret l
          Secret.new name, path, property
        end.
        inject({}) do |hsh, secret|
          hsh.merge secret.name => secret
        end
    end

    def parse_secret(line)
      name, path, property = line.scan(/([^\s]+)\s+([^:]+)(:.*)?/).first
      path.gsub! /@ENV@/, SecretGarden.env
      [name, path, property.to_s[1..-1]]
    end
  end

end
