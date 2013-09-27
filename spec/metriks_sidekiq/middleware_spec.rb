require 'spec_helper'

class TestWorker; end

module MetriksSidekiq
  describe Middleware do
    let(:options) { Hash.new }
    let(:msg)     { { foo: :bar} }
    let(:metriks) { double :metriks }
    let(:timer)   { double :timer }
    let(:meter)   { double :meter }

    subject(:middleware) { MetriksSidekiq::Middleware.new(metriks, options) }

    its(:prefix)  { should == "sidekiq" }

    context 'called with a block' do
      let(:worker) { TestWorker.new }
      let(:queue) { double :queue }

      it 'should track the worker duration' do
        metriks.stub meter: double.as_null_object
        metriks.should_receive(:timer).with("sidekiq.test_worker.duration").and_return(timer.as_null_object)
        middleware.call(worker, msg, queue) { double }
      end

      it 'should yield the worker' do
        metriks.stub meter: double.as_null_object
        metriks.should_receive(:timer).and_return(timer)
        timer.should_receive(:time).and_yield
        middleware.call(worker, msg, queue) { double }
      end

      it 'should increment the success count' do
        metriks.stub_chain(:timer, :time)
        metriks.should_receive(:meter).with("sidekiq.test_worker.success").and_return(meter.as_null_object)
        middleware.call(worker, msg, queue) { double }
      end

      it 'should increment the failure count' do
        metriks.should_receive(:meter).with("sidekiq.test_worker.failure").and_return(meter.as_null_object)
        expect { middleware.call(worker, msg, queue) { raise } }.to raise_error
      end

      it 'should re-raise the exception' do
        expect { middleware.call(worker, msg, queue) { raise } }.to raise_error
      end

      it 'should time the latency' do
        metriks.stub meter: double.as_null_object
        msg = { 'enqueued_at' => Time.now.to_f }
        timer.stub :time
        metriks.should_receive(:timer).with("sidekiq.test_worker.latency").and_return(timer)
        metriks.should_receive(:timer).with("sidekiq.test_worker.duration").and_return(timer)
        timer.should_receive(:update).with(an_instance_of(Fixnum))
        middleware.call(worker, msg, queue) { double }
      end
    end
  end
end
