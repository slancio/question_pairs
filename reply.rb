require_relative 'questions_database'
require_relative 'save'

class Reply
  include Save

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
