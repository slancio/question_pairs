require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')

    self.result_as_hash = true

    self.type_translation = true
  end

end


class User
  def self.find_by_id
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if results.empty?
    User.new(results)
  end

  attr_accessor :fname, :lname, :id

  def initialize(options = {})
    @id = options['id']
    @fname, @lname = options['fname'], options['lname']
  end

end


class Question
  def self.find_by_id
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil if results.empty?
    Question.new(results)
  end

  attr_accessor :id, :title, :body, :user_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

end


class QuestionFollow
  def self.find_by_id
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    return nil if results.empty?
    QuestionFollow.new(results)
  end

  attr_accessor :id, :question_id, :user_id

  def initialize(options = {})
    @id = options['id']
    @question_id, @user_id = options['question_id'], options['user_id']
  end

end


class Reply
  def self.find_by_id
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if results.empty?
    Reply.new(results)
  end

  attr_accessor :id, :body, :question_id, :user_id, :parent_id

  def initialize(options = {})
    @id = options['id']
    @body = options['body']
    @question_id, @user_id = options['question_id'], options['user_id']
    @parent_id = options['parent_id']
  end
end


class QuestionLike
  def self.find_by_id
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    return nil if results.empty?
    QuestionLike.new(results)
  end

  attr_accessor :id, :question_id, :user_id

  def initialize(options = {})
    @id = options['id']
    @question_id, @user_id = options['question_id'], options['user_id']
  end

end
