bundle exec rubocop -a
git add .
git commit -m "Commit: Removed Habits API and created new Controller for Habits and basic operations with habits"
git push -u origin
git checkout main
git pull