# frozen_string_literal: true

module Sheetsy
  class Converter
    attr_reader :source, :destination, :options

    def initialize(source, destination, options = {})
      @source = source
      @destination = destination
      @options = options
    end

    def run
      debug "Files found: #{files.count}"

      progress_bar.progress = 0

      FileUtils.mkdir_p(destination) unless File.directory?(destination)

      files.each do |file|
        process_file(file)
        progress_bar.increment
      end

      puts "Conversion complete."
    end

    def overwrite?
      @overwrite ||= options[:overwrite]
    end

    def debug?
      @debug ||= options[:debug]
    end

    private

    def files
      @files ||= Dir.glob(File.join(source, "**/*.{xls,xlsx,csv}"))
    end

    def progress_bar
      @progress_bar ||= ProgressBar.create(title: "Files", total: files.count)
    end

    def debug(str)
      return unless debug?

      progress_bar.log str
    end

    def process_csv(file)
      debug "Processing as CSV"

      output_file_path = File.join(destination, "#{nameify(file)}.json")
      return if skip?(output_file_path)

      debug "File #{output_file_path}"

      data = CSV.read(file, headers: true).map(&:to_h)
      write_json(output_file_path, data)
      debug "Converted #{file} to #{output_file_path}\n\n"
    end

    def process_excel(file)
      debug "Processing as Excel"
      excel = Roo::Spreadsheet.open(file)

      excel.sheets.each do |sheet_name|
        output_file_path = File.join(destination, "#{nameify(file)}__sheet__#{nameify(sheet_name)}.json")
        return if skip?(output_file_path)

        debug "Sheet #{output_file_path}"

        sheet = excel.sheet(sheet_name)
        header_row = (output_file_path.include?("Synergy_Output__") ? 2 : 1)
        header = sheet.row(header_row)
        data = ((header_row + 1)..sheet.last_row).map { |i| Hash[header.zip(sheet.row(i))] }
        write_json(output_file_path, data)
        debug "Converted #{file} to #{output_file_path}\n\n"
      end
    end

    def process_file(file)
      debug "File: #{file}"

      if file.include?("~$")
        debug "Skipping #{file}\n\n"

        return
      end

      # base_name = File.basename(file, '.*')
      extension = File.extname(file)

      if extension == ".csv"
        process_csv(file)
      elsif [".xls", ".xlsx"].include?(extension)
        process_excel(file)
      else
        debug "Unsupported file format: #{file}"
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

      debug "Skipping #{file}"
      true
    end
  end
end
