# frozen_string_literal: true

module Sheetsy
  class JSONFile
    attr_reader :file_path, :data

    def initialize(file_path)
      @file_path = file_path
    end

    def data
      @data ||= JSON.parse(File.read(file_path))
    end

    def inspect
      to_s
    end

    def to_s
      "#<#{self.class}:#{file_path}>"
    end
  end
end
