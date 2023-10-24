# frozen_string_literal: true

require "json"
require "roo"
require "csv"
require "pry"

require_relative "sheetsy/version"

module Sheetsy
  class Error < StandardError; end

  def self.get_input(text, default)
    print "#{text} (#{default}): "
    input = gets.chomp
    (input.empty? ? default : input)
  end

  def self.write_json(file_name, data)
    File.open(file_name, "w") do |f|
      f.write(JSON.pretty_generate(data))
    end
  end

  def self.nameify(file)
    file.gsub(@source_directory + "/", "").gsub("/", "__").gsub(" ", "_").gsub(File.extname(file), "")
  end

  def self.skip?(file)
    return false if @overwrite || !File.exist?(file)

    puts "Skipping #{file}"
    true
  end

  def self.run
    @source_directory = if ENV.key?("SOURCE_DIR")
                         ENV.fetch("SOURCE_DIR")
                       else
                         get_input("Source Directory", __dir__)
                       end

    @output_directory = if ENV.key?("OUTPUT_DIR")
                         ENV.fetch("OUTPUT_DIR")
                       else
                       default_source_folders = input_directory.split('/')
                       default_output_folder = "#{source_folders.pop}_json"
                         get_input("Output Directory", File.join(*default_source_folders, default_output_folder))
                       end

    @overwrite = if ENV.key?("OVERWRITE")
                  ENV.fetch("OVERWRITE")&.downcase == "y"
                else
                  get_input("Overwrite Y/n? (n): ", "n").downcase == "y"
                end

    convert_files(@source_directory, @output_directory, @overwrite)
  end

  def self.convert_files(input_directory, output_directory, overwrite)
    Dir.glob(File.join(input_directory, "**/*.{xls,xlsx,csv}")).each do |file|
      puts "File: #{file}"

      # base_name = File.basename(file, '.*')
      output_name = nameify(file)
      extension = File.extname(file)

      if file.include?("~$")
        puts "Skipping #{file}\n\n"

        next
      end

      if extension == ".csv"
        puts "Processing as CSV"

        output_file_path = File.join(output_directory, "#{output_name}.json")
        next if skip?(output_file_path)

        puts "File #{output_file_path}"

        data = CSV.read(file, headers: true).map(&:to_h)
        write_json(output_file_path, data)
        puts "Converted #{file} to #{output_file_path}\n\n"
      elsif [".xls", ".xlsx"].include?(extension)
        puts "Processing as Excel"
        excel = Roo::Spreadsheet.open(file)

        excel.sheets.each do |sheet_name|
          output_file_path = File.join(output_directory, "#{output_name}__sheet__#{nameify(sheet_name)}.json")
          next if skip?(output_file_path)

          puts "Sheet #{output_file_path}"

          sheet = excel.sheet(sheet_name)
          header_row = (output_file_path.include?("Synergy_Output__") ? 2 : 1)
          header = sheet.row(header_row)
          data = ((header_row + 1)..sheet.last_row).map { |i| Hash[header.zip(sheet.row(i))] }
          write_json(output_file_path, data)
          puts "Converted #{file} to #{output_file_path}\n\n"
        end
      else
        puts "Unsupported file format: #{file}"
        next
      end
    end
  end
end
