namespace :rubocop do
  desc 'Run RuboCop with autocorrect'
  task autocorrect: :environment do
    sh 'bundle exec rubocop -A || true'
  end

  desc 'Run RuboCop with safe autocorrect (does not change code behavior)'
  task safe_autocorrect: :environment do
    sh 'bundle exec rubocop -a || true'
  end

  desc 'Generate a RuboCop todo file'
  task todo: :environment do
    sh 'bundle exec rubocop --auto-gen-config'
  end
end
