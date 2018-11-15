require 'spec_helper'
require 'support/shared_context'

describe Clamby::Command do
  before { Clamby.configure(Clamby::DEFAULT_CONFIG.dup) }

  describe 'ClamAV version' do
    it 'returns true' do
      command = described_class.clamscan_version
      expect(command).to be true
    end
  end

  describe 'scan' do
    include_context 'paths'

    let(:runner){ instance_double(described_class) }

    describe 'exceptions' do
      it "can be configured to raise exception when file is missing" do
        Clamby.configure({:error_file_missing => true})

        expect do
          described_class.scan(bad_path)
        end.to raise_exception(Exceptions::FileNotFound)
      end
      it 'can be configured to return nil when file is missing' do
        Clamby.configure({:error_file_missing => false})
        command = described_class.scan(bad_path)

        expect(command).to be(nil)
      end
    end

    describe 'passing file descriptor' do
      it 'does not include fdpass in the command by default' do
        Clamby.configure(fdpass: false)
        expect(runner).to receive(:run).with('clamscan', good_path, '--no-summary')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end

      it 'omits the fdpass option when invoking clamscan if it is set, but daemonize isn\'t' do
        Clamby.configure(fdpass: true)
        expect(runner).to receive(:run).with('clamscan', good_path, '--no-summary')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end

      it 'passes the fdpass option when invoking clamscan if it is set with daemonize' do
        Clamby.configure(fdpass: true, daemonize: true)
        expect(runner).to receive(:run).with('clamdscan', good_path, '--no-summary', '--fdpass')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end
    end

    describe 'streaming files to clamd' do
      it 'does not include stream in the command by default' do
        Clamby.configure(stream: false)
        expect(runner).to receive(:run).with('clamscan', good_path, '--no-summary')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end

      it 'omits the stream option when invoking clamscan if it is set, but daemonize isn\'t' do
        Clamby.configure(stream: true)
        expect(runner).to receive(:run).with('clamscan', good_path, '--no-summary')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end

      it 'passes the stream option when invoking clamscan if it is set with daemonize' do
        Clamby.configure(stream: true, daemonize: true)
        expect(runner).to receive(:run).with('clamdscan', good_path, '--no-summary', '--stream')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end
    end

    describe 'specifying config-file' do
      it 'does not include the parameter in the clamscan command by default' do
        Clamby.configure(daemonize: false, stream: false, fdpass: false)
        expect(runner).to receive(:run).with('clamscan', good_path, '--no-summary')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end
      it 'does not include the parameter in the clamdscan command by default' do
        Clamby.configure(daemonize: true, stream: false, fdpass: false)
        expect(runner).to receive(:run).with('clamdscan', good_path, '--no-summary')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end
      it 'omits the parameter when invoking clamscan if it is set' do
        Clamby.configure(daemonize: false, stream: false, fdpass: false, config_file: 'clamd.conf')
        expect(runner).to receive(:run).with('clamscan', good_path, '--no-summary')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end
      it 'passes the parameter when invoking clamdscan if it is set' do
        Clamby.configure(daemonize: true, stream: false, fdpass: false, config_file: 'clamd.conf')
        expect(runner).to receive(:run).with('clamdscan', good_path, '--no-summary', '--config-file=clamd.conf')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end
    end
  end
end
