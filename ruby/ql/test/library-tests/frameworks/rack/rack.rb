class HelloWorld
  def call(env)
    status = 200
    if something_goes_wrong(env)
      status = 500
    end
    headers = {'Content-Type' => 'text/plain'}
    [status, headers, ['Hello World']]
  end
end

class Proxy
  def initialize(app)
    @app = app
  end

  def call(the_env)
    status, headers, body = @app.call(the_env)
    headers.content_type = "text/html"
    [status, headers, body]
  end
end

class Logger
  def initialize(app, logger = nil)
    @app = app
    @logger = logger
  end

  def call(env)
    began_at = Utils.clock_time
    status, header, body = @app.call(env)
    header = Utils::HeaderHash.new(header)
    body = BodyProxy.new(body) { log(env, status, header, began_at) }
    [status, header, body]
  end
end

class Redirector
  def call(env)
    status = 302
    headers = {'location' => '/foo.html'}
    [status, headers, ['this is a redirect']]
  end
end

class Foo
  def not_call(env)
    [1, 2, 3]
  end
end

class Bar
  def call(env)
    nil
  end
end

class Baz
  def call(env)
    run(env)
  end

  def run(env)
    if env[:foo] == "foo"
      [200, {}, "foo"]
    else
      error
    end
  end

  def error
    [400, {}, "nope"]
  end
end
