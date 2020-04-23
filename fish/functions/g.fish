function g
   if test -z $argv[1]
      git branch
      return
   end

   set command $argv[1]
   set rest_of_args $argv[2..-1]
   switch $command
      case co
         dev cmd "git co $rest_of_args"
         git co $rest_of_args

      case pull
         dev cmd "git pull"
         g sync

      case delete
         dev cmd "git branch -D $rest_of_args"
         git branch -D $rest_of_args
         git push -d origin $rest_of_args

      case stash
         dev cmd "git add -A; git stash"
         git add -A
         git stash

      case pop
         dev cmd "git stash pop"
         git stash pop

      case clean
         dev cmd "git reset HEAD; git checkout .; git clean -df"
         git reset HEAD
         git checkout .
         git clean -df

      # Work on a new repo
      case clone --argument-names repo_path
         dev cmd "git clone git@github.yelpcorp.com:$rest_of_args $rest_of_args"
         git clone git@github.yelpcorp.com:$rest_of_args $rest_of_args
         cd $rest_of_args
         git remote add 'dev' ssh://davelu@m/nail/home/davelu/pg/$rest_of_args

      # Resolve merge conflicts
      case resolve
         dev cmd "git add -A && git rebase --continue"
         git add -A
         git rebase --continue

      case sync
         git fetch --all
         git reset --hard dev/(git_branch_name)

      case b
         git branch

      case save
         if dev cmd "git add -A && git commit -m \"$rest_of_args\""
            g sync
         end

      case amend
         if dev cmd "git add -A && git commit --amend --no-edit"
            g sync
         end

      case fix
         if dev cmd "git add -A && git commit --fixup $rest_of_args && GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash"
            g sync
         end

      case forward
         g co $rest_of_args
         if g pull
            dev cmd "git push origin HEAD --force"
            g sync
         end
   end
end

