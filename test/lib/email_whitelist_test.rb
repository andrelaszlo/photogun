class EmailWhitelistTest < ActionController::TestCase
  def setup
    @w = EmailWhitelist
  end

  test "single match" do
    assert @w.whitelisted? "foo@bar.com", whitelist: "foo@bar\.com"
  end

  test "empty whitelist" do
    assert_not @w.whitelisted? "foo@example.com", whitelist: ''
  end

  test "multi-entry whitelist" do
    list = 'foo@bar\.com;foo@example\.com'
    assert @w.whitelisted? "foo@example.com", whitelist: list
    assert @w.whitelisted? "foo@bar.com", whitelist: list
  end

  test "wildcard whitelist" do
    list = '.*@example.com;foo@.*\.com'
    assert @w.whitelisted? "bar@example.com", whitelist: list
    assert @w.whitelisted? "foo@bar.com", whitelist: list

    assert_not @w.whitelisted? "something@somewhere.com", whitelist: list
    assert_not @w.whitelisted? "foo@somewhere.net", whitelist: list
  end

  test "environment whitelist" do
    ENV['EMAIL_WHITELIST'] = 'foo@bar\.com'
    assert @w.whitelisted? "foo@bar.com"
  end
end
