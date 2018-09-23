require 'spec_helper'

shared_examples_for 'a record creator' do |klass_name|
  context 'valid attributes' do
    let(:record) { creator.run }

    it 'returns the record' do
      expect(record.class).to eq(klass_name.constantize)
      valid_attributes.each do |attr, val|
        expect(record.send(attr)).to eq(val)
      end
    end
  end

  context 'invalid attributes' do
    it 'raises a validation error' do
      expect { invalid_creator.run }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
