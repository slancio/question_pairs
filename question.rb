require_relative 'questions_database'

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
