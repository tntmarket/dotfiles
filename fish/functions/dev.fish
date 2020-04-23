function dev
   if test -z $argv[1]
      ssh -t "m" "cd "(dev path)"; exec bash -l"
      return
   end

   set command $argv[1]
   set rest_of_args $argv[2..-1]
   switch $command
      case cmd
         ssh "m" "cd "(dev path)"; $rest_of_args"

      case tmux
         if ssh "m" -t "agenttmux2 -2 -CC attach"
            echo "Reusing existing tmux session"
         else
            echo "Creating new tmux session"
            ssh "m" -t "agenttmux2 -2 -CC"
         end

      case path
         pwd|sed "s=$HOME/pg=~/pg="
   end
end

