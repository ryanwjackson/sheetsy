# frozen_string_literal: true

module Sheetsy
  class Reader
    attr_reader :source, :options, :data

    def initialize(source, options = {})
      @source = source
      @options = options
    end

    def run
      debug "Files found: #{files.count}"

      progress_bar.progress = 0
      ret = {}

      files.each do |file|
        ret[file] = process_file(file)
        progress_bar.increment
      end

      @data = ret
    end

    def overwrite?
      @overwrite ||= options[:overwrite]
    end

    def debug?
      @debug ||= options[:debug]
    end

    private

    def files
      @files ||= Dir.glob(File.join(source, "**/*.{json}"))
    end

    def progress_bar
      @progress_bar ||= ProgressBar.create(title: "Files", total: files.count)
    end

    def debug(str)
      return unless debug?

      progress_bar.log str
    end

    def process_file(file)
      debug "File: #{file}"

      JSON.parse(File.read(file))
    end

    def progress_bar
      @progress_bar ||= ProgressBar.create(title: "Files", total: files.count)
    end
  end
end
