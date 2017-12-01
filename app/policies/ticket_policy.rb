class TicketPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
  	# ** the || part of the query is evaluated from left to right
  	user.try(:admin?) || record.project.has_member?(user)
  end

  def create?
  	user.try(:admin?) || record.project.has_manager?(user) || record.project.has_editor?(user)
  end
end
