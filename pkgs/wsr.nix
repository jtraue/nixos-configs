{ writeShellApplication, watson, taskwarrior, ... }:
writeShellApplication
{
  name = "wsr";
  text = ''
    watson report --week --no-pager
    task end.after:today-1wk completed
  '';
  runtimeInputs = [ watson taskwarrior ];
}
