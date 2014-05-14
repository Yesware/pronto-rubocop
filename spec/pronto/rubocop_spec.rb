require 'spec_helper'

module Pronto
  describe Rubocop do
    let(:rubocop) { Rubocop.new }

    describe '#run' do
      subject { rubocop.run(patches, nil) }

      context 'patches are nil' do
        let(:patches) { nil }
        it { should == [] }
      end

      context 'no patches' do
        let(:patches) { [] }
        it { should == [] }
      end
    end

    describe '#level' do
      subject { rubocop.level(severity) }

      ::Rubocop::Cop::Severity::NAMES.each do |severity|
        let(:severity) { severity }
        context "severity '#{severity}' conversion to Pronto level" do
          it { should_not be_nil }
        end
      end
    end

    describe '#initialize' do
      let(:inspector) { double('FileInspector') }
      let(:config_store) { double('ConfigStore') }

      before(:each) do
        ::Rubocop::FileInspector.stub(:new).and_return(inspector)
        ::Rubocop::ConfigStore.stub(:new).and_return(config_store)
      end

      it 'creates object instances' do
        ::Rubocop::FileInspector.should_receive(:new).with({})
        ::Rubocop::ConfigStore.should_receive(:new).with(no_args)

        rubocop
      end

      it 'assigns instance variables' do
        rubocop.instance_variable_get(:@inspector).should == inspector
        rubocop.instance_variable_get(:@config_store).should == config_store
      end

      context 'when an instance configure block is used' do
        let(:options) { double('options') }

        before(:each) do
          block_options = options
          ::Pronto::Rubocop.instance_configure do
            @config_store.options = block_options
          end
        end

        it 'evaluates the block in the context of the instance' do
          config_store.should_receive(:options=).with(options)

          rubocop
        end
      end
    end
  end
end
