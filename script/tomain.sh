bundle exec rubocop -a
git add .
git commit -m "Updated UI for greeting message and made it more interactive"
git push -u origin
git checkout main
git pull