# frozen_string_literal: true

# Abstract superclass for Servers and VM objects
class Machine < ApplicationRecord
  self.abstract_class = true

  def commit_message(git_writer)
    if git_writer.added?
      'Add ' + name
    elsif git_writer.updated?
      'Update ' + name
    else
      ''
    end
  end
end