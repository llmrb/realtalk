# frozen_string_literal: true

require "setup"

class BaseRouteTest < Relay::Test
  def test_root_path_raises_without_request_delegation
    assert_raise(NameError) do
      get "/"
    end
  end

  def test_unknown_get_route_redirects_to_root
    get "/nonexistent-route"
    assert_equal 302, last_response.status
    assert_equal "/", last_response.headers["Location"]
  end
end
