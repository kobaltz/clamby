RSpec.shared_context 'paths' do
  let(:special_path) { File.expand_path('../../fixtures/safe (special).txt', __FILE__) }
  let(:good_path) { File.expand_path('../../fixtures/safe.txt', __FILE__) }
  let(:bad_path) { File.expand_path("not-here/#{rand 10e6}.txt", __FILE__) }
end
