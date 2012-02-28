require 'test/unit'
require 'rvc'

class ShellTest < Test::Unit::TestCase
  def setup
    session = RVC::MemorySession.new
    $shell = @shell = RVC::Shell.new(session)
    RVC::reload_modules false
  end

  def teardown
    $shell = @shell = nil
  end

  def test_parse_input
    cmd, args = RVC::Shell.parse_input "module.cmd --longarg -s vm1 vm2"
    assert_equal ['module', 'cmd'], cmd
    assert_equal ['--longarg', '-s', 'vm1', 'vm2'], args
  end

  def test_lookup_cmd
    ns, op = @shell.lookup_cmd ['basic', 'info']
    assert_equal @shell.modules['basic'], ns
    assert_equal :info, op

    ns, op = @shell.lookup_cmd ['ls']
    assert_equal @shell.modules['basic'], ns
    assert_equal :ls, op

    assert_raise RVC::Shell::InvalidCommand do
      @shell.lookup_cmd []
    end

    assert_raise RVC::Shell::InvalidCommand do
      @shell.lookup_cmd ['nonexistent-alias']
    end

    assert_raise RVC::Shell::InvalidCommand do
      @shell.lookup_cmd ['nonexistent-module', 'foo']
    end
  end
end