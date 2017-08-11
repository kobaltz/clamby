require 'spec_helper'

good_path = 'README.md'
bad_path = 'BAD_FILE.md'

describe Clamby do
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
      expect(Clamby.system_command(good_path)).to eq "clamscan #{good_path} --no-summary"
    end
    it 'passes the fdpass option when invoking clamscan if it is set' do
      Clamby.configure(fdpass: true)
      expect(Clamby.system_command(good_path)).to eq "clamscan --fdpass #{good_path} --no-summary"
    end
  end
end
