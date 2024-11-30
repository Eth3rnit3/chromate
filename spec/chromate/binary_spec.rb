# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate::Binary do
  describe '#run' do
    context 'when command exists' do
      it 'returns the stdout' do
        expect(Chromate::Binary.run('echo', ['hello'])).to eq "hello\n"
      end
    end

    context 'when command does not exist' do
      it 'raises an error' do
        expect { Chromate::Binary.run('invalid_command', []) }.to raise_error(Errno::ENOENT, 'No such file or directory - invalid_command')
      end
    end

    context 'when command fails and need_success is false' do
      it 'does not raise an error' do
        expect { Chromate::Binary.run('false', [], need_success: false) }.not_to raise_error
      end
    end

    context 'when command fails and need_success is true' do
      it 'raises an error' do
        expect { Chromate::Binary.run('false', [], need_success: true) }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#start' do
    let(:binary) { Chromate::Binary.new('echo', ['hello']) }

    it 'starts the process' do
      expect(binary.start).to be_a(Chromate::Binary)
    end

    it 'sets the pid' do
      expect(binary.start.pid).to be_a(Integer)
    end

    it 'is started' do
      expect(binary.start).to be_started
    end

    it 'returns self' do
      expect(binary.start).to eq(binary)
    end

    context 'when success starting the process' do
      let(:binary) { Chromate::Binary.new('tail', ['-f', '/dev/null']) }

      it 'starts and stops the process' do
        binary.start
        sleep 0.5
        pid = binary.pid

        expect(binary.started?).to be(true)
        expect(Process.getpgid(pid)).to be_a(Integer)

        binary.stop
        expect(binary.started?).to be(false)
        expect { Process.getpgid(pid) }.to raise_error(Errno::ESRCH)
      end
    end

    context 'when failing to start the process' do
      let(:binary) { Chromate::Binary.new('invalid_command', []) }

      it 'raises an error' do
        expect { binary.start }.to raise_error(Errno::ENOENT)
      end
    end

    context 'when process raises an error' do
      let(:binary) { Chromate::Binary.new('sh', ['-c', 'sleep 1; exit 1']) }

      it 'does not raise an error' do
        expect { binary.start }.not_to raise_error
        expect(binary.started?).to be(true)
        sleep 1.5

        expect(binary).not_to be_running
      end
    end
  end

  describe '#stop' do
    let(:binary) { Chromate::Binary.new('tail', ['-f', '/dev/null']) }

    before { binary.start }

    it 'stops the process' do
      sleep 1
      binary.stop
      expect(binary).not_to be_running
    end
  end
end
