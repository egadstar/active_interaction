# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::HashFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  context 'with a nested nameless filter' do
    let(:block) { proc { hash } }

    it 'raises an error' do
      expect { filter }.to raise_error ActiveInteraction::InvalidFilterError
    end
  end

  describe '#cast' do
    let(:result) { filter.cast(value) }

    context 'with a Hash' do
      let(:value) { {} }

      it 'returns the Hash' do
        expect(result).to eql value
      end
    end

    context 'with a non-empty Hash' do
      let(:value) { { a: {} } }

      it 'returns an empty Hash' do
        expect(result).to eql({})
      end
    end

    context 'with a nested filter' do
      let(:block) { proc { hash :a } }

      context 'with a Hash' do
        let(:value) { { a: {} } }

        it 'returns the Hash' do
          expect(result).to eql value
        end

        context 'with String keys' do
          before do
            value.stringify_keys!
          end

          it 'does not raise an error' do
            expect { result }.to_not raise_error
          end
        end
      end

      context 'without a Hash' do
        let(:k) { 'a' }
        let(:v) { double }
        let(:value) { { k => v } }

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidNestedValueError
        end

        it 'populates the error' do
          begin
            result
          rescue ActiveInteraction::InvalidNestedValueError => e
            expect(e.filter_name).to eql k
            expect(e.input_value).to eql v
          end
        end
      end
    end

    context 'keys are symbolized' do
      let(:value) { { 'a' => 'a', 1 => 1 } }

      before do
        options.merge!(strip: false)
      end

      it 'symbolizes String keys' do
        expect(result).to have_key :a
      end

      it 'leaves other keys alone' do
        expect(result).to have_key 1
      end
    end
  end

  describe '#default' do
    context 'with a Hash' do
      before do
        options.merge!(default: {})
      end

      it 'returns the Hash' do
        expect(filter.default).to eql options[:default]
      end
    end

    context 'with a non-empty Hash' do
      before do
        options.merge!(default: { a: {} })
      end

      it 'raises an error' do
        expect do
          filter.default
        end.to raise_error ActiveInteraction::InvalidDefaultError
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to eql :string
    end
  end
end
