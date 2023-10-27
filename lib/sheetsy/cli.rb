# frozen_string_literal: true

require "thor"

module Sheetsy
  class CLI < Thor
    desc "convert", "Convert sheets to JSON"
    option :source, type: :string, aliases: :s
    option :destination, type: :string, aliases: :d
    option :override, type: :boolean, aliases: :o, default: false
    def convert
      source = if options[:source]
                 options[:source]
               elsif ENV.key?("SOURCE")
                 ENV.fetch("SOURCE")
               else
                 get_input("Source Directory", Dir.pwd)
               end

      destination = if options[:destination]
                      options[:destination]
                    elsif ENV.key?("DESTINATION")
                      ENV.fetch("DESTINATION")
                    else
                      default_source_folders = source.split("/")
                      default_output_folder = "#{default_source_folders.pop}_json"
                      get_input("Output Directory", File.join(*default_source_folders, default_output_folder))
                    end

      overwrite = if options[:overwrite]
                    options[:overwrite]
                  elsif ENV.key?("OVERWRITE")
                    ENV.fetch("OVERWRITE")&.downcase == "y"
                  else
                    get_input("Overwrite Y/n? (n): ", "n").downcase == "y"
                  end

      Sheetsy::Converter.new(source, destination, overwrite).run
    end

    private

    def get_input(text, default)
      print "#{text} (#{default}): "
      input = STDIN.gets.chomp
      (input.empty? ? default : input)
    end
  end
end