class UserState
  @state = {}

  def self.set(chat_id, value)
    @state[chat_id] = value
  end

  def self.get(chat_id)
    @state[chat_id]
  end

  def self.clear(chat_id)
    @state.delete(chat_id)
  end
end