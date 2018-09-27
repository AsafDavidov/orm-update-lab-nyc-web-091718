require_relative "../config/environment.rb"
require 'pry'
class Student
  attr_reader :id
  attr_accessor :name,:grade

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name,grade,id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      sql = <<-SQL
        UPDATE students SET name = ?, grade = ? WHERE id = ?
      SQL
      DB[:conn].execute(sql,self.name,self.grade,self.id)
    else
      sql = <<-SQL
        INSERT INTO students (name,grade)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name,grade)
    new_student = self.new(name,grade)
    new_student.save
  end

  def self.new_from_db(array)
    new_student = self.new(array[1],array[2])
    new_student.save
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL
    array = DB[:conn].execute(sql,name)[0]
    Student.new(array[1],array[2],array[0])
  end

  def update
    self.save
  end
end
