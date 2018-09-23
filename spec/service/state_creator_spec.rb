require 'rails_helper'

describe StateCreator do
  describe "#run" do
    it_behaves_like 'a record creator', 'State' do
      let(:bug) { FactoryBot.create(:bug) }
      let(:valid_attributes) do
        {
          device: 'iPhone X',
          os: 'iOS 11',
          memory: '1028',
          storage: '20480'
        }
      end
      let(:creator) { StateCreator.new(bug: bug, params: valid_attributes) }
      let(:invalid_creator) do
        StateCreator.new(bug: bug, params: { os: 'iOS 11', memory: '1028',storage: '20480' })
      end

      context 'with no bug present' do
        it 'raises a validation error' do
          expect do
            StateCreator.new(bug: nil, params: valid_attributes).run
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'missing bug argument' do
        it 'raises an argument error' do
          expect do
            StateCreator.new(params: valid_attributes).run
          end.to raise_error(ArgumentError)
        end
      end
    end
  end
end
