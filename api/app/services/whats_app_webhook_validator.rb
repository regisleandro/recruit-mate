class WhatsAppWebhookValidator
  def self.valid_format?(data)
    new(data).valid_format?
  end

  def initialize(data)
    @data = data
  end

  def valid_format?
    required_root_fields? && valid_entry_structure?
  end

  private

  attr_reader :data

  def required_root_fields?
    data.is_a?(Hash) && data[:object] == 'whatsapp_business_account'
  end

  def valid_entry_structure?
    return false unless data[:entry].is_a?(Array) && data[:entry].any?

    entry = data[:entry].first
    valid_entry?(entry) && valid_change_structure?(entry)
  end

  def valid_entry?(entry)
    entry.is_a?(Hash) &&
      entry[:id].present? &&
      entry[:changes].is_a?(Array) &&
      entry[:changes].any?
  end

  def valid_change_structure?(entry)
    return false unless entry[:changes].is_a?(Array) && entry[:changes].any?

    change = entry[:changes].first
    valid_change = valid_change?(change)
    return false unless valid_change

    # Additional check for messages field
    return true unless change[:field] == 'messages'

    valid_messages_field?(change)
  end

  def valid_change?(change)
    change.is_a?(Hash) &&
      change[:field].present? &&
      change[:value].is_a?(Hash)
  end

  def valid_messages_field?(change)
    value = change[:value]
    value[:messaging_product] == 'whatsapp' &&
      value[:metadata].is_a?(Hash) &&
      value[:metadata][:phone_number_id].present?
  end
end
