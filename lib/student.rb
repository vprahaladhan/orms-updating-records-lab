require_relative "../config/environment.rb"

class Student
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = %{
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        grade TEXT);
      }

    DB[:conn].execute(sql);
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"
    DB[:conn].execute(sql);
  end

  def self.create(name, grade)
    student = self.new(name, grade);
    student.save
    student
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = self.new(row[0], row[1], row[2]);
    student.save
    student
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM students 
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new(row[0], row[1], row[2])
  end

  def save
    if (self.id) then 
      update
    else
      sql = %{
        INSERT OR REPLACE INTO students (name, grade) 
        VALUES (?, ?);
      }

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = %{
      UPDATE students 
      SET name = ?, grade = ? 
      WHERE id = ?;
    }

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end