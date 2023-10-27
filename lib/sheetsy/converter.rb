# frozen_string_literal: true

module Sheetsy
  class Converter
    attr_reader :source, :destination, :overwrite

    def initialize(source, destination, overwrite = false)
      @source = source
      @destination = destination
      @overwrite = overwrite
    end

    def run
      files = Dir.glob(File.join(source, "**/*.{xls,xlsx,csv}"))
      puts "Files found: #{files.count}"

      FileUtils.mkdir_p(destination) unless File.directory?(destination)

      files.each do |file|
        process_file(file)
      end
    end

    def overwrite?
      overwrite == true
    end

    private

    def process_csv(file)
      puts "Processing as CSV"

      output_file_path = File.join(destination, "#{nameify(file)}.json")
      return if skip?(output_file_path)

      puts "File #{output_file_path}"

      data = CSV.read(file, headers: true).map(&:to_h)
      write_json(output_file_path, data)
      puts "Converted #{file} to #{output_file_path}\n\n"
    end

    def process_excel(file)
      puts "Processing as Excel"
      excel = Roo::Spreadsheet.open(file)

      excel.sheets.each do |sheet_name|
        output_file_path = File.join(destination, "#{nameify(file)}__sheet__#{nameify(sheet_name)}.json")
        return if skip?(output_file_path)

        puts "Sheet #{output_file_path}"

        sheet = excel.sheet(sheet_name)
        header_row = (output_file_path.include?("Synergy_Output__") ? 2 : 1)
        header = sheet.row(header_row)
        data = ((header_row + 1)..sheet.last_row).map { |i| Hash[header.zip(sheet.row(i))] }
        write_json(output_file_path, data)
        puts "Converted #{file} to #{output_file_path}\n\n"
      end
    end

    def process_file(file)
      puts "File: #{file}"

      if file.include?("~$")
        puts "Skipping #{file}\n\n"

        return
      end

      # base_name = File.basename(file, '.*')
      extension = File.extname(file)

      if extension == ".csv"
        process_csv(file)
      elsif [".xls", ".xlsx"].include?(extension)
        process_excel(file)
      else
        puts "Unsupported file format: #{file}"
        return
      end
    end

    def write_json(file_name, data)
      File.open(file_name, "w") do |f|
        f.write(JSON.pretty_generate(data))
      end
    end

    def nameify(file)
      file.gsub(source + "/", "").gsub("/", "__").gsub(" ", "_").gsub(File.extname(file), "")
    end

    def skip?(file)
      return false if overwrite?
      return false unless File.exist?(file)

      puts "Skipping #{file}"
      true
    end
  end
end
