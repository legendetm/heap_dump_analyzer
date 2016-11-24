module WhereExists
  def where_exists(subquery)
    spawn.where_exists!(subquery)
  end

  def where_exists!(subquery)
    self.where_clause += subquery_exists_where_clause(subquery)
    self
  end

  def where_not_exists(subquery)
    spawn.where_not_exists!(subquery)
  end

  def where_not_exists!(subquery)
    self.where_clause += subquery_exists_where_clause(subquery).invert
    self
  end

  private

  def subquery_exists_where_clause(subquery)
    ActiveRecord::Relation::WhereClause.new([subquery.exists], subquery.bound_attributes)
  end
end

ActiveRecord::Relation.send(:include, WhereExists)
