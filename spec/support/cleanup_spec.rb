# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Client mocks cleanup' do
  let(:client) { instance_double(Chromate::Client) }

  it 'resets mocks between tests' do
    allow(client).to receive(:send_message).with('test').and_return('test')
    expect(client.send_message('test')).to eq('test')
  end

  it 'starts with fresh mocks' do
    expect { client.send_message('test') }.to raise_error(RSpec::Mocks::MockExpectationError)
  end
end
