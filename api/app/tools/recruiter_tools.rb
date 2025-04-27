module RecruiterTools
  TOOLS = [
    {
      type: 'function',
      name: 'list_oppened_positions',
      description: 'List all open positions in the database'
    },
    {
      type: 'function',
      name: 'get_job',
      description: 'Returns a job from database, based on its ID.
                    The user will query the bot for the title or description previous to this call',
      parameters: {
        type: 'object',
        properties: {
          id: { type: 'integer', description: 'id to search for' }
        },
        required: ['id']
      }
    },
    {
      type: 'function',
      name: 'job_search',
      description: 'Search for jobs in the database',
      parameters: {
        type: 'object',
        properties: {
          query: { type: 'string', description: 'Query to search for' }
        },
        required: ['query']
      }
    }
  ].freeze

  def get_job(id:)
    job = scope
          .find(id)
    job.to_json
  end

  def list_oppened_positions
    jobs = scope
           .select(:id, :title)
           .to_json
    "Summarize this jobs: #{jobs} - extract the titles from the jobs and display them in a list"
  end

  def job_search(query:)
    jobs = scope
           .where('title ILIKE ?', "%#{query}%")
           .to_json
    "Summarize this jobs: #{jobs} - extract the titles from the jobs and display them in a list"
  end

  def scope
    Job
      .open
      .select(:id, :title, :description, :benefits, :start_time, :end_time, :interval_time)
  end
end
