require 'rails_helper'

describe CreateBugAndStateJob do
  describe '#perform' do
    let(:job) { CreateBugAndStateJob.new(bug_attributes.to_json, state_attributes.to_json) }

    context 'with valid attributes' do
      let(:bug_attributes) { {
        application_token: SecureRandom.hex(10),
        number: '1',
        status: 'new',
        priority: 'minor'
      } }
      let(:state_attributes) {
        {
          device: 'iPhone X',
          os: 'iOS 11',
          memory: '1028',
          storage: '20480'
        }
      }

      it 'uses the bug and state creator to bug and state records' do
        expect_any_instance_of(BugCreator).to receive(:run).once.and_call_original
        expect_any_instance_of(StateCreator).to receive(:run).once.and_call_original

        job.perform(bug_attributes, state_attributes)
      end

      it 'succesfully creates a bug with connected state' do
        expect {
          job.perform(bug_attributes, state_attributes)
        }.to change { Bug.count }.by(1)
         .and change { State.count }.by(1)
      end
    end

    context 'with invalid bug attributes' do
      let(:bug_attributes) { {
        status: 'new',
        priority: 'minor'
      } }
      let(:state_attributes) {
        {
          device: 'iPhone X',
          os: 'iOS 11',
          memory: '1028',
          storage: '20480'
        }
      }

      it 'rolls back bug and state creation' do
        expect do
          begin
            job.perform(bug_attributes, state_attributes)
          rescue => e
          end
        end.to_not change { Bug.count }

        expect do
          begin
            job.perform(bug_attributes, state_attributes)
          rescue => e
          end
        end.to_not change { State.count }
      end

      it 'raises a record invalid error' do
        expect do
          job.perform(bug_attributes, state_attributes)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
