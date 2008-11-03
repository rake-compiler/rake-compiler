When /^rake task '(.*)' is invoked$/ do |task_name|
  @output ||= {}
  @result ||= {}
  FileUtils.chdir @safe_dir do
    @output[task_name] = `rake #{task_name} 2>&1`
    @result[task_name] = $?.success?
  end
end

When /^rake task '(.*)' succeeded$/ do |task_name|
  if @result.nil? || !@result.include?(task_name) then
    raise "The task #{task_name} should be invoked first."
  else
    @result[task_name].should be_true
  end
end

Then /^output of rake task '(.*)' (does|does not) match \/(.*)\/$/ do |task_name, condition, regexp|
  (condition == 'does') ?
    @output[task_name].should(match(%r[#{regexp}])) :
    @output[task_name].should_not(match(%r[#{regexp}]))
end
