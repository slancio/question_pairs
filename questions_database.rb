require_relative 'user'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'

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
