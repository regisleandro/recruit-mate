# frozen_string_literal: true

class OpenaiService
  include HTTParty
  include RecruiterTools

  base_uri 'https://api.openai.com/v1'
  
  def initialize(key)
    @openai_key = key
    history << {
      role: 'system',
      content: "
        You are a helpful assistant. 
        You must detect the language of the user's message based on their words.
        Always respond in the same detected language.
        If the user writes anything in Portuguese, you must respond strictly in Portuguese.
        If the user writes anything in English, respond in English.
        Never assume English as default if the input is short.
        Be strict: even if the user writes just one word, always respect their language.
        Returns the response in markdown format for whatsapp.
        You will answer all the questions first, looking at the history, and then you will call the tools if needed.
        You will not call the tools if the user is asking for information that is already in the history.
      " 
    }
  end

  def chat(message:)
    history << { role: 'user', content: message }
    response = model_response
    process(response: response)

    history.last
  end

  private

  def history
    @history ||= []
  end

  def model_response
    self.class.post(
      '/responses',
      headers: {
        'Authorization' => "Bearer #{@openai_key}",
        'Content-Type' => 'application/json'
      },
      body: {
        model: 'gpt-4o-mini',
        input: history,
        tools: RecruiterTools::TOOLS,
        tool_choice: 'auto',
        temperature: 0.2
      }.to_json
    ).parsed_response
  end

  def process(response:)
    outputs = response.dig('output')
    outputs.each do |output|
      if output.dig('type') == 'message'
        history << { role: 'assistant', content: output.dig('content', 0, 'text') }
      elsif output.dig('type') == 'function_call'
        handle_tool_call(tool_call: output)
        response = model_response
        process(response: response)
      end
    end
  end

  def handle_tool_call(tool_call:)
    tool_name = tool_call.dig('name')
    parameters = JSON.parse(tool_call.dig('arguments'), symbolize_names: true)

    content = parameters.empty? ? send(tool_name) : send(tool_name, **parameters)

    history << {
      role: 'assistant',
      content: content,
    }
    
  rescue NoMethodError
    error_message = "Unknown tool called: #{tool_name}"
    history << {
      role: 'assistant',
      content: { error: error_message },
    }
    error_message
  end
end
