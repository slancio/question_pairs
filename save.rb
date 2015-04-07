module Save
  def self.save
    table = self.class.to_s.downcase.pluralize
    ivar_names = build_ivar_names(self.instance_variables[1..-1])
    ivar_values = ivar_names.map { |name| self.send name }

    if self.id.nil?
      query_string = <<-SQL
        INSERT INTO
          #{table} (#{ivar_names.join(', ')})
        VALUES
          (#{ivar_names.map { '?' }.join(', ')})
      SQL

      QuestionsDatabase.instance.execute(query_string, *ivar_values)
      self.id = QuestionsDatabase.instance.last_insert_row_id
    else
      query_string = <<-SQL
        UPDATE #{table}
        SET #{ivar_names.join(' = ?,')}#{' = ?'}
        WHERE id = #{self.id}
      SQL

      QuestionsDatabase.instance.execute(query_string, *ivar_values)
    end

  end

  def build_ivar_names(ivars)
    ivars.map { |var| var.to_s[1..-1] }
  end

end
