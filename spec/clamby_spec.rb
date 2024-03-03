require 'spec_helper'
require 'support/shared_context'

describe Clamby do
  include_context 'paths'

  before { Clamby.configure(Clamby::DEFAULT_CONFIG.dup) }

  it "should find clamscan" do
    expect(Clamby.scanner_exists?).to be true
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
    begin
      file = download('https://secure.eicar.org/eicar.com')
    rescue SocketError => error
      pending("Skipped because reasons: #{error}")
    end

    dangerous = file.path
    Clamby.configure({:error_file_virus => true})
    expect{Clamby.safe?(dangerous)}.to raise_exception(Clamby::VirusDetected)
    expect{Clamby.virus?(dangerous)}.to raise_exception(Clamby::VirusDetected)
    Clamby.configure({:error_file_virus => false})
    expect(Clamby.safe?(dangerous)).to be false
    expect(Clamby.virus?(dangerous)).to be true
    File.delete(dangerous)
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
  end

  # From the clamscan man page:
  # Request clamd to reload virus database.
  context 'reload option' do
    it 'is false by default' do
      expect(Clamby.config[:reload]).to eq false
    end
    it 'accepts an reload option in the config' do
      Clamby.configure(reload: true)
      expect(Clamby.config[:reload]).to eq true
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
      before do
        Clamby.configure(error_clamscan_client_error: false)
        allow(Clamby::Command).to receive(:scan_status).and_return(2)
      end

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
      before do
        Clamby.configure(error_clamscan_client_error: true)
        allow(Clamby::Command).to receive(:scan_status).and_return(2)
      end

      it 'virus? raises when the daemonized client exits with status 2' do
        Clamby.configure(daemonize: true)
        expect { Clamby.virus?(good_path) }.to raise_error(Clamby::ClamscanClientError)
      end
      it 'returns true when the client exits with status 2' do
        Clamby.configure(daemonize: false)
        expect(Clamby.virus?(good_path)).to eq true
      end
    end
  end

  context 'executable paths' do
    context 'executable_path_clamscan option' do
      it 'is clamscan by default' do
        expect(Clamby.config[:executable_path_clamscan]).to eq 'clamscan'
      end
      it 'accepts an executable_path_clamscan option in the config' do
        path = '/custom/path/clamscan'
        Clamby.configure(executable_path_clamscan: path)
        expect(Clamby.config[:executable_path_clamscan]).to eq path
      end
    end

    context 'executable_path_clamdscan option' do
      it 'is clamdscan by default' do
        expect(Clamby.config[:executable_path_clamdscan]).to eq 'clamdscan'
      end
      it 'accepts an executable_path_clamdscan option in the config' do
        path = '/custom/path/clamdscan'
        Clamby.configure(executable_path_clamdscan: path)
        expect(Clamby.config[:executable_path_clamdscan]).to eq path
      end
    end

    context 'executable_path_freshclam option' do
      it 'is freshclam by default' do
        expect(Clamby.config[:executable_path_freshclam]).to eq 'freshclam'
      end
      it 'accepts an executable_path_freshclam option in the config' do
        path = '/custom/path/freshclam'
        Clamby.configure(executable_path_freshclam: path)
        expect(Clamby.config[:executable_path_freshclam]).to eq path
      end
    end
  end
end
