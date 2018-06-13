require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

#---This creates the attr_accessor methods every time the class is run rather than store them staticly. This is why it is also not wrapped in a self method so that it is auto called.
  self.column_names.each do |column_name|
    attr_accessor column_name.to_sym
  end


end
