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
    `wget http://www.eicar.org/download/eicar.com`
    `chmod 644 eicar.com`
    Clamby.configure({:error_file_virus => true})
    expect{Clamby.safe?('eicar.com')}.to raise_exception(Exceptions::VirusDetected)
    expect{Clamby.virus?('eicar.com')}.to raise_exception(Exceptions::VirusDetected)
    Clamby.configure({:error_file_virus => false})
    expect(Clamby.safe?('eicar.com')).to be false
    expect(Clamby.virus?('eicar.com')).to be true
    File.delete('eicar.com')
  end
end
