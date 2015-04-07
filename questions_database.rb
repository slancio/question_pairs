require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')

    self.results_as_hash = true

    self.type_translation = true
  end

end


class User
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if results.empty?
    User.new(results.first)
  end

  def self.find_by_name(fname, lname)
    results = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil if results.empty?
    results.map { |row| User.new(row) }
  end

  attr_accessor :fname, :lname, :id

  def initialize(options = {})
    @id = options['id']
    @fname, @lname = options['fname'], options['lname']
  end

  def authored_questions
    Question::find_by_author_id(id)
  end

  def authored_replies
    Reply::find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow::followed_questions_for_user_id(id)
  end
end


class Question
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil if results.empty?
    Question.new(results.first)
  end

  def self.find_by_author_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    return nil if results.empty?
    results.map { |row| Question.new(row) }
  end

  def self.most_followed(n)
    QuestionFollow::most_followed_questions(n)
  end

  attr_accessor :id, :title, :body, :user_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    User::find_by_id(user_id)
  end

  def replies
    Reply::find_by_question_id(id)
  end

  def followers
    QuestionFollow::followers_for_question_id(id)
  end

end


class QuestionFollow
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    return nil if results.empty?
    QuestionFollow.new(results.first)
  end

  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows AS q_f
      JOIN
        users ON q_f.user_id = users.id
      WHERE
        q_f.question_id = ?
    SQL
    return nil if results.empty?
    results.map { |row| User.new(row) }
  end

  def self.followed_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows AS q_f
      JOIN
        questions ON q_f.question_id = questions.id
      WHERE
        q_f.user_id = ?
    SQL
    return nil if results.empty?
    results.map { |row| Question.new(row) }
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN
        questions ON question_follows.question_id = questions.id
      GROUP BY
        question_follows.question_id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL
    return nil if results.empty?
    results.map { |row| Question.new(row) }
  end

  attr_accessor :id, :question_id, :user_id

  def initialize(options = {})
    @id = options['id']
    @question_id, @user_id = options['question_id'], options['user_id']
  end

end


class Reply
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if results.empty?
    Reply.new(results.first)
  end

  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil if results.empty?
    results.map { |row| Reply.new(row) }
  end

  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil if results.empty?
    results.map { |row| Reply.new(row) }
  end

  attr_accessor :id, :body, :question_id, :user_id, :parent_id

  def initialize(options = {})
    @id = options['id']
    @body = options['body']
    @question_id, @user_id = options['question_id'], options['user_id']
    @parent_id = options['parent_id']
  end

  def author
    User::find_by_id(user_id)
  end

  def question
    Question::find_by_id(question_id)
  end

  def parent_reply
    Reply::find_by_id(parent_id)
  end

  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    return nil if results.empty?
    results.map { |row| Reply.new(row) }
  end

end


class QuestionLike
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    return nil if results.empty?
    QuestionLike.new(results.first)
  end

  attr_accessor :id, :question_id, :user_id

  def initialize(options = {})
    @id = options['id']
    @question_id, @user_id = options['question_id'], options['user_id']
  end

end
