# frozen_string_literal: true

require "json"
require "roo"
require "csv"
# require "pry"
require "ruby-progressbar"

require_relative "sheetsy/version"
require_relative "sheetsy/converter"
require_relative "sheetsy/reader"
require_relative "sheetsy/cli"

module Sheetsy
  def self.run(*args)
    Converter.new(*args).run
  end
end
