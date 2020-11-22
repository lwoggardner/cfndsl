# frozen_string_literal: true

require 'rake/clean'
require 'rspec/core/rake_task'
require 'cfndsl/version'
require 'rubocop/rake_task'
require 'yamllint/rake_task'
require 'github_changelog_generator/task'
require 'cfndsl/rake_task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

desc 'Run RSpec with SimpleCov'
task :cov do
  ENV['CFNDSL_COV'] = 'true'
  Rake::Task[:spec].execute
end

YamlLint::RakeTask.new do |t|
  t.paths = %w[
    sample/t1.yaml
    .travis.yml
    .rubocop.yml
  ]
end

task default: %i[clean spec rubocop yamllint samples:generate]

# Test our own rake task and samples

directory 'tmp'

namespace :samples do
  source_files = FileList.new('sample/*.rb') { |fl| fl.exclude('**/circular.rb') }

  CfnDsl::RakeTask.new do |t|
    desc 'Generate CloudFormation Json'
    t.json(name: :json, files: source_files, pathmap: 'tmp/%f.json', pretty: true, extras: FileList.new('sample/*.yaml'))
    t.yaml(name: :yaml, files: 'sample/t1.rb', pathmap: 'tmp/%f.yaml', extras: %w[%X.yaml sample/t1-extra.yaml])
  end

  task :json => [ :cfndsl ]
  task :yaml => [ :cfndsl ]

  task :cfndsl do
    # Defer require of cfndsl until the gems are available
    require 'cfndsl'
  end
end

GEMS_PATH = File.expand_path("#{__FILE__}/../gems")

namespace :generate do
  # Download schema but only go on to generate if it has changed
  desc "Fetch schemas"
  task :fetch => [ :aws, :aws_serverless ]

  #task :aws => aws_schema
  #task :aws_serverless => aws_serverless_schema

  desc "Commit new schema"
  task :commit => :fetch do |t|
    #TODO: git add and commit -m "Updated schemas"
  end

end

namespace :gems do

  # For each gem
  #  Download schema file- detect changes
  #  if changed generate code, if not in deploy.yaml { bump minor version, add to deploy.yml }, commit -m "Generated <gem> from <url> @ <date>"
  require 'cfndsl/generate/rake_task'

  AWS_SCHEMA = 'https://schema.cloudformation.us-east-1.amazonaws.com/CloudformationSchema.zip'
  AWS_DIR = "#{GEMS_PATH}/cfndsl-aws"
  CLOBBER << "#{AWS_DIR}/lib/cfndsl"
  desc "Generate gem cfndsl-aws"
  CfnDsl::Generate::TaskLib.new do |t|
    t.lib(name: :aws, zip: AWS_SCHEMA, target_dir: AWS_DIR )
  end

  SERVERLESS_SCHEMA = 'https://raw.githubusercontent.com/aws/serverless-application-model/master/samtranslator/validator/sam_schema/schema.json'
  SERVERLESS_DIR = "#{GEMS_PATH}/cfndsl-aws-serverless/lib/cfndsl"
  CLOBBER << SERVERLESS_DIR
  require 'cfndsl/generate/serverless_specification'

  directory SERVERLESS_DIR
  desc "Generate gem cfndsl-aws-serverless"
  task :aws_serverless => [ SERVERLESS_DIR ] do |t|
    CfnDsl::Generate::ServerlessAppModelSpecification.generate_aws_serverless(SERVERLESS_SCHEMA, SERVERLESS_DIR )
  end
  #TODO
end

CLEAN.add 'tmp/*.rb.{json,yaml}', 'tmp/cloudformation_resources.json'

# Versioning under SemVer 2.0.0
# cfndsl_core
#   Patch version bump after release (ready for bugfixes)
#   Minor/Major version bump manually
#     also bump cfndsl, cfndsl-generate, cfndsl-aws, cfndsl-aws-serverless (because they reference the minor version of cfndsl-core as a dependency)
# cfndsl-generate => cfndsl-core
#   Patch version bump after release (ready for bugfixes)
#      optionally bump cfndsl-aws[-serverless] where the fixed will also fix the generated code
#   Minor/Major version bump manually
#     optionally bump cfndsl-aws[-serverless] where the changes impact the generated code
# cfndsl-aws[-serverless] => cfndsl-core
#   Minor version bump on any schema change - new or change properties as these are all Public API.
#    also bumps cfndsl
#   Major version bump manually also bump cfndsl

# Releasing
# Travis deploy config per gem in separate file imported into travis.yml
# Pre commit hook
#   - lint travis.yml
#   - if commits in gems/X then X must be in deploy.yml
# Post release
#   - bump patch versions of cfndsl-core, cfndsl-generate (if they are in deploy.yml)
#   - clear travis deploy config


task :bump, :type do |_, args|
  type = args[:type].downcase
  version_path = 'lib/cfndsl/version.rb'
  changelog = 'CHANGELOG.md'

  types = %w[major minor patch]

  raise unless types.include?(type)


  version_segments = CfnDsl::VERSION.split('.').map(&:to_i)

  segment_index = types.find_index type

  version_segments = version_segments.take(segment_index) +
                     [version_segments.at(segment_index).succ] +
                     [0] * version_segments.drop(segment_index.succ).count

  version = version_segments.join('.')

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.future_release = version
    config.user = 'cfndsl'
    config.project = 'cfndsl'
  end

  puts "Bumping gem from version #{CfnDsl::VERSION} to #{version} as a '#{type.capitalize}' release"

  puts 'Warning, CHANGELOG_GITHUB_TOKEN is unset, you will likely be rate limited' if ENV['CHANGELOG_GITHUB_TOKEN'].nil?
  Rake::Task[:changelog].execute

  contents         = File.read version_path
  updated_contents = contents.gsub(/'[0-9.]+'/, "'#{version}'")
  File.write(version_path, updated_contents)

  puts 'Committing version updates'
  `git add #{version_path} #{changelog}`
  `git commit --message='#{type.capitalize} release #{version}'`

  puts 'Tagging release'
  `git tag -a v#{version} -m 'Version #{version}'`

  puts 'Pushing branch'
  `git push origin master`

  puts 'Pushing tag'
  `git push origin v#{version}`

  puts 'All done, travis should pick up and release the gem now!'
end
