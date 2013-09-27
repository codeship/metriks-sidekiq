require 'spec_helper'

class TestWorker; end

module MetriksSidekiq
  describe Middleware do
    let(:options) { Hash.new }
    let(:msg)     { { foo: :bar} }
    let(:timer)   { double :timer }
    let(:meter)   { double :meter }

    subject(:middleware) { MetriksSidekiq::Middleware.new(options) }

    its(:prefix)  { should == "sidekiq" }

    context 'called with a block' do
      let(:worker) { TestWorker.new }
      let(:queue) { double :queue }

      it 'should track the worker duration' do
        Metriks.should_receive(:timer).with("sidekiq.test_worker.duration").and_return(timer.as_null_object)
        middleware.call(worker, msg, queue) { double }
      end

      it 'should yield the worker' do
        Metriks.should_receive(:timer).and_return(timer)
        timer.should_receive(:time).and_yield
        middleware.call(worker, msg, queue) { double }
      end

      it 'should increment the success count' do
        Metriks.stub_chain(:timer, :time)
        Metriks.should_receive(:meter).with("sidekiq.test_worker.success").and_return(meter.as_null_object)
        middleware.call(worker, msg, queue) { double }
      end

      it 'should increment the failure count' do
        Metriks.should_receive(:meter).with("sidekiq.test_worker.failure").and_return(meter.as_null_object)
        expect { middleware.call(worker, msg, queue) { raise } }.to raise_error
      end

      it 'should re-raise the exception' do
        expect { middleware.call(worker, msg, queue) { raise } }.to raise_error
      end

      it 'should time the latency' do
        msg = { 'enqueued_at' => Time.now.to_f }
        timer.stub :time
        Metriks.should_receive(:timer).with("sidekiq.test_worker.latency").and_return(timer)
        Metriks.should_receive(:timer).with("sidekiq.test_worker.duration").and_return(timer)
        timer.should_receive(:update).with(an_instance_of(Fixnum))
        middleware.call(worker, msg, queue) { double }
      end
    end
  end
end
