require 'spec_helper'

good_path = 'README.md'
bad_path = 'BAD_FILE.md'

describe Clamby do
  before { Clamby.configure(Clamby::DEFAULT_CONFIG.dup) }

  it "should find files." do
    expect(Clamby.file_exists?(good_path)).to be true
  end

  it "should find clamscan" do
    expect(Clamby.scanner_exists?).to be true
  end

  it "should not find files." do
    Clamby.configure({:error_file_missing => true})
    expect{Clamby.file_exists?(bad_path)}.to raise_exception(Exceptions::FileNotFound)
    Clamby.configure({:error_file_missing => false})
    expect(Clamby.file_exists?(bad_path)).to be false
  end

  it "should scan file as safe" do
    expect(Clamby.safe?(good_path)).to be true
    expect(Clamby.virus?(good_path)).to be false
  end

  it "should scan file and return nil" do
    Clamby.configure({:error_file_missing => false})
    expect(Clamby.safe?(bad_path)).to be nil
    expect(Clamby.virus?(bad_path)).to be nil
  end

  it "should scan file as dangerous" do
     `which wget`

     if $?.success?
      `wget http://www.eicar.org/download/eicar.com`
     else
      `curl http://www.eicar.org/download/eicar.com > eicar.com`
    end
    `chmod 644 eicar.com`
    Clamby.configure({:error_file_virus => true})
    expect{Clamby.safe?('eicar.com')}.to raise_exception(Exceptions::VirusDetected)
    expect{Clamby.virus?('eicar.com')}.to raise_exception(Exceptions::VirusDetected)
    Clamby.configure({:error_file_virus => false})
    expect(Clamby.safe?('eicar.com')).to be false
    expect(Clamby.virus?('eicar.com')).to be true
    File.delete('eicar.com')
  end

  # From the clamscan man page:
  # Pass the file descriptor permissions to clamd. This is useful if clamd is
  # running as a different user as it is faster than streaming the file to
  # clamd. Only available if connected to clamd via local(unix) socket.
  context 'fdpass option' do
    it 'is false by default' do
      expect(Clamby.config[:fdpass]).to eq false
    end
    it 'accepts an fdpass option in the config' do
      Clamby.configure(fdpass: true)
      expect(Clamby.config[:fdpass]).to eq true
    end
    it 'does not include fdpass in the command by default' do
      Clamby.configure(fdpass: false)
      expect(Clamby.system_command(good_path)).to eq ["clamscan", good_path, "--no-summary"]
    end
    it 'passes the fdpass option when invoking clamscan if it is set' do
      Clamby.configure(fdpass: true)
      expect(Clamby.system_command(good_path)).to eq ["clamscan", "--fdpass", good_path, "--no-summary"]
    end
  end

  # From the clamscan man page:
  # Forces file streaming to clamd. This is generally not needed as clamdscan
  # detects automatically if streaming is required. This option only exists for
  # debugging and testing purposes, in all other cases --fdpass is preferred.
  context 'stream option' do
    it 'is false by default' do
      expect(Clamby.config[:stream]).to eq false
    end
    it 'accepts an stream option in the config' do
      Clamby.configure(stream: true)
      expect(Clamby.config[:stream]).to eq true
    end
    it 'does not include stream in the command by default' do
      Clamby.configure(stream: false)
      expect(Clamby.system_command(good_path)).to eq ["clamscan", good_path, "--no-summary"]
    end
    it 'omits the stream option when invoking clamscan if it is set, but daemonize isn\'t' do
      Clamby.configure(stream: true)
      expect(Clamby.system_command(good_path)).to eq ["clamscan", good_path, "--no-summary"]
    end
    it 'passes the stream option when invoking clamscan if it is set with daemonize' do
      Clamby.configure(stream: true, daemonize: true)
      expect(Clamby.system_command(good_path)).to eq ["clamdscan", "--stream", good_path, "--no-summary"]
    end
  end

  context 'error_clamscan_client_error option' do
    it 'is false by default' do
      expect(Clamby.config[:error_clamscan_client_error]).to eq false
    end
    it 'accepts an error_clamscan_client_error option in the config' do
      Clamby.configure(error_clamscan_client_error: true)
      expect(Clamby.config[:error_clamscan_client_error]).to eq true
    end

    before {
      Clamby.configure(check: false)
      allow_any_instance_of(Process::Status).to receive(:exitstatus).and_return(2)
      allow(Clamby).to receive(:system)
    }

    context 'when false' do
      before { Clamby.configure(error_clamscan_client_error: false) }

      it 'virus? returns true when the daemonized client exits with status 2' do
        Clamby.configure(daemonize: true)
        expect(Clamby.virus?(good_path)).to eq true
      end
      it 'returns true when the client exits with status 2' do
        Clamby.configure(daemonize: false)
        expect(Clamby.virus?(good_path)).to eq true
      end
    end

    context 'when true' do
      before { Clamby.configure(error_clamscan_client_error: true) }

      it 'virus? raises when the daemonized client exits with status 2' do
        Clamby.configure(daemonize: true)
        expect { Clamby.virus?(good_path) }.to raise_error(Exceptions::ClamscanClientError)
      end
      it 'returns true when the client exits with status 2' do
        Clamby.configure(daemonize: false)
        expect(Clamby.virus?(good_path)).to eq true
      end
    end
  end
end
