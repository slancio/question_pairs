require_relative 'questions_database'

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
