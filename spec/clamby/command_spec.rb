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
        end.to raise_exception(Clamby::FileNotFound)
      end
      it 'can be configured to return nil when file is missing' do
        Clamby.configure({:error_file_missing => false})
        command = described_class.scan(bad_path)

        expect(command).to be(nil)
      end
    end

    describe 'passing file descriptor' do
      it 'does not include fdpass in the command by default' do
        Clamby.configure
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
        Clamby.configure
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

    describe 'reloading virus database' do
      it 'does not include reload in the command by default' do
        Clamby.configure
        expect(runner).to receive(:run).with('clamscan', good_path, '--no-summary')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end

      it 'omits the reload option when invoking clamscan if it is set, but daemonize isn\'t' do
        Clamby.configure(reload: true)
        expect(runner).to receive(:run).with('clamscan', good_path, '--no-summary')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end

      it 'passes the reload option when invoking clamscan if it is set with daemonize' do
        Clamby.configure(reload: true, daemonize: true)
        expect(runner).to receive(:run).with('clamdscan', good_path, '--no-summary', '--reload')
        allow(described_class).to receive(:new).and_return(runner)

        described_class.scan(good_path)
      end
    end

    describe 'specifying config-file' do
      it 'does not include the parameter in the clamscan command by default' do
        Clamby.configure

        expect(described_class.new.send(:default_args)).not_to include(a_string_matching(/--config-file/))
      end
      it 'does not include the parameter in the clamdscan command by default' do
        Clamby.configure(daemonize: true)

        expect(described_class.new.send(:default_args)).not_to include(a_string_matching(/--config-file/))
      end
      it 'omits the parameter when invoking clamscan if it is set' do
        Clamby.configure(daemonize: false, config_file: 'clamd.conf')

        expect(described_class.new.send(:default_args)).not_to include('--config-file=clamd.conf')
      end
      it 'passes the parameter when invoking clamdscan if it is set' do
        Clamby.configure(daemonize: true, config_file: 'clamd.conf')

        expect(described_class.new.send(:default_args)).to include('--config-file=clamd.conf')
      end
    end

    describe 'specifying custom executable paths' do
      let(:runner) { described_class.new }
      let(:custom_path) { '/custom/path' }

      before do
        Clamby.configure(
          executable_path_clamscan: "#{custom_path}/clamscan",
          executable_path_clamdscan: "#{custom_path}/clamdscan",
          executable_path_freshclam: "#{custom_path}/freshclam",
        )
        allow(described_class).to receive(:new).and_return(runner)
      end

      it 'executes the freshclam executable from the custom path' do
        expect(runner).to receive(:system).with(
          "#{custom_path}/freshclam",
          {}
        ) { system("exit 0", out: File::NULL) }

        described_class.freshclam
      end

      context 'when not set with daemonize' do
        before { Clamby.configure(daemonize: false) }

        it 'executes the clamscan executable from the custom path' do
          expect(runner).to receive(:system).with(
            "#{custom_path}/clamscan --no-summary #{good_path}",
            {}
          ) { system("exit 0", out: File::NULL) }

          described_class.scan(good_path)
        end
      end

      context 'when set with daemonize' do
        before { Clamby.configure(daemonize: true) }

        it 'executes the clamdscan executable from the custom path' do
          expect(runner).to receive(:system).with(
            "#{custom_path}/clamdscan --no-summary #{good_path}",
            {}
          ) { system("exit 0", out: File::NULL) }

          described_class.scan(good_path)
        end
      end
    end

    describe 'special filenames' do
      it 'does not fail' do
        expect(described_class.scan(special_path)).to be(false)
      end
    end
  end
end
