require 'test_helper'

class MotdTest < ActiveSupport::TestCase
  test "plaintext-formatter-erb returns a valid motd file when given a valid motd file" do
    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)
    expected_file = File.open(path).read

    assert_equal expected_file, formatted_motd.content
  end

  test "plaintext-formatter-erb returns an empty string when given an empty motd file" do
    path = "#{Rails.root}/test/fixtures/files/motd_empty"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test "plaintext-formatter-erb throws a standard error when given an invalid motd erb file" do
    path = "#{Rails.root}/test/fixtures/files/motd_erb_standard_error"
    motd_file = MotdFile.new(path)
    
    assert_raises(Exception) {
      MotdFormatterPlaintextErb.new(motd_file)
    }
  end

  test "plaintext-formatter-erb returns a valid motd erb file when given a valid motd erb file" do
    path = "#{Rails.root}/test/fixtures/files/motd_valid_erb"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)
    expected_file = "\nWelcome to the Ohio Supercomputer Center!\n"
    
    assert_equal expected_file, formatted_motd.content
  end
  
  test "plaintext-formatter-erb returns an empty string when given a missing file" do
    path = "#{Rails.root}/test/fixtures/files/motd_missing"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test "plaintext-formatter-erb returns an empty string when given nil" do
    motd_file = nil
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)

    assert_not_nil formatted_motd.content
  end

  test "plaintext-formatter-erb should recognize CurrentUserSingleton methods" do
    path = "#{Rails.root}/test/fixtures/files/motd_current_user"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)

    groups = OodSupport::User.new.groups.sort_by(&:id).tap { |groups|
      groups.unshift(groups.delete(OodSupport::Process.group))
    }.map(&:name).grep(/^P./)

    group  = OodSupport::Group.new
    user_in_group = groups.include? group

    expected_file = "\nYou're in #{groups.size} groups\nincluding #{group}.\n"

    assert_equal expected_file, formatted_motd.content
  end
end

