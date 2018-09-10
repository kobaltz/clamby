require 'spec_helper'
require 'support/shared_context'

describe Clamby::Command do
  describe 'ClamAV version' do
    it 'returns true' do
      command = described_class.clamscan_version
      expect(command).to be true
    end
  end
  describe 'scan' do
    include_context 'paths'

    describe 'exceptions' do
      it "can be configured to raise exception when file is missing" do
        Clamby.configure({:error_file_missing => true})
        subject.scan(bad_path)
        it { is_expected.to raise_exception(Exceptions::FileNotFound) }
      end
      it 'can be configured to return false when file is missing' do
        Clamby.configure({:error_file_missing => false})
        subject.scan(bad_path)
        it { is_expected.to be_false }
      end
    end

    describe 'passing file descriptor' do
      it 'does not include fdpass in the command by default' do
        Clamby.configure(fdpass: false)
        subject.scan(good_path)
        expect(subject.command).to eq ["clamscan", good_path, "--no-summary"]
      end
      it 'passes the fdpass option when invoking clamscan if it is set' do
        Clamby.configure(fdpass: true)
        subject.scan(good_path)
        it { is_expected.to have_command ["clamscan", "--fdpass", good_path, "--no-summary"] }
      end
    end

    describe 'streaming files to clamd' do
      it 'does not include stream in the command by default' do
        Clamby.configure(stream: false)
        subject.scan(good_path)
        expect(subject.command).to eq ["clamscan", good_path, "--no-summary"]
      end
      it 'omits the stream option when invoking clamscan if it is set, but daemonize isn\'t' do
        Clamby.configure(stream: true)
        subject.scan(good_path)
        expect(subject.command).to eq ["clamscan", good_path, "--no-summary"]
      end
      it 'passes the stream option when invoking clamscan if it is set with daemonize' do
        Clamby.configure(stream: true, daemonize: true)
        subject.scan(good_path)
        expect(subject.command).to eq ["clamdscan", "--stream", good_path, "--no-summary"]
      end
    end
  end
end
