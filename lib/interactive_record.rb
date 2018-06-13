require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
  #-----SQLite3 that grabs the data that exists in the table as a hash
    sql = "PRAGMA table_info('#{table_name}')"
  #-----stores the sql quiry return as a variable hash
    table_info = DB[:conn].execute(sql)
  #-----empty array so that you can store the values of the name
    column_names = []
  #-----itterate over the hash and pull the values at the key 'name' out to use as your attr values
    table_info.each do |row|
      column_names << row["name"]
    end
  #------returns only value names as an array
    column_names
    end


  #---initialize method takes in a hash of value keys and creates the assingments through the each method for every key value in the options
  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  #----creates the table name from the self OJBECT rather than the previeous method on class.
  def table_name_for_insert
    self.class.table_name
  end
  #----creates a list of names for table insert that DOES NOT include id
  def col_names_for_insert
    col_names_insert = self.class.column_names.delete_if{|value| value == "id"}
    col_names_insert.join(", ")
  end
  #---this creates a values array from the read methods which are created by getting the column names from the table using the helper function column_names. The unless nil? is to check to make sure the column exists in the list. This can if you're not careful shift your data over a column.
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end
  #------this takes the above methods and interpolates them into a sql string, then sets the id of the object = to the id Primary Key from the database
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name)
  end

#----finds any item based on a key value hash as argument
#----Note: sql interprolation doesn't mix with the ? variable statment. So all one or all the other
  def self.find_by(hash)
    hash_array = hash.shift
    column_name = hash_array[0].to_s
    column_value = hash_array[1]
    sql = "SELECT * FROM #{table_name} WHERE #{column_name} = '#{column_value}' "
    DB[:conn].execute(sql)
  end

end
