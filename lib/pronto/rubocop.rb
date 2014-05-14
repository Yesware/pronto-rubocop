require 'pronto'
require 'rubocop'

module Pronto
  class Rubocop < Runner
    def initialize
      @inspector = ::Rubocop::FileInspector.new({})
      @config_store = ::Rubocop::ConfigStore.new

      if ((block = self.class.instance_configure_block))
        instance_eval &block
      end
    end

    def run(patches, _)
      return [] unless patches

      patches.select { |patch| patch.additions > 0 }
             .select { |patch| ruby_file?(patch.new_file_full_path) }
             .map { |patch| inspect(patch) }
             .flatten.compact
    end

    def inspect(patch)
      processed_source = ::Rubocop::SourceParser.parse_file(patch.new_file_full_path)
      offences = @inspector.send(:inspect_file, processed_source, @config_store).first

      offences.map do |offence|
        patch.added_lines.select { |line| line.new_lineno == offence.line }
                         .map { |line| new_message(offence, line) }
      end
    end

    def new_message(offence, line)
      path = line.patch.delta.new_file[:path]
      level = level(offence.severity.name)

      Message.new(path, line, level, offence.message)
    end

    def level(severity)
      case severity
      when :refactor, :convention
        :info
      when :warning, :error, :fatal
        severity
      end
    end

    def self.instance_configure(&block)
      @instance_configure_block = block
    end

    def self.instance_configure_block
      @instance_configure_block
    end

  end
end
