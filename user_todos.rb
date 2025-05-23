#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

class UserTodosSelector
  BASE_URL = 'https://jsonplaceholder.typicode.com'.freeze

  def initialize
    @users = fetch_users
  end

  def run
    return puts "No users found" if @users.empty?

    display_users
    user_id = get_user_selection
    return puts "Invalid selection" unless user_id

    todos = fetch_user_todos(user_id)
    display_todos(todos, selected_user(user_id))
  end

  private

  def fetch_users
    response = make_request('/users')
    return [] unless response

    JSON.parse(response.body)
  rescue JSON::ParserError
    puts "Error parsing users data"
    []
  end

  def fetch_user_todos(user_id)
    response = make_request("/todos?userId=#{user_id}")
    return [] unless response

    JSON.parse(response.body)
  rescue JSON::ParserError
    puts "Error parsing todos data"
    []
  end

  def make_request(endpoint)
    uri = URI("#{BASE_URL}#{endpoint}")
    response = Net::HTTP.get_response(uri)
    
    unless response.is_a?(Net::HTTPSuccess)
      puts "Error fetching data from #{endpoint}: #{response.code}"
      return nil
    end

    response
  rescue StandardError => e
    puts "Network error: #{e.message}"
    nil
  end

  def display_users
    puts "\nAvailable users:"
    puts "=================="
    @users.each_with_index do |user, index|
      puts "#{index + 1}. #{user['name']} (#{user['username']}) - #{user['email']}"
    end
    puts
  end

  def get_user_selection
    print "Select a user (1-#{@users.length}): "
    input = gets.chomp.to_i
    
    return nil if input < 1 || input > @users.length
    
    @users[input - 1]['id']
  end

  def selected_user(user_id)
    @users.find { |user| user['id'] == user_id }
  end

  def display_todos(todos, user)
    puts "\nTodos for #{user['name']}:"
    puts "=" * 40
    
    if todos.empty?
      puts "No todos found for this user."
      return
    end

    completed_count = todos.count { |todo| todo['completed'] }
    pending_count = todos.length - completed_count

    puts "Total: #{todos.length} todos (#{completed_count} completed, #{pending_count} pending)\n\n"

    todos.each do |todo|
      status = todo['completed'] ? '✓' : '○'
      puts "#{status} #{todo['title']}"
    end
  end
end

UserTodosSelector.new.run