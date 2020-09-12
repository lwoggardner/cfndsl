# frozen_string_literal: true

require 'spec_helper'

describe 'cfndsl', type: :aruba do
  let(:usage) do
    <<-USAGE.gsub(/^ {6}/, '').chomp
      Usage: cfndsl [options] FILE
          -o, --output FILE                Write output to file
          -y, --yaml FILE                  Import yaml file as local variables
          -j, --json FILE                  Import json file as local variables
          -p, --pretty                     Pretty-format output JSON
          -f, --format FORMAT              Specify the output format (JSON default)
          -D, --define "VARIABLE=VALUE"    Directly set local VARIABLE as VALUE
          -v, --verbose                    Turn on verbose output
          -m, --disable-deep-merge         Disable deep merging of yaml
          -r, --require                    Require library
          -l, --list                       List supported resources
          -h, --help                       Display this screen
    USAGE
  end

  let(:template_content) do
    <<-TEMPLATE.gsub(/^ {6}/, '')
      CloudFormation do
        Description(external_parameters[:DESC] || 'default')
      end
    TEMPLATE
  end

  before(:each) { write_file('cloudformation_template.rb', template_content) }

  context 'cfndsl' do
    it 'displays the usage' do
      run_command 'cfndsl'
      expect(last_command_started).to have_output(usage)
      expect(last_command_started).to have_exit_status(1)
    end
  end

  context 'cfndsl --help' do
    it 'displays the usage' do
      run_command_and_stop 'cfndsl --help'
      expect(last_command_started).to have_output(usage)
    end
  end

  context 'cfndsl FILE' do
    it 'generates a JSON CloudFormation template' do
      run_command_and_stop 'cfndsl cloudformation_template.rb'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"default"}')
    end
  end

  context 'cfndsl FILE --pretty' do
    it 'generates a pretty JSON CloudFormation template' do
      run_command_and_stop 'cfndsl cloudformation_template.rb --pretty'
      expect(last_command_started).to have_output_on_stdout(<<-OUTPUT.gsub(/^ {8}/, '').chomp)
        {
          "AWSTemplateFormatVersion": "2010-09-09",
          "Description": "default"
        }
      OUTPUT
    end
  end

  context 'cfndsl FILE --output FILE' do
    it 'writes the JSON CloudFormation template to a file' do
      run_command_and_stop 'cfndsl cloudformation_template.rb --output template.json'
      expect(read('template.json')).to eq(['{"AWSTemplateFormatVersion":"2010-09-09","Description":"default"}'])
    end
  end

  context 'cfndsl FILE --yaml FILE' do
    before { write_file('params.yaml', 'DESC: yaml') }

    it 'interpolates the YAML file in the CloudFormation template' do
      run_command_and_stop 'cfndsl cloudformation_template.rb --yaml params.yaml'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"yaml"}')
    end
  end

  context 'cfndsl FILE --json FILE' do
    before { write_file('params.json', '{"DESC":"json"}') }

    it 'interpolates the JSON file in the CloudFormation template' do
      run_command_and_stop 'cfndsl cloudformation_template.rb --json params.json'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"json"}')
    end
  end

  context 'cfndsl FILE --define VARIABLE=VALUE' do
    it 'interpolates the command line variables in the CloudFormation template' do
      run_command "cfndsl cloudformation_template.rb --define \"DESC='cli'\""
      expect(last_command_started).to have_output_on_stdout("{\"AWSTemplateFormatVersion\":\"2010-09-09\",\"Description\":\"'cli'\"}")
    end
  end

  context 'cfndsl FILE --define VARIABLE=true' do
    it 'interpolates the command line variable with value true in the CloudFormation template ' do
      run_command 'cfndsl cloudformation_template.rb --define "DESC=true"'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":true}')
    end
  end

  context 'cfndsl FILE --define VARIABLE=false' do
    it 'interpolates the command line variable with value false in the CloudFormation template ' do
      run_command 'cfndsl cloudformation_template.rb --define "DESC=false"'
      expect(last_command_started).to have_output_on_stdout('{"AWSTemplateFormatVersion":"2010-09-09","Description":"default"}')
    end
  end

  context 'cfndsl FILE --verbose' do
    before { write_file('params.yaml', 'DESC: yaml') }

    it 'displays the variables as they are interpolated in the CloudFormation template' do
      run_command_and_stop 'cfndsl cloudformation_template.rb --yaml params.yaml --verbose'
      verbose = /
        Loading \s YAML \s file \s .* params\.yaml \n
        Loading \s template \s file \s .* cloudformation_template.rb \n
        Writing \s to \s STDOUT
      /x
      template = '{"AWSTemplateFormatVersion":"2010-09-09","Description":"yaml"}'
      expect(last_command_started).to have_output_on_stderr(verbose)
      expect(last_command_started).to have_output_on_stdout(template)
    end
  end

  context 'cfndsl --list' do
    it 'lists the available resources' do
      run_command_and_stop 'cfndsl --list'
      expect(last_command_started).to have_output_on_stdout(/Alexa::ASK::Skill/)
      expect(last_command_started).to have_output_on_stdout(/AWS::EC2::Instance/)
    end
  end
end
