RSpec.shared_context 'paths' do
  let(:good_path) { File.expand_path('../../fixtures/safe.txt', __FILE__) }
  let(:bad_path) { File.expand_path("not-here/#{rand 10e6}.txt", __FILE__) }
end
