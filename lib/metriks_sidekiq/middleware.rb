require_relative '../core_ext/string'

module MetriksSidekiq
  class Middleware
    attr_reader :client, :prefix

    def initialize(client, options = {})
      @client = client
      @prefix = options.delete(:prefix) || "sidekiq"
    end

    def call(worker, msg, queue)
      if msg['enqueued_at']
        # convert and round to ms
        latency = ((Time.now.to_f - msg['enqueued_at']) * 1000).round
        client.timer(metric_key(worker, "latency")).update latency
      end

      client.timer(metric_key(worker, 'duration')).time do
        yield
      end

      client.meter(metric_key(worker, "success")).mark
    rescue Exception => e
      client.meter(metric_key(worker, "failure")).mark
      raise e
    end

    private

    def elapsed(start)
      (Time.now - start).to_f.round(3)
    end

    def metric_key(worker, key)
      worker_name = worker.class.name.underscore.gsub("/", ".")
      [prefix, worker_name, key].reject(&:nil?).join(".")
    end
  end
end
