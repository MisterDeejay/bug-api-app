require 'rails_helper'

RSpec.describe 'Bugs API', type: :request do
  let(:application_token) { SecureRandom.hex(11) }
  let!(:bugs) do
    (0..9).inject([]) do |memo, i|
      memo << FactoryBot.create(:bug, number: i, application_token: application_token)
    end
  end
  let(:bug_id) { bugs.first.id }
  let(:bug_number) { bugs.first.number }
  let(:bug_app_token) { bugs.first.application_token }
  let!(:bug) { FactoryBot.create(:bug) }

  describe 'GET /bugs/count' do
    context 'testing the response object' do
      before { get '/bugs/count', params: {application_token: bugs.first.application_token} }

      it 'returns total number of bugs with the same application token' do
        expect(Bug.count).to eq(11)
        expect(json).not_to be_empty
        expect(json['count']).to eq(10.to_s)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'bugs count for the app has not been cached' do
      before do
        Redis.current.flushdb

        expect($redis.get(bug_app_token)).to be_nil
        expect($redis.get(bug.application_token)).to be_nil
      end

      it 'also caches the result of the query' do
        get '/bugs/count', params: {application_token: bug_app_token}

        expect($redis.get(bug_app_token)).to eq(bugs.count.to_s)
      end
    end
  end

  describe 'GET /bugs/:number' do
    before { get "/bugs/#{bug_number}?application_token=#{bug_app_token}" }

    context 'when the record exists' do
      it 'returns the bug' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(bug_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:bug_number) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Bug/)
      end
    end

    context 'without an application token' do
      before { get "/bugs/#{bug_number}" }
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Bug/)
      end
    end
  end

  # Test suite for POST /bugs
  describe 'POST /bugs' do
    let(:valid_attributes) { {
      application_token: SecureRandom.hex(10),
      status: 'new',
      priority: 'minor',
      state: {
        device: 'iPhone X',
        os: 'iOS 11',
        memory: '1028',
        storage: '20480'
      }
    } }
    let(:attributes_missing_state) { {
      application_token: SecureRandom.hex(10),
      status: 'new',
      priority: 'minor'
    } }

    context 'when the request is valid' do
      before do
        allow(CreateBugAndStateJob).to receive(:perform_later)
      end

      it 'enqueues a CreateBugAndStateJob to perform later' do
        post '/bugs', params: valid_attributes
        bug_params = valid_attributes.dup
        bug_params.delete(:state)
        state_params = valid_attributes[:state]

        expect(CreateBugAndStateJob).to have_received(:perform_later).with(bug_params, state_params)
      end

      it 'returns status code 200' do
        post '/bugs', params: valid_attributes
        expect(response).to have_http_status(200)
      end

      context 'with the bugs count already saved in the cache for the given app' do
        before do
          allow($redis).to receive(:get).and_call_original
          bug = FactoryBot.create(
            :bug,
            application_token: valid_attributes[:application_token]
          )

          $redis.set(
            bug.application_token,
            Bug.count_by_application_token(bug.application_token)
          )

          post '/bugs', params: valid_attributes
        end

        it 'returns the cached bugs count for the application' do
          bugs_count = Bug.count_by_application_token(
            valid_attributes[:application_token]
          )

          expect($redis).to have_received(:get).with(valid_attributes[:application_token]).exactly(4).times
          expect(JSON.parse(response.body)['count']).to eq(bugs_count.to_s)
        end
      end

      context 'without the bugs count in cache for the given app' do
        before do
          Redis.current.flushdb

          allow(Bug).to receive(:count_by_application_token)
          allow($redis).to receive(:get).and_call_original
          allow($redis).to receive(:set).and_call_original
          post '/bugs', params: valid_attributes
        end

        it 'returns the bugs count from the database' do
          expect(Bug).to have_received(:count_by_application_token)
            .with(valid_attributes[:application_token]).twice
          expect($redis).to have_received(:get)
            .with(valid_attributes[:application_token]).twice
        end
      end
    end

    context 'when the params submitted are invalid' do
      it 'still returns the current bugs count in the cache' do
        post '/bugs', params: attributes_missing_state

        expect(JSON.parse(response.body)['count']).to eq(
          Bug.count_by_application_token(
            attributes_missing_state[:application_token]
          ).to_s
        )
      end

      it 'rolls back bug creation' do
        expect do
          post '/bugs', params: attributes_missing_state
        end.to_not change { Bug.count }
      end

      it 'rolls back state creation' do
        expect do
          post '/bugs', params: attributes_missing_state
        end.to_not change { State.count }
      end
    end

    context 'submitting with a number attribute' do
      let(:attributes_with_bug_no) { {
        application_token: SecureRandom.hex(10),
        status: 'new',
        number: '110',
        priority: 'minor',
        state: {
          device: 'iPhone X',
          os: 'iOS 11',
          memory: '1028',
          storage: '20480'
        }
      } }
      before { post '/bugs', params: attributes_with_bug_no }

      it 'returns status code 404' do
        expect(response).to have_http_status(422)
      end

      it 'returns a bug submission error' do
        expect(response.body).to match(/Please submit these attributes without a bug number/)
      end
    end
  end
end
