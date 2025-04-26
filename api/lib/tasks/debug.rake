namespace :debug do
  desc 'Test file upload and URL generation'
  task test_file_upload: :environment do
    TestFileUploader.run
  end
end

# Helper class for the file upload test
class TestFileUploader
  def self.run
    new.run
  end

  def run
    setup_test_environment
    test_curriculum_service
    test_aws_upload
    display_aws_configuration
  end

  private

  def setup_test_environment
    # Find or create a test candidate
    user = User.first || User.create!(email: 'test@example.com', password: 'password', name: 'Test User')

    @candidate = Candidate.find_or_create_by!(
      name: 'Test Candidate',
      cpf: '12345678909',
      user: user
    )

    puts 'Initial candidate state:'
    puts "ID: #{@candidate.id}"
    puts "Curriculum: #{@candidate.curriculum.inspect}"
    puts "Curriculum URL: #{@candidate.curriculum_url.inspect}"

    # Create a test file
    @file_content = 'This is a test file content'
    @file_name = "test_#{Time.now.to_i}.txt"
  end

  def test_curriculum_service
    puts "\nTesting CurriculumService.save_curriculum_file..."
    result = CurriculumService.save_curriculum_file(@candidate, @file_content, @file_name)
    puts "Save result: #{result}"

    # Reload to get the updated attributes
    @candidate.reload

    puts "\nCandidate after file upload:"
    puts "ID: #{@candidate.id}"
    puts "Curriculum: #{@candidate.curriculum.inspect}"
    puts "Curriculum URL: #{@candidate.curriculum_url.inspect}"
  end

  def test_aws_upload
    puts "\nTesting direct AWS upload..."
    aws_result = AwsService.upload(@file_content, @candidate.curriculum)
    puts "AWS upload result: #{aws_result}"
  end

  def display_aws_configuration
    puts "\nAWS Configuration:"
    begin
      bucket_url = Rails.application.config.aws_bucket_url
      puts "AWS Bucket URL: #{bucket_url.inspect}"
    rescue StandardError => e
      puts "Error getting AWS bucket URL: #{e.message}"
    end

    puts "\nTrying to generate URL manually:"
    bucket_name = Rails.application.credentials.dig(:aws, :bucket) || "recruit-mate-app-#{Rails.env}"
    region = Rails.application.credentials.dig(:aws, :region) || 'us-east-1'
    manual_url = "https://#{bucket_name}.s3.#{region}.amazonaws.com/#{@candidate.curriculum}"
    puts "Manual URL: #{manual_url}"
  end
end
