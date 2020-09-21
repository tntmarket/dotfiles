function dave
   set command $argv[1]
   switch $command
      case submit
         if test $argv[2]
            set description $argv[2]
            if test (git_branch_name) = master
               echo "Creating new branch... $description"
               if __new_branch (__description_to_branch_name $description)
                  echo "Saving new work..."
                  if g save $description
                     dev cmd "git push origin HEAD"
                  end
               end
            end
         else
            if test (git_branch_name) = master
               echo "You have to provide a description!"
            else
               echo "Amending previous work..."
               if g amend
                  dev cmd "git push origin HEAD --force"
               end
            end
         end
      case --complete
         __dave_complete
   end
end

function __description_to_branch_name --argument-names description
   echo $description | sed -e 's/ /_/g'
end

function __new_branch --argument-names branch_name
   dev cmd "git fetch "(__canonical_remote)"; git checkout "(__canonical_remote)"/master -b $branch_name; git push origin HEAD"
   git fetch (__canonical_remote)
   git checkout (__canonical_remote)/master -b $branch_name
end

function __dave_complete
   complete -xc dave -n "__fish_use_subcommand" -a submit -d "Commit changes, and post them for review"
end

function __canonical_remote
   if test (git remote | grep canon)
      echo canon
   else
      echo origin
   end
end
